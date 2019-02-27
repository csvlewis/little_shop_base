require 'rails_helper'
include ActionView::Helpers::NumberHelper

=begin
- the top 5 most popular items by quantity purchased, plus the quantity bought
- the bottom 5 least popular items, plus the quantity bought

"Popularity" is determined by total quantity of that item fulfilled
=end

Random.new_seed
rng = Random.new

RSpec.describe 'items index stats', type: :feature do
  it 'should show the top and bottom items by quantity popularity' do
    merchant = create(:merchant)
    items = create_list(:item, 7, user: merchant)
    user = create(:user)
    Address.create(user: user, nickname: 'nickname', street: 'street', state: 'CO', city: 'Fairfield', zip: 1)

    order = create(:completed_order, user: user, address: user.addresses.first)
    create(:fulfilled_order_item, order: order, item: items[3], quantity: 7) # Name 4
    create(:fulfilled_order_item, order: order, item: items[1], quantity: 6) # Name 2
    create(:fulfilled_order_item, order: order, item: items[0], quantity: 5) # Name 1
    create(:fulfilled_order_item, order: order, item: items[2], quantity: 3) # Name 3
    create(:fulfilled_order_item, order: order, item: items[5], quantity: 2) # Name 6
    create(:fulfilled_order_item, order: order, item: items[4], quantity: 1) # Name 5

    visit items_path

    within '#statistics' do
      within '#popular-items' do
        popular = Item.popular_items(5)
        expect(page).to have_content("#{items[3].name}, total ordered: #{popular[0].total_ordered}")
        expect(page).to have_content("#{items[1].name}, total ordered: #{popular[1].total_ordered}")
        expect(page).to have_content("#{items[0].name}, total ordered: #{popular[2].total_ordered}")
        expect(page).to have_content("#{items[2].name}, total ordered: #{popular[3].total_ordered}")
        expect(page).to have_content("#{items[5].name}, total ordered: #{popular[4].total_ordered}")
      end
      within '#unpopular-items' do
        not_popular = Item.unpopular_items(5)
        expect(page).to have_content("#{items[4].name}, total ordered: #{not_popular[0].total_ordered}")
        expect(page).to have_content("#{items[5].name}, total ordered: #{not_popular[1].total_ordered}")
        expect(page).to have_content("#{items[2].name}, total ordered: #{not_popular[2].total_ordered}")
        expect(page).to have_content("#{items[0].name}, total ordered: #{not_popular[3].total_ordered}")
        expect(page).to have_content("#{items[1].name}, total ordered: #{not_popular[4].total_ordered}")
      end
      # items never ordered shouldn't show up at all
      expect(page).to_not have_content(items[6].name)
    end
  end
end
