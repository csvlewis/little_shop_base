class Address < ApplicationRecord
  validates_presence_of :nickname, :street, :city, :state, :zip

  belongs_to :user
  has_many :orders

  def deletable?
    orders.empty?
  end

  def editable?
    orders.none? do |order|
      order.completed?
    end
  end
end
