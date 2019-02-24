class Order < ApplicationRecord
  enum status: [:pending, :completed, :cancelled]

  belongs_to :user
  belongs_to :address
  has_many :order_items
  has_many :items, through: :order_items

  validates_presence_of :status

  def total_item_count
    order_items.sum(:quantity)
  end

  def total_cost
    oi = order_items.pluck("sum(quantity*price)")
    oi.sum
  end

  def self.sorted_by_items_shipped(limit = nil)
    self.joins(:order_items)
        .select('orders.*, sum(order_items.quantity) as quantity')
        .where(status: 1, order_items: {fulfilled: true})
        .group(:id)
        .order('quantity desc')
        .limit(limit)
  end

  def total_quantity_for_merchant(merchant_id)
    items.where('merchant_id = ?', merchant_id)
         .joins(:order_items).select('items.id, order_items.quantity')
         .distinct
         .sum('order_items.quantity')
  end

  def total_price_for_merchant(merchant_id)
    items.where('merchant_id = ?', merchant_id)
         .joins(:order_items).select('items.id, order_items.quantity, order_items.price')
         .distinct
         .sum('order_items.quantity*order_items.price')
  end

  def self.pending_orders_for_merchant(merchant_id)
    self.where(status: 0)
        .where(items: {merchant_id: merchant_id})
        .joins(:items)
        .distinct
  end

  def order_items_for_merchant(merchant_id)
    order_items.joins('join items on items.id = order_items.item_id')
               .where(items: {merchant_id: merchant_id})
  end
end
