class AddressesController < ApplicationController
  def new
    @form_path = Address.new(nickname: 'Home')
  end

  def create
    @address = Address.create(address_params)
    current_user.addresses << @address
    redirect_to profile_path
  end

  private

  def address_params
    params.require(:address).permit(:nickname, :street, :city, :state, :zip)
  end
end
