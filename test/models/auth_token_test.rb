require 'test_helper'
require 'auth_token'

class AuthTokenTest < ActiveSupport::TestCase
  test "build new jwt token with valid arguments" do
    email = 'mr@example.com'
    password = 'password123'
    user = User.create!(email: email, password: password, password_confirmation: password)

    auth_token = AuthToken.new(user_id: user.id, user_email: user.email)
    assert auth_token.valid?
    assert_equal user.id, auth_token.user_id

    auth = AuthToken.decode(auth_token.value)
    assert_equal email, auth[:email]
    assert_equal user.id, auth[:user_id]
  end

  test "build new auth token with missing arguments" do
    auth_token = AuthToken.new(user_id: nil, user_email: nil)
    refute auth_token.valid?

    decoded_auth = AuthToken.decode(nil)
    assert decoded_auth[:error] = :jwt_token_missing

    decoded_auth = AuthToken.decode('invalidtoken')
    assert decoded_auth[:error] = :decode_error
  end

  test "reject expired jwt tokens" do
    email = 'mr@example.com'
    password = 'password123'
    user = User.create!(email: email, password: password, password_confirmation: password)
    auth_token = AuthToken.new(user_id: user.id, user_email: user.email)
    decoded_auth = AuthToken.decode(auth_token.value)
    refute decoded_auth.has_key?(:error)

    expiration_time = Time.now + AuthToken::TOKEN_LIFETIME + 1.second
    travel_to expiration_time
    decoded_auth = AuthToken.decode(auth_token.value)

    assert decoded_auth.has_key?(:error)
    assert_equal :expired_token, decoded_auth[:error]

    travel_back
  end
end
