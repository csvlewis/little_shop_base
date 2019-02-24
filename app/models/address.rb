class Address < ApplicationRecord
  validates_presence_of :nickname, :street, :city, :state, :zip

  belongs_to :user
  has_many :orders

  def deletable?
    orders.none? do |order|
      order.status == 'completed'
    end
  end
end
