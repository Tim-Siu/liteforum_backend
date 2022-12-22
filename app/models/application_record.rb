class ApplicationRecord < ActiveRecord::Base
  require 'jwt'
  before_action :authenticate_user, except: [:login]
  primary_abstract_class
  def login
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      payload = {user_id: user.id}
      secrete_key = Rails.application.secrets.secret_key_base
      token = JWT.encode(payload, secrete_key)    
   else 
      render json: {error: "Invalid email or password"}, status: :unauthorized
    end
  end

  private

  def authenticate_user
    token = request.headers["Authorization"]
    begin
      decoded_token = JWT.decode(token, Rails.application.secrets.secret_key_base)
      @current_user = User.find(decoded_token[0]["user_id"])
    rescue
      render json: {error: "Invalid token"}, status: :unauthorized
    end
  end
end
