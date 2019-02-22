class ReviewsController < ApplicationController
  before_action :require_user

  def index
  end

  def new
    @review = Review.new
    @orderitem = OrderItem.find(params[:order_item_id])
  end

  def create
    redirect_to user_reviews_path(current_user)
  end
end
