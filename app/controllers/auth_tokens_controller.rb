require 'auth_token'

class AuthTokensController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    auth_token = build_auth_token
    presenter = AuthTokenPresenter.new(auth_token)
    if auth_token.valid? && refresh_token.blank?
      @refresh_token = RefreshToken.create(user_id: auth_token.user_id)
      cookies[:refresh_token] = {
        value: refresh_token.token,
        expires: refresh_token.expires_at,
        httponly: true
      }
    end
    render json: presenter.present, status: presenter.status
  end

  def validate
    if authenticated?
      render json: { message: 'Your auth token is valid.' }, status: :ok
    else
      render_unauthenticated
    end
  end

  private

  def find_user
    return @user if @user

    if refresh_token.present?
      @user = User.find(refresh_token.user_id.to_i)
    elsif auth_token_params[:email].present? && auth_token_params[:password].present?
      @user = User.find_by(email: auth_token_params[:email])&.authenticate(auth_token_params[:password])
    else
      nil
    end
  end

  def build_auth_token
    return @auth_token if @auth_token

    user = find_user

    @auth_token = AuthToken.new(user_id: user&.id, user_email: user&.email)
  end

  def auth_token_params
    params.permit(:email, :password)
  end


  def refresh_token
    return @refresh_token if @refresh_token
    return unless request.cookies['refresh_token']

    # TODO: this feels a bit dangerous. User ID for the refresh token
    # should be required to create a new auth token with refresh token.
    # Otherwise, if the refresh token is somehow guessed, data leakage could happen.
    # I'm going to skip this for right now so I can move on to the React bits
    # but before this is used in production, this should be revisited.
    @refresh_token = RefreshToken.where(token: request.cookies['refresh_token']).active.first
  end
end
