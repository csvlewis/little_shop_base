require 'rails_helper'

RSpec.describe 'user addresses', type: :feature do
  context 'as a visitor' do
    it 'When I create an account, the address I submit is saved with the nickname "Home"' do
      visit registration_path

      fill_in :user_name, with: 'Name'
      fill_in :user_email, with: 'user@gmail.com'
      fill_in :user_password, with: '123'
      fill_in :user_password_confirmation, with: '123'

      click_button 'Create User'

      new_user = User.last

      expect(current_path).to eq(new_address_path)

      fill_in :address_street, with: '123 Main Street'
      fill_in :address_city, with: 'Denver'
      fill_in :address_state, with: 'CO'
      fill_in :address_zip, with: 12345

      click_button 'Create Address'

      expect(current_path).to eq(profile_path)
      expect(new_user.addresses.first.street).to eq('123 Main Street')
      expect(new_user.addresses.first.city).to eq('Denver')
      expect(new_user.addresses.first.state).to eq('CO')
      expect(new_user.addresses.first.zip).to eq(12345)
      expect(new_user.addresses.first.nickname).to eq('Home')
    end
  end

  context 'as a registered user' do
    before :each do
      @user = create(:user)
      login_as(@user)
    end
    it 'I can add a new address from a link on my Profile page' do
      expect(page).to_not have_content('123 Main Street')
      expect(@user.addresses.count).to eq(0)

      click_link 'Add an Address'

      expect(current_path).to eq(new_address_path)


      fill_in :address_nickname, with: 'Work'
      fill_in :address_street, with: '123 Main Street'
      fill_in :address_state, with: 'Denver'
      fill_in :address_city, with: 'CO'
      fill_in :address_zip, with: 12345

      click_button 'Create Address'

      expect(current_path).to eq(profile_path)
      expect(page).to have_content('123 Main Street')
      expect(@user.addresses.count).to eq(1)
    end

    it 'I am given an error message if I try to create an address with invalid information' do
      click_link 'Add an Address'

      click_button 'Create Address'

      expect(current_path).to eq(addresses_path)
      expect(page).to have_content('There are problems with the provided information.')
    end

    it 'I can edit an address I have created from my profile page' do

    end
  end
end
