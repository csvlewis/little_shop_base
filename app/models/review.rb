class Review < ApplicationRecord
  validates_presence_of :title, :description, :rating, :username, :item_name
  belongs_to :user
  belongs_to :order_item
end
