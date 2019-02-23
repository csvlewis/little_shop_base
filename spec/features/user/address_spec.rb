require 'rails_helper'

RSpec.describe 'user addresses', type: :feature do
  context 'as a registered user' do
    it 'When I create an account, the address I submit is saved with the nickname "Home"' do
      visit registration_path

      fill_in :user_name, with: 'Name'
      fill_in :user_email, with: 'user@gmail.com'
      fill_in :user_address, with: '123 Main Street'
      fill_in :user_city, with: 'Denver'
      fill_in :user_state, with: 'Colorado'
      fill_in :user_zip, with: 12345
      fill_in :user_password, with: '123'
      fill_in :user_password_confirmation, with: '123'

      click_on 'Create User'

      new_user = User.last

      expect(new_user.addresses.first.street).to eq('123 Main Street')
      expect(new_user.addresses.first.city).to eq('Denver')
      expect(new_user.addresses.first.state).to eq('Colorado')
      expect(new_user.addresses.first.zip).to eq(12345)
      expect(new_user.addresses.first.nickname).to eq('Home')
    end
  end
end
