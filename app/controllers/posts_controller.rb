class PostsController < ApplicationController
  before_action :set_post, only: %i[ show update destroy ]
  skip_before_action :authenticate_request, only: [:index, :show]

  # GET /posts
  def index
    # @posts = Post.left_outer_joins(:tags).select('posts.*, tags.name as tag_name').group('posts.id')
    # @posts = Post.includes(:tags).select('posts.*, tags.name as tag_name').group('posts.id')
    # @posts = Post.joins(:tags).select('posts.*, tags.name as tag_name').group('posts.id')
    # @posts = Post.eager_load(:tags).select('posts.*, tags.name').group('posts.id')
    # @posts = Post.includes(:tags).group('posts.id').pluck(:id, :title, 'tags.name')
    # @posts = Post.joins(:tags).group('posts.id').pluck(:id, :title, 'tags.name')
    posts = Post.eager_load(:tags).all
    results = []

    posts.each do |post|
      post_data = {
        id: post.id,
        title: post.title,
        user_name: post.user.name,
        created_at: post.created_at,
        tags: []
      }
      post.tags.each do |tag|
        post_data[:tags] << tag.name
      end
      results << post_data
    end
    render json: results
  end

  # GET /posts/1
  def show
    render json: @post.as_json(include: [:tags, :comments])
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
  end


  # DELETE /posts/1
  def destroy
    @post.destroy
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
