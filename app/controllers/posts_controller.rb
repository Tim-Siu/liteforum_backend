class PostsController < ApplicationController
  before_action :set_post, only: %i[ show update destroy ]
  skip_before_action :authenticate_request, only: [:index, :show]

  # GET /posts
  def index
    @posts = Post.left_outer_joins(:tags).select('posts.*, tags.name as tag_name').group('posts.id')
    begin
      render json: @posts
    rescue => e
      puts "Error rendering JSON: #{e.message}"
    end
  end

  # GET /posts/1
  def show
    render json: @post
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
    if @post.update(post_params)
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
