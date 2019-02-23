require 'rails_helper'

RSpec.describe 'User Reviews', type: :feature do
  before :each do
    @user = create(:user)
    @user_2 = create(:user)
    @merchant_1 = create(:merchant)

    @item_1 = create(:item, user: @merchant_1)
    @item_2 = create(:item, user: @merchant_1)

    @pending_order = create(:order, user: @user,)
    @oi_1 = create(:order_item, order: @pending_order, item: @item_1)

    @cancelled_order = create(:cancelled_order, user: @user)
    @oi_2 = create(:order_item, order: @cancelled_order, item: @item_1)

    @completed_order_1 = create(:completed_order, user: @user)
    @oi_3 = create(:fulfilled_order_item, order: @completed_order_1, item: @item_1)
    @oi_4 = create(:fulfilled_order_item, order: @completed_order_1, item: @item_2)

    @completed_order_2 = create(:completed_order, user: @user)
    @oi_5 = create(:fulfilled_order_item, order: @completed_order_2, item: @item_1)
    @oi_6 = create(:fulfilled_order_item, order: @completed_order_2, item: @item_2)

    @completed_order_3 = create(:completed_order, user: @user_2)
    @oi_7 = create(:fulfilled_order_item, order: @completed_order_3, item: @item_1)
    @oi_8 = create(:fulfilled_order_item, order: @completed_order_3, item: @item_2)
    login_as(@user)
    @review_1 = Review.create(user: @user, order_item: @oi_4, title: 'title 1', description: 'description 1', rating: 1, username: 'username', item_name: 'item name')
    @review_2 = Review.create(user: @user, order_item: @oi_6, title: 'title 2', description: 'description 2', rating: 2, username: 'username', item_name: 'item name')
    @review_3 = Review.create(user: @user_2, order_item: @oi_8, title: 'title 3', description: 'description 3', rating: 3, username: 'username', item_name: 'item name')
  end
  context 'as a registered user' do
    it 'I can write a review for an item I have bought in a completed order' do
      click_link 'Orders'
      click_link "#{@completed_order_1.id}"

      within("div#oitem-#{@oi_3.id}") do
        click_link 'Review Item'
      end

      expect(current_path).to eq(new_order_item_review_path(@oi_3))

      fill_in :review_title, with: 'Sample Title'
      fill_in :review_description, with: 'Sample Description'
      fill_in :review_rating, with: 5
      click_button 'Create Review'

      expect(current_path).to eq(reviews_path(@user))

      expect(page).to have_content('Sample Title')
      expect(page).to have_content('Sample Description')
      expect(page).to have_content('Rating: 5/5')
    end

    it 'I cannot write a review for an item in a pending or cancelled order' do
      click_link 'Orders'
      click_link "#{@pending_order.id}"
      within("div#oitem-#{@oi_1.id}") do
        expect(page).to_not have_link('Review Item')
      end

      click_link 'Orders'
      click_link "#{@cancelled_order.id}"
      within("div#oitem-#{@oi_2.id}") do
        expect(page).to_not have_link('Review Item')
      end
    end

    it 'I can see all the reviews I have left for items on my review index page' do
      click_link 'Profile'
      click_link 'See All Reviews'

      within("div#review-#{@review_1.id}") do
        expect(page).to have_content(@review_1.title)
        expect(page).to have_content(@review_1.description)
        expect(page).to have_content("Rating: #{@review_1.rating}/5")
      end

      within("div#review-#{@review_2.id}") do
        expect(page).to have_content(@review_2.title)
        expect(page).to have_content(@review_2.description)
        expect(page).to have_content("Rating: #{@review_2.rating}/5")
      end

      expect(page).to_not have_content(@review_3.title)
      expect(page).to_not have_content(@review_3.description)
      expect(page).to_not have_content("Rating: #{@review_3.rating}")
    end

    it 'I am given an error message if I try to submit a review with invalid information' do
      click_link 'Orders'
      click_link "#{@completed_order_1.id}"
      within("div#oitem-#{@oi_3.id}") do
        click_link 'Review Item'
      end

      expect(current_path).to eq(new_order_item_review_path(@oi_3))
      fill_in :review_title, with: 'Title'
      fill_in :review_description, with: 'Description'
      fill_in :review_rating, with: 6
      click_button 'Create Review'

      expect(current_path).to eq(order_item_reviews_path(@oi_3))
      expect(page).to have_content('There are problems with the provided information.')
    end

    it 'I can edit a review I have already created' do
      click_link 'Profile'
      click_link 'See All Reviews'
      within("div#review-#{@review_1.id}") do
        click_link 'Edit Review'
      end

      fill_in :review_title, with: 'Edited Title'
      click_button 'Update Review'
    end
  end
end
