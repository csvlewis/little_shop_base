class CreateReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :reviews do |t|
      t.references :user, foreign_key: true
      t.references :order_item, foreign_key: true

      t.string :title
      t.text :description
      t.integer :rating
      t.string :username
      t.string :item_name

      t.timestamps
    end
  end
end
