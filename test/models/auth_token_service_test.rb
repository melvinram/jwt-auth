require 'test_helper'

class AuthTokenServiceTest < ActiveSupport::TestCase
  test "generate new auth token with valid email and password" do
    email = 'mr@example.com'
    password = 'password123'
    user = User.create!(email: email, password: password, password_confirmation: password)

    auth_token = AuthTokenService.generate(email: email, password: password)
    assert auth_token.is_a?(AuthToken)
    assert auth_token.valid?
    assert_equal user.id, auth_token.user.id

    auth = AuthTokenService.decode(auth_token.value)
    assert_equal email, auth[:email]
    assert_equal user.id, auth[:user_id]
  end

  test "generate new auth token with invalid email and password" do
    email = 'not-real-user@example.com'
    password = 'password123'

    auth_token = AuthTokenService.generate(email: email, password: password)
    refute auth_token.valid?

    token_is_valid = AuthTokenService.valid_token?(nil)
    assert_equal false, token_is_valid

    decoded_auth = AuthTokenService.decode(nil)
    assert decoded_auth[:error] = :decode_error

    token_is_valid = AuthTokenService.valid_token?('invalidtoken')
    assert_equal false, token_is_valid

    decoded_auth = AuthTokenService.decode('invalidtoken')
    assert decoded_auth[:error] = :decode_error
  end

  test "reject expired jwt tokens" do
    email = 'mr@example.com'
    password = 'password123'
    user = User.create!(email: email, password: password, password_confirmation: password)

    auth_token = AuthTokenService.generate(email: email, password: password)

    decoded_auth = AuthTokenService.decode(auth_token.value)
    token_is_valid = AuthTokenService.valid_token?(auth_token.value)
    refute decoded_auth.has_key?(:error)
    assert_equal true, token_is_valid

    expiration_time = Time.now + AuthTokenService::TOKEN_LIFETIME + 1.second
    travel_to expiration_time

    decoded_auth = AuthTokenService.decode(auth_token.value)
    token_is_valid = AuthTokenService.valid_token?(auth_token.value)
    assert_equal :expired_token, decoded_auth[:error]
    assert_equal false, token_is_valid

    travel_back
  end
end
