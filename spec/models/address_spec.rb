require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'validations' do
    it { should validate_presence_of :nickname }
    it { should validate_presence_of :street }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
  end

  describe 'relationships' do
    it { should have_many :orders}
    it { should belong_to :user}
  end

  describe 'instance methods' do
    describe '.deletable?' do
      it 'returns false if the address has been used in a completed order' do
        user = create(:user)
        a1 = Address.create(user: user, nickname: 'nickname', street: 'street', state: 'state', city: 'city', zip: 1)
        a2 = Address.create(user: user, nickname: 'nickname', street: 'street', state: 'state', city: 'city', zip: 1)
        a3 = Address.create(user: user, nickname: 'nickname', street: 'street', state: 'state', city: 'city', zip: 1)
        a4 = Address.create(user: user, nickname: 'nickname', street: 'street', state: 'state', city: 'city', zip: 1)
        create(:order, address: a2)
        create(:cancelled_order, address: a3)
        create(:completed_order, address: a4)

        expect(a1.deletable?).to eq(true)
        expect(a2.deletable?).to eq(true)
        expect(a3.deletable?).to eq(true)
        expect(a4.deletable?).to eq(false)
      end
    end
  end
end
