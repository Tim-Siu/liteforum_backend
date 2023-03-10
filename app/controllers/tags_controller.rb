class TagsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :show]
  before_action :set_tag, only: %i[ show update destroy ]

  # GET /tags
  def index
    for tag in Tag.all
      if tag.posts.count == 0
        tag.destroy
      end
    end
    tags = Tag.all.order(created_at: :desc).limit(12).left_outer_joins(:posts).select('tags.*, count(posts.id) as post_count').group('tags.id')
    render json: tags
  end

  # GET /tags/1
  def show
    render json: @tag.as_json(include: [posts: {only: [:title, :id]}])
  end

  # POST /tags
  # def create
  #   @tag = Tag.new(tag_params)

  #   if @tag.save
  #     render json: @tag, status: :created, location: @tag
  #   else
  #     render json: @tag.errors, status: :unprocessable_entity
  #   end
  # end

  # PATCH/PUT /tags/1
  # def update
  #   if @tag.update(tag_params)
  #     render json: @tag
  #   else
  #     render json: @tag.errors, status: :unprocessable_entity
  #   end
  # end

  # DELETE /tags/1
  # def destroy
  #   @tag.destroy
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def tag_params
      params.require(:tag).permit(:name)
    end
end
