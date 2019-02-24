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

  private

  def address_params
    params.require(:address).permit(:nickname, :street, :city, :state, :zip)
  end
end
