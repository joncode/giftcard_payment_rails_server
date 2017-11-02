class CreateSupplyOrders < ActiveRecord::Migration
  def change
    create_table :supply_orders do |t|
      t.string :hex_id
      t.integer :price
      t.string :ccy, default: 'USD'
      t.json :form_data
      t.string :status, default: 'open'
      t.string :pay_stat, default: 'due'
      t.datetime :delivered_at
      t.boolean :active, default: true

      t.timestamps null: false
    end
  end
end
