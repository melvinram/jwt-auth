require 'auth_token'

class AuthTokenService
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s
  TOKEN_LIFETIME = 15.minutes

  def self.generate(email:, password:)
    auth_token = AuthToken.new
    user = User.find_by(email: email)

    if user && user.authenticate(password)
      payload = {
        user_id: user.id,
        email: email,
        expiration: TOKEN_LIFETIME.from_now.to_i
      }
      jwt_value = JWT.encode(payload, SECRET_KEY)

      auth_token.value = jwt_value
      auth_token.user = user
    end

    auth_token
  end

  def self.remove_bearer_prefix(jwt_token)
    return unless jwt_token.present?
    token_pattern = /^Bearer /
    jwt_token.gsub(token_pattern, '')
  end

  def self.decode(jwt_token)
    return { error: :jwt_token_missing } unless jwt_token

    begin
      decoded_token = JWT.decode(jwt_token, SECRET_KEY)[0].with_indifferent_access
      raise JWT::DecodeError unless decoded_token.respond_to?(:[])

      if decoded_token && Time.now.to_i < decoded_token[:expiration].to_i
        decoded_token
      else
        { error: :expired_token }
      end
    rescue JWT::DecodeError
      { error: :decode_error }
    end
  end

  def self.valid_token?(jwt_token)
    jwt_token = remove_bearer_prefix(jwt_token)
    decoded_token = decode(jwt_token)
    decoded_token[:error].blank?
  end
end
