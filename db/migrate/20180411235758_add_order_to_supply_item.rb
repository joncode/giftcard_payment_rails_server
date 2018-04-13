class AddOrderToSupplyItem < ActiveRecord::Migration
  def change
    add_column :supply_items, :order, :integer

    SupplyItem.all.order(created_at: :asc).each.with_index do |item, index|
        item.order = index
        item.save
    end
  end
end
