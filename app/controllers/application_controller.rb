class ApplicationController < ActionController::Base
  def render_unauthenticated
    response_json = { error: 'The request you made requires authentication.' }
    render json: response_json, status: :unauthorized
  end

  def authenticated?
    current_user.present?
  end

  def current_user
    return @current_user if @current_user
    return if auth_token_payload[:error]

    user_id = auth_token_payload[:user_id]
    @current_user = User.find(user_id.to_i) if user_id
  end

  def auth_token_payload
    @auth_token_payload ||= AuthTokenService.decode(request.authorization)
  end
end
