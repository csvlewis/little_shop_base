require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of :quantity }
    it { should validate_numericality_of(:quantity).only_integer }
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }
  end

  describe 'relationships' do
    it { should belong_to :order }
    it { should belong_to :item }
    it { should have_many :reviews}
  end

  describe 'instance methods' do
    it '.subtotal' do
      address = Address.create(nickname: 'Home', street: 'street', city: 'Fairfield', state: 'CO', zip: 1)
      order = create(:order, address: address)
      oi = create(:order_item, order: order, quantity: 5, price: 3)

      expect(oi.subtotal).to eq(15)
    end

    it 'inventory_available' do
      address = Address.create(nickname: 'Home', street: 'street', city: 'Fairfield', state: 'CO', zip: 1)
      order = create(:order, address: address)
      item = create(:item, inventory:2)
      oi1 = create(:order_item, order: order, quantity: 1, item: item)
      oi2 = create(:order_item, order: order, quantity: 2, item: item)
      oi3 = create(:order_item, order: order, quantity: 3, item: item)

      expect(oi1.inventory_available).to eq(true)
      expect(oi2.inventory_available).to eq(true)
      expect(oi3.inventory_available).to eq(false)
    end

    it '.fulfill' do
      address = Address.create(nickname: 'Home', street: 'street', city: 'Fairfield', state: 'CO', zip: 1)
      order = create(:order, address: address)
      item = create(:item, inventory:2)
      oi1 = create(:order_item, order: order, quantity: 1, item: item)
      oi2 = create(:order_item, order: order, quantity: 1, item: item)
      oi3 = create(:order_item, order: order, quantity: 1, item: item)

      oi1.fulfill

      expect(oi1.fulfilled).to eq(true)
      expect(item.inventory).to eq(1)

      oi2.fulfill

      expect(oi1.fulfilled).to eq(true)
      expect(item.inventory).to eq(0)

      oi2.fulfill

      expect(oi2.fulfilled).to eq(true)
      expect(item.inventory).to eq(0)

      oi3.fulfill

      expect(oi2.fulfilled).to eq(true)
      expect(item.inventory).to eq(0)
    end

    describe '.reviewable?' do
      it 'returns true if an orderitem is fulfilled and is part of a completed order' do
        pending = create(:order)
        cancelled = create(:cancelled_order)
        completed = create(:completed_order)
        oi_1 = create(:order_item, order: pending)
        oi_2 = create(:fulfilled_order_item, order: pending)
        oi_3 = create(:order_item, order: cancelled)
        oi_4 = create(:fulfilled_order_item, order: cancelled)
        oi_5 = create(:fulfilled_order_item, order: completed)
        oi_6 = create(:fulfilled_order_item, order: completed)

        expect(oi_1.reviewable?).to eq(false)
        expect(oi_2.reviewable?).to eq(false)
        expect(oi_3.reviewable?).to eq(false)
        expect(oi_4.reviewable?).to eq(false)
        expect(oi_5.reviewable?).to eq(true)
        expect(oi_6.reviewable?).to eq(true)
      end
    end
  end
end
