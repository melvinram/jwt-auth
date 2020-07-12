require 'test_helper'

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "auth token creation with valid credentials" do
    email = "mel@example.com"
    password = "password123"
    User.create!(email: email, password: password, password_confirmation: password)
    post auth_tokens_path, params: { email: email, password: password }, as: :json

    assert_response :success
    assert response.parsed_body.has_key?('auth_token')
    assert response.parsed_body.has_key?('user')
    assert_equal email, response.parsed_body['user']['email']

    refresh_token = cookies[:refresh_token]
    assert refresh_token.present?, "refresh_token cookie missing when creating a new auth token"

    auth_token = response.parsed_body['auth_token']
    get validate_auth_tokens_path, headers: { 'Authorization' => "Bearer #{auth_token}" }
    assert_response :success
  end

  test "auth token creation with invalid credentials" do
    email = "unknown@example.com"
    password = "password123"
    post auth_tokens_path, params: { email: email, password: password }, as: :json

    assert_response :unauthorized
    assert response.parsed_body.has_key?('errors')
    refute response.parsed_body.has_key?('auth_token')

    get validate_auth_tokens_path, headers: { 'Authorization' => 'Bearer invalid_token' }
    assert_response :unauthorized
  end

  test "auth token creation with valid refresh token and no credentials" do
    email = "mel@example.com"
    password = "password123"
    user = User.create!(email: email, password: password, password_confirmation: password)
    refresh_token = RefreshToken.create(user: user)
    post auth_tokens_path, as: :json, headers: { "HTTP_COOKIE" => "refresh_token=#{refresh_token.token};" }

    assert_response :success
    assert response.parsed_body.has_key?('auth_token')
    assert response.parsed_body.has_key?('user')
    assert_equal email, response.parsed_body['user']['email']

    get validate_auth_tokens_path, headers: { "HTTP_COOKIE" => "refresh_token=#{refresh_token.token};" }
    assert_response :unauthorized
  end

  test "auth token creation with expired refresh token and no credentials" do
    email = "mel@example.com"
    password = "password123"
    user = User.create!(email: email, password: password, password_confirmation: password)
    refresh_token = RefreshToken.create(user: user, expires_at: 1.minute.ago)
    post auth_tokens_path, as: :json, headers: { "HTTP_COOKIE" => "refresh_token=#{refresh_token.token};" }

    assert_response :unauthorized
    assert response.parsed_body.has_key?('errors')
    refute response.parsed_body.has_key?('auth_token')
  end

  test "auth token creation with no refresh token and no credentials" do
    email = "mel@example.com"
    password = "password123"
    user = User.create!(email: email, password: password, password_confirmation: password)
    post auth_tokens_path, as: :json

    assert_response :unauthorized
    assert response.parsed_body.has_key?('errors')
    refute response.parsed_body.has_key?('auth_token')
  end
end
