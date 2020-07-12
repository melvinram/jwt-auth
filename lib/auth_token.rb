class AuthToken
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s
  BEARER_PATTERN = /^Bearer /
  TOKEN_LIFETIME = 15.minutes

  attr_accessor :user_id, :user_email, :expiration

  def initialize(user_id: nil, user_email: nil)
    @user_id = user_id
    @user_email = user_email
    @expiration = TOKEN_LIFETIME.from_now
  end

  def value
    return @value if @value
    return if user_id.nil? || user_email.nil?

    jwt_payload = {
      user_id: user_id,
      email: user_email,
      expiration: expiration.to_i
    }
    @value = JWT.encode(jwt_payload, SECRET_KEY)
  end

  def valid?
    value.present?
  end

  def self.decode(jwt_token)
    return { error: :jwt_token_missing } unless jwt_token

    jwt_token = jwt_token.gsub(BEARER_PATTERN, '')

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
end
