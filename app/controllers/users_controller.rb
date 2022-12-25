class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:create, :index]
    require 'jwt'
  
  def index
      users = User.left_outer_joins(:posts).select('users.*, count(posts.id) as post_count').group('users.id')
      render json: users
  end

  def show
      user = User.find(params[:id])
      render json: user
  end
  
  def create
      user = User.new(user_params)
      if user.save
        payload = {user_id: user.id}
        secrete_key = Rails.application.secrets.secret_key_base
        token = JWT.encode(payload, secrete_key)   
        render json: {token: token, user_id: user.id, name: user.name} 
      else
      render json: { error: "Invalid username or password" }, status: :unprocessable_entity
      end
  end
  
  def update
      user = User.find(params[:id])
      if user.update(user_params)
      render json: user
      else
      render json: { error: "Invalid username or password" }, status: :unprocessable_entity
      end
  end

  private
    def user_params
        params.require(:user).permit(:name, :password, :email)
    end
end
