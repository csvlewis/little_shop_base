class AddressesController < ApplicationController
  before_action :require_user

  def new
    @form_path = Address.new(nickname: 'Home')
  end

  def create
    @address = Address.create(address_params)
    if current_user.addresses << @address
      flash[:success] = 'You have created an address'
      redirect_to profile_path
    else
      flash[:danger] = 'There are problems with the provided information.'
      @form_path = @address
      render :new
    end
  end

  def edit
    @form_path = Address.find(params[:id])
  end

  def update
    @address = Address.find(params[:id])
    if @address.update(address_params)
      flash[:success] = 'You have edited an address.'
      redirect_to profile_path
    else
      flash[:danger] = 'There are problems with the provided information.'
      @form_path = @address
      render :edit
    end
  end

  def destroy
    @address = Address.find(params[:id])
    @address.destroy
    flash[:success] = 'You have deleted an address.'
    redirect_to profile_path
  end

  private

  def address_params
    params.require(:address).permit(:nickname, :street, :city, :state, :zip)
  end
end
