class ReviewsController < ApplicationController
  before_action :require_user

  def index
    @reviews = Review.where(user_id: current_user)
  end

  def new
    @review = Review.new
    @order_item = OrderItem.find(params[:order_item_id])
    @form_path = [@order_item, @review]
  end

  def create
    @order_item = OrderItem.find(params[:order_item_id])
    @review = Review.create(review_params)
    @review.username = current_user.name
    @review.item_name = @order_item.item.name
    current_user.reviews << @review
    if @order_item.reviews << @review
      flash[:success] = 'You have created a review.'
      redirect_to reviews_path(current_user)
    else
      flash[:danger] = 'There are problems with the provided information.'
      @form_path = [@order_item, @review]
      render :new
    end
  end

  def edit
    @review = Review.find(params[:id])
    @order_item = @review.order_item
    @form_path = [@order_item, @review]
  end

  def update
    @review = Review.find(params[:id])
    @order_item = OrderItem.find(params[:order_item_id])
    if @review.update(review_params)
      flash[:success] = 'You have edited a review.'
      redirect_to reviews_path(current_user)
    else
      flash[:danger] = 'There are problems with the provided information.'
      @form_path = [@order_item, @review]
      render :new
    end
  end

  def destroy
    @review = Review.find(params[:id])
    @review.destroy
    flash[:success] = 'You have deleted a review.'
    redirect_to reviews_path
  end

  private

  def review_params
    params.require(:review).permit(:title, :description, :rating)
  end
end
