class CreateProtos < ActiveRecord::Migration
  def change
    create_table :protos do |t|
      t.text :message
      t.text :detail
      t.text :shoppingCart
      t.string :value
      t.string :cost
      t.datetime :expires_at

      t.timestamps
    end
  end
end
