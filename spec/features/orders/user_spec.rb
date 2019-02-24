require 'rails_helper'

RSpec.describe 'User Order workflow', type: :feature do
  before :each do
    @user = create(:user)
    Address.create(user: @user, nickname: 'nickname', street: 'street', state: 'CO', city: 'Fairfield', zip: 1)
    @admin = create(:admin)

    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)

    @inventory_level = 20
    @purchased_amount = 5
    @item_1 = create(:item, user: @merchant_1)
    @item_2 = create(:item, user: @merchant_2, inventory: @inventory_level)

    @order_1 = create(:order, user: @user, address: @user.addresses.first, created_at: 1.day.ago)
    @oi_1 = create(:order_item, order: @order_1, item: @item_1, price: 1, quantity: 1, created_at: 1.day.ago)
    @oi_2 = create(:fulfilled_order_item, order: @order_1, item: @item_2, price: 2, quantity: @purchased_amount, created_at: 1.day.ago, updated_at: 2.hours.ago)

    @order_2 = create(:completed_order, user: @user, address: @user.addresses.first, created_at: 1.day.ago)
    @oi_1 = create(:fulfilled_order_item, order: @order_2, item: @item_1, price: 1, quantity: 1, created_at: 1.day.ago, updated_at: 5.hours.ago)
    @oi_2 = create(:fulfilled_order_item, order: @order_2, item: @item_2, price: 2, quantity: 1, created_at: 1.day.ago, updated_at: 2.hours.ago)

    visit item_path(@item_2)
    expect(page).to have_content("In stock: #{@inventory_level}")
  end

  describe 'order cancellation' do
    scenario 'as a user' do
      login_as(@user)
      visit profile_order_path(@order_2)
      expect(page).to_not have_button('Cancel Order')

      visit profile_order_path(@order_1)
      @am_user = true
    end
    scenario 'as an admin' do
      login_as(@admin)
      visit admin_user_order_path(@user, @order_2)
      expect(page).to_not have_button('Cancel Order')

      visit admin_user_order_path(@user, @order_1)
      @am_user = false
    end
    after :each do
      click_button('Cancel Order')

      if @am_user
        expect(current_path).to eq(profile_orders_path)
      else
        expect(current_path).to eq(admin_user_orders_path(@user))
      end

      within "#order-#{@order_1.id}" do
        expect(page).to have_content("Status: cancelled")
      end

      click_link "Order ID #{@order_1.id}"

      @order_1.order_items.each do |oi|
        within "#oitem-#{oi.id}" do
          expect(page).to have_content("Fulfilled: No")
        end
      end

      visit item_path(@item_2)
      expect(page).to have_content("In stock: #{@inventory_level + @purchased_amount}")
    end
  end

  scenario 'admins get a 404 if they try to access an order for a wrong user' do
    @user_2 = create(:user)
    login_as(@admin)

    visit admin_user_order_path(@user_2, @order_2)
    expect(page.status_code).to eq(404)
  end
end
