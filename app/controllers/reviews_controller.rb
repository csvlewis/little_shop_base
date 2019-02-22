class ReviewsController < ApplicationController
  before_action :require_user

  def new
    @review = Review.new
  end
end
