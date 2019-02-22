require 'rails_helper'

RSpec.describe Review, type: :model do
  describe 'validations' do
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
    it { should validate_presence_of :username }
    it { should validate_presence_of :item_name }
    it {should validate_numericality_of(:rating)
      .is_greater_than_or_equal_to(1)
      .is_less_than_or_equal_to(5)
      .only_integer
    }
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should belong_to :order_item }
  end

  describe 'class methods' do
    describe '.all_reviews(user)' do
      it 'returns all reviews for a given user' do
        user = create(:user)
        review_1 = Review.create(title: 'Title', description: 'Description', rating: 5, )
      end
    end
  end
end
