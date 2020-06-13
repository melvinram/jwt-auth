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

  def self.validate(jwt_token)
    # token = token.value if token.is_a?(AuthToken)

    begin
      JWT.decode(jwt_token, SECRET_KEY)[0].with_indifferent_access
    rescue JWT::DecodeError
      return nil
      # TODO: log when nil value is passed in as token.
      # TODO: log when token cannot be decoded because token is invalid
    end
  end
end
