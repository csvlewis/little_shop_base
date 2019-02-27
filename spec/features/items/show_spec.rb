require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'items show workflow', type: :feature do
  it 'shows basic information about each item' do
    user = create(:user)
    Address.create(user: user, nickname: 'nickname', street: 'street', state: 'CO', city: 'Fairfield', zip: 1)
    merchant = create(:merchant)
    item = create(:item, user: merchant)
    order_1 = create(:completed_order, user: user, address: user.addresses.first)
    create(:fulfilled_order_item, order: order_1, item: item, quantity: 5, price: 2, created_at: 3.days.ago, updated_at: 1.day.ago)
    order_2 = create(:completed_order, user: user, address: user.addresses.first)
    create(:fulfilled_order_item, order: order_2, item: item, quantity: 5, price: 2, created_at: 1.days.ago, updated_at: 1.hour.ago)

    visit item_path(item)

    expect(page).to have_content(item.name)
    expect(page).to have_content(item.description)
    expect(page.find("#item-#{item.id}-image")['src']).to have_content(item.image)
    expect(page).to have_content("Sold by: #{item.user.name}")
    expect(page).to have_content("In stock: #{item.inventory}")
    expect(page).to have_content(number_to_currency(item.price))
    expect(page).to have_content("Average time to fulfill: 1 day 11:30")
  end
  it 'shows alternate data if out of stock or never fulfilled' do
    user = create(:user)
    merchant = create(:merchant)
    item = create(:item, user: merchant, inventory: 0)

    visit item_path(item)

    expect(page).to have_content("Out of Stock")
    expect(page).to_not have_content("In stock: #{item.inventory}")
    expect(page).to have_content("Average time to fulfill: n/a")
  end
end
