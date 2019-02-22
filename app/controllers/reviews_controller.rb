class ReviewsController < ApplicationController
  before_action :require_user

  def index
    @reviews = Review.where(user_id: current_user)
  end

  def new
    @review = Review.new
    @order_item = OrderItem.find(params[:order_item_id])
  end

  def create
    @order_item = OrderItem.find(params[:order_item_id])
    @review = Review.create(review_params)
    @review.username = current_user.name
    @review.item_name = @order_item.item.name
    current_user.reviews << @review
    @order_item.review = @review
    redirect_to user_reviews_path(current_user)
  end

  private

  def review_params
    params.require(:review).permit(:title, :description, :rating)
  end
end
