class ApplicationController < ActionController::API
    require 'jwt'
    before_action :authenticate_request, except: [:login]
    def login
      user = User.find_by(email: params[:email])
      if user && user.password == (params[:password])
        payload = {user_id: user.id}
        secrete_key = Rails.application.secrets.secret_key_base
        token = JWT.encode(payload, secrete_key)   
        render json: {token: token, user_id: user.id, name: user.name} 
     else 
        render json: {error: "Invalid email or password"}, status: :unauthorized
      end
    end
  
    def authenticate_request
      # Retrieve the JWT from the request headers
      auth_header = request.headers['Authorization']
      if auth_header
        # Extract the JWT from the Bearer token
        token = auth_header.split(' ').last
      else
        # Return a 401 Unauthorized response if the JWT is not present
        render json: { error: 'Not Authorized' }, status: 401
        return
      end
    
      # Decode and verify the JWT
      begin
        # decoded_token = JWT.decode(token, secret, true, algorithm: algorithm)
        decoded_token = JWT.decode(token, Rails.application.secrets.secret_key_base)
      rescue JWT::DecodeError
        # Return a 401 Unauthorized response if the JWT is invalid
        render json: { error: 'Not Authorized' }, status: 401
        return
      end
    
      # Set the current user by retrieving the user's information from the JWT payload
      @current_user = User.find(decoded_token[0]['user_id'])
    end

    
    
end
