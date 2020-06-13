require 'set'

class AuthTokenPresenter
  attr_reader :auth_token, :errors

  ERROR_TYPES_AND_MESSAGES = {
    auth_token_missing: 'Authentication failed',
    auth_token_invalid: 'Authentication failed'
  }

  def initialize(auth_token)
    @auth_token = auth_token
    @errors = Set.new
    @errors_checked = false
  end

  def check_errors
    return if @errors_checked
    errors.add(:auth_token_missing) unless auth_token
    errors.add(:auth_token_invalid) unless auth_token.valid?
    @errors_checked = true
  end

  def error_messages
    errors.map{ |error_type| ERROR_TYPES_AND_MESSAGES[error_type] }
  end

  def present
    check_errors

    if errors.any?
      present_errors
    else
      {
        auth_token: auth_token.value,
        user: {
          email: auth_token.user.email
        }
      }
    end
  end

  def present_errors
    { errors: error_messages }
  end

  def status
    check_errors
    errors.empty? ? :ok : :unauthorized
  end
end
