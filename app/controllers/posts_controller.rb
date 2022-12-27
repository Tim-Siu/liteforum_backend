
class PostsController < ApplicationController

  skip_before_action :authenticate_request, only: [:index, :show]
  before_action :set_post, only: [:show, :update, :destroy]

  # GET /posts
  def index
    render json: Post.all.order(created_at: :desc).limit(12).as_json(include: [:tags, user: {only: [:name]}])
  end

  def show
    render json: @post.as_json(include: [:tags, {comments: {include: [user: {only: [:name]}]}}, user: {only: [:name, :id]}])
  end

  # POST /posts
  def create
    @post = Post.new(post_params.except(:tags))
    tags = post_params[:tags]
    @post.user_id = @current_user.id
  
    if @post.save
      tags.each do |tag|
        @post.tags << Tag.find_or_create_by(name: tag)
      end
      render json: @post, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end
  

  # PATCH/PUT /posts/1
  def update
    if @post.user_id = @current_user.id
      @post.tags.destroy_all
      tags = post_params[:tags]
      tags.each do |tag|
        @post.tags << Tag.find_or_create_by(name: tag)
      end
      if @post.update(post_params.except(:tags))
        render json: @post
      else
        render json: @post.errors, status: :unprocessable_entity
      end
    else
      render json: {error: 'You are not authorized to edit this post'}, status: :unauthorized
    end

  end


  # DELETE /posts/1
  def destroy
    if @post.user_id = @current_user.id
      @post.destroy
    else
      render json: {error: 'You are not authorized to delete this post'}, status: :unauthorized
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body, tags: [])
    end
end
