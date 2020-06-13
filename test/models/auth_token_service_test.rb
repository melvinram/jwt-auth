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

    auth = AuthTokenService.validate(auth_token.value)
    assert_equal email, auth[:email]
    assert_equal user.id, auth[:user_id]
  end

  test "generate new auth token with invalid email and password" do
    email = 'not-real-user@example.com'
    password = 'password123'

    auth_token = AuthTokenService.generate(email: email, password: password)
    refute auth_token.valid?

    auth = AuthTokenService.validate(nil)
    assert_nil auth

    auth = AuthTokenService.validate('invalidtoken')
    assert_nil auth
  end
end
