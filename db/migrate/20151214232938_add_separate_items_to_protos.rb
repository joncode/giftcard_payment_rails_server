class AddSeparateItemsToProtos < ActiveRecord::Migration
	def change
		add_column :protos, :split, :boolean, default: false
	end
end
