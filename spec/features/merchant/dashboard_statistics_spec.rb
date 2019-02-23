require 'rails_helper'

RSpec.describe 'merchant dashboard statistics' do
  before :each do
    a1 = Address.create(nickname: 'Home', street: 'street', city: 'Fairfield', state: 'CO', zip: 1)
    a2 = Address.create(nickname: 'Home', street: 'street', city: 'OCK', state: 'OK', zip: 1)
    a3 = Address.create(nickname: 'Home', street: 'street', city: 'Fairfield', state: 'IA', zip: 1)
    a4 = Address.create(nickname: 'Home', street: 'street', city: 'Des Moines', state: 'IA', zip: 1)
    @u1 = create(:user, addresses: a1)
    @u2 = create(:user, addresses: a2)
    @u2 = create(:user, addresses: a2)
    @u3 = create(:user, addresses: a3)
    u4 = create(:user, addresses: a4)
    u5 = create(:user, addresses: a4)
    u6 = create(:user, addresses: a4)
    @m1 = create(:merchant)
    @m2 = create(:merchant)
    @i1 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i2 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i3 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i4 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i5 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i6 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i7 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i9 = create(:item, merchant_id: @m1.id, inventory: 20)
    @i8 = create(:item, merchant_id: @m2.id, inventory: 20)
    o1 = create(:completed_order, user: @u1)
    o2 = create(:completed_order, user: @u2)
    o3 = create(:completed_order, user: @u3)
    o4 = create(:completed_order, user: @u1)
    o5 = create(:cancelled_order, user: u5)
    o6 = create(:completed_order, user: u6)
    @oi1 = create(:order_item, item: @i1, order: o1, quantity: 2, created_at: 1.days.ago)
    @oi2 = create(:order_item, item: @i2, order: o2, quantity: 7, created_at: 7.days.ago)
    @oi3 = create(:order_item, item: @i2, order: o3, quantity: 7, created_at: 7.days.ago)
    @oi4 = create(:order_item, item: @i3, order: o3, quantity: 4, created_at: 6.days.ago)
    @oi5 = create(:order_item, item: @i4, order: o4, quantity: 3, created_at: 4.days.ago)
    @oi6 = create(:order_item, item: @i5, order: o5, quantity: 1, created_at: 5.days.ago)
    @oi7 = create(:order_item, item: @i6, order: o6, quantity: 2, created_at: 3.days.ago)
    @oi1.fulfill
    @oi2.fulfill
    @oi3.fulfill
    @oi4.fulfill
    @oi5.fulfill
    @oi6.fulfill
    @oi7.fulfill

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@m1)
    visit dashboard_path
  end

  it 'shows top items sold by quantity' do
    within("#top-items-sold-by-quantity") do
      expect(page.all('li')[0]).to have_content("#{@i2.name}: 14")
      expect(page.all('li')[1]).to have_content("#{@i3.name}: 4")
      expect(page.all('li')[2]).to have_content("#{@i4.name}: 3")
      expect(page.all('li')[3]).to have_content("#{@i1.name}: 2")
      expect(page.all('li')[4]).to have_content("#{@i6.name}: 2")
    end
  end

  it 'shows percent of items sold' do
    within("#percent-of-items-sold") do
      expect(page).to have_content("You have sold 26 items, 19.40% of your total inventory")
    end
  end

  it 'shows top states where items were shipped, but quantity' do
    within('#top-states-by-items-shipped') do
      expect(page.all('li')[0]).to have_content("IA: 14")
      expect(page.all('li')[1]).to have_content("OK: 7")
      expect(page.all('li')[2]).to have_content("CO: 5")
    end
  end

  it 'shows top cities where items were shipped, but quantity' do
    within('#top-cities-by-items-shipped') do
      expect(page.all('li')[0]).to have_content("Fairfield, IA: 11")
      expect(page.all('li')[1]).to have_content("OKC, OK: 7")
      expect(page.all('li')[2]).to have_content("Fairfield, CO: 5")
    end
  end

  it 'shows top user by order count' do
    within("#top-user-by-order-count") do
      expect(page).to have_content("#{@u1.name}: 2 orders")
    end
  end

  it 'shows NA if no top user by order' do
    merchant = create(:merchant)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)
    visit dashboard_path

    within("#top-user-by-order-count") do
      expect(page).to have_content("N/A")
    end
  end

  it 'shows top user by item count' do
    within("#top-user-by-item-count") do
      expect(page).to have_content("#{@u3.name}: 11 items")
    end
  end

  it 'shows NA if no top user by item' do
    merchant = create(:merchant)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)
    visit dashboard_path

    within("#top-user-by-item-count") do
      expect(page).to have_content("N/A")
    end
  end

  it 'shows top users by money spent' do
    within('#top-users-by-money-spent') do
      expect(page.all('li')[0]).to have_content("#{@u3.name}: $72.00")
      expect(page.all('li')[1]).to have_content("#{@u1.name}: $33.00")
      expect(page.all('li')[2]).to have_content("#{@u2.name}: $31.50")
    end
  end
end
