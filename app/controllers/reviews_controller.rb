class ReviewsController < ApplicationController
  before_action :require_user

  def index

  end

  def new
    @review = Review.new
    @orderitem = OrderItem.find(params[:order_item_id])
  end

  def create
    @item =  OrderItem.find(params[:order_item_id]).item
    @review = Review.create(review_params)
    @review.order_item_id = params[:order_item_id]
    @review.username = current_user.name
    @review.item_name = @item.name
    current_user.reviews << @review
    redirect_to user_reviews_path(current_user)
  end

  private

  def review_params
    params.require(:review).permit(:title, :description, :rating)
  end
end
