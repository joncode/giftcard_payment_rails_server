class AddPosParamsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :pos_merchant_id, :integer
    add_column :orders, :ticket_value,    :string
    add_column :orders, :ticket_item_ids, :string
  end
end
