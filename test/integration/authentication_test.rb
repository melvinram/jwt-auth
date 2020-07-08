require 'test_helper'

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "auth token creation with valid credentials" do
    email = "mel@example.com"
    password = "password123"
    User.create!(email: email, password: password, password_confirmation: password)
    post auth_tokens_path, params: { user: { email: email, password: password } }, as: :json

    assert_response :success
    assert response.parsed_body.has_key?('auth_token')
    assert response.parsed_body.has_key?('user')
    assert_equal email, response.parsed_body['user']['email']

    auth_token = response.parsed_body['auth_token']
    get validate_auth_tokens_path, headers: { 'Authorization' => "Bearer #{auth_token}" }
    assert_response :success
  end

  test "auth token creation with invalid credentials" do
    email = "unknown@example.com"
    password = "password123"
    post auth_tokens_path, params: { user: { email: email, password: password } }, as: :json

    assert_response :unauthorized
    assert response.parsed_body.has_key?('errors')
    refute response.parsed_body.has_key?('auth_token')

    get validate_auth_tokens_path, headers: { 'Authorization' => 'Bearer invalid_token' }
    assert_response :unauthorized
  end
end
