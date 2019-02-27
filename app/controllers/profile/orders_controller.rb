class Profile::OrdersController < ApplicationController
  before_action :user_or_admin

  def index
    @user = current_user
    @orders = Order.where(user: @user)
  end

  def create
    address = Address.find(params[:address_id])
    order = Order.create(user: current_user, address: address, status: :pending)
    @cart.items.each do |item|
      order.order_items.create!(
        item: item,
        price: item.price,
        quantity: @cart.count_of(item.id),
        fulfilled: false)
    end
    session[:cart] = nil

    flash[:success] = 'You have successfully checked out!'
    redirect_to profile_orders_path
  end

  def update
    order = Order.find(params[:id])
    address = Address.find(params[:address_id])
    order.update(address: address)
    flash[:success] = 'You have changed this order\'s shipping address.'
    redirect_to profile_order_path(order)
  end

  def show
    @order = Order.find(params[:id])
  end

  def destroy
    @order = Order.find(params[:id])

    @order.order_items.where(fulfilled: true).each do |oi|
      item = Item.find(oi.item_id)
      item.inventory += oi.quantity
      item.save
      oi.fulfilled = false
      oi.save
    end

    @order.status = :cancelled
    @order.save

    if current_reguser?
      redirect_to profile_orders_path
    elsif current_admin?
      redirect_to admin_user_orders_path(@order.user)
    end
  end
end
