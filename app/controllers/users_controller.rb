class UsersController < ApplicationController
  before_action :require_user, only: [:show, :edit]

  def new
    @user = User.new
    @address = Address.new(nickname: 'Home')
    @form_path = @user
  end

  def show
    @user = current_user
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "Welcome #{@user.name}, you are now registered and logged in."
      flash[:notice] = "Enter a home address."
      redirect_to new_address_path
    else
      invalid_user(@user)
    end
  end

  def edit
    @user = current_user
    @form_path = @user
  end

  def update
    @user = current_user
    @form_path = @user
    if @user.update(user_params)
      flash[:success] = "Your profile has been updated"
      redirect_to profile_path
    else
      flash[:alert] = "That email address is already in use"
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :address, :city, :state, :zip, :password)
  end

  def invalid_user(user)
    @user = user
    @form_path = @user
    if User.find_by(email: @user.email)
      @user.email = ""
    else
      flash[:alert] = "Required field(s) missing."
    end
    render :new
  end
end
