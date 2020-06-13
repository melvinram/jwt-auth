require 'auth_token_service'

class AuthTokensController < ApplicationController
  def create
    auth_token = AuthTokenService.generate(email: auth_token_params[:email], password: auth_token_params[:password])
    presenter = AuthTokenPresenter.new(auth_token)
    render json: presenter.present, status: presenter.status
  end

  private

  def auth_token_params
    params.require(:user).permit(:email, :password)
  end
end
