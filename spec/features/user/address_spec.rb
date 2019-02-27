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

  context 'as an admin' do
    it 'I do not see links to edit, delete, or create an address on a user\'s profile' do
      admin = create(:admin)
      user = create(:user)
      address = Address.create(nickname: 'Home', street: 'street', city: 'city', state: 'state', zip: 1)
      user.addresses << address

      login_as(admin)

      visit admin_user_path(user)

      expect(page).to_not have_link('Edit Address')
      expect(page).to_not have_link('Add an Address')
      expect(page).to_not have_link('Delete Address')
    end
  end

  context 'as a registered user' do
    before :each do
      @user = create(:user)
      @address = Address.create(nickname: 'Home', street: 'street', city: 'city', state: 'state', zip: 1)
      @user.addresses << @address
      login_as(@user)
      @merchant = create(:merchant)
      @item = create(:item, user: @merchant)
    end
    it 'I can add a new address from a link on my Profile page' do
      expect(page).to_not have_content('123 Main Street')
      expect(@user.addresses.count).to eq(1)

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
      expect(@user.addresses.count).to eq(2)
    end

    it 'I am given an error message if I try to create an address with invalid information' do
      click_link 'Add an Address'

      click_button 'Create Address'

      expect(current_path).to eq(addresses_path)
      expect(page).to have_content('There are problems with the provided information.')
    end

    it 'I can edit an address I have created from my profile page' do
      expect(page).to have_content("Street: #{@address.street}")
      click_link 'Edit Address'

      expect(current_path).to eq(edit_address_path(@address))

      fill_in :address_street, with: 'New Street'

      click_button 'Update Address'

      expect(@user.addresses.first.street).to eq('New Street')
      expect(page).to have_content("Street: New Street")
    end

    it 'I cannot edit an address that has been used in a completed order' do
      expect(page).to have_link('Edit Address')

      create(:completed_order, user: @user, address: @user.addresses.first)
      visit profile_path

      expect(page).to_not have_link('Edit Address')
    end

    it 'I am given an error message if I try to edit an address with invalid information.' do
      click_link 'Edit Address'
      fill_in :address_street, with: ''

      click_button 'Update Address'
      expect(current_path).to eq(address_path(@address))
      expect(page).to have_content('There are problems with the provided information.')
    end

    it 'I can delete an address I have created from my profile page' do
      expect(@user.addresses.count).to eq(1)
      expect(page).to have_content("Street: #{@address.street}")

      click_link 'Delete Address'

      expect(current_path).to eq(profile_path)
      expect(@user.addresses.count).to eq(0)
      expect(page).to_not have_content("Street: #{@address.street}")
    end

    it 'I cannot delete an address that has been used in an order' do
      address_2 = Address.create(nickname: 'Work', street: 'street', city: 'city', state: 'state', zip: 1)
      address_3 = Address.create(nickname: 'Work 2', street: 'street', city: 'city', state: 'state', zip: 1)
      @user.addresses << [address_2, address_3]

      visit profile_path

      expect(page).to have_content("#{@address.nickname}")
      expect(page).to have_content("#{address_2.nickname}")
      expect(page).to have_content("#{address_3.nickname}")
      expect(page).to have_link('Delete Address')

      create(:completed_order, user: @user, address: @user.addresses.first)
      create(:order, user: @user, address: @user.addresses.second)
      create(:cancelled_order, user: @user, address: @user.addresses.third)
      visit profile_path

      expect(page).to have_content("#{@address.nickname}")
      expect(page).to have_content("#{address_2.nickname}")
      expect(page).to have_content("#{address_3.nickname}")
      expect(page).to_not have_link('Delete Address')
    end

    it 'I can choose one of my adresses for shipping when checking out my cart' do

      visit item_path(@item)
      click_button "Add to Cart"
      visit cart_path
      click_button 'Check out'

      expect(current_path).to eq(addresses_path)

      click_link 'Ship to This Address'

      expect(current_path).to eq(profile_orders_path)
      expect(page).to have_content('You have successfully checked out!')
      expect(page).to have_content("Order ID #{Order.last.id}")
      expect(Order.last.address).to eq(@address)
    end

    it 'if I have no addresses, I cannot check out and instead receive a notice with a link to add an address' do

      click_link 'Delete Address'
      expect(@user.addresses.count).to eq(0)

      visit item_path(@item)
      click_button "Add to Cart"
      visit cart_path

      expect(page).to_not have_button('Check out')

      click_link 'add an address'

      expect(current_path).to eq(new_address_path)

      fill_in :address_street, with: '123 Main Street'
      fill_in :address_city, with: 'Denver'
      fill_in :address_state, with: 'CO'
      fill_in :address_zip, with: 12345

      click_button 'Create Address'

      expect(@user.addresses.count).to eq(1)
    end

    it 'I can change the address of a pending order' do
      order = create(:order, user: @user, address: @address)
      address = Address.create(user: @user, nickname: 'Work', street: 'street 2', city: 'city 2', state: 'state 2', zip: 2)

      expect(@user.orders.first.address).to eq(@address)

      click_link 'Orders'
      click_link "#{order.id}"
      click_button 'Change Shipping Address'

      expect(current_path).to eq(addresses_path)

      within(".address-#{address.id}") do
        click_link 'Ship to This Address'
      end

      expect(current_path).to eq(profile_order_path(order))
      expect(@user.orders.first.address).to eq(address)
      expect(page).to have_content('You have changed this order\'s shipping address.')
      expect(page).to have_content("Street: #{address.street}")
      expect(page).to have_content("State: #{address.state}")
      expect(page).to have_content("City: #{address.city}")
      expect(page).to have_content("Zip code: #{address.zip}")
    end

    it 'I can see the shipping address of an order on its show page' do
      order = create(:order, user: @user, address: @address)

      click_link 'Orders'
      click_link "#{order.id}"

      expect(page).to have_content("Nickname: #{@address.nickname}")
      expect(page).to have_content("Street: #{@address.street}")
      expect(page).to have_content("State: #{@address.state}")
      expect(page).to have_content("City: #{@address.city}")
      expect(page).to have_content("Zip code: #{@address.zip}")
    end
  end
end
