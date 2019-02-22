class Review < ApplicationRecord
  validates_presence_of :title, :description, :rating, :username, :item_name
  validates :rating,
    presence: true,
    numericality: {
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 5,
      only_integer: true
  }
  belongs_to :user
  belongs_to :order_item
end
