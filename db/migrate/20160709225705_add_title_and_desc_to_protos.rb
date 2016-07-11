class AddTitleAndDescToProtos < ActiveRecord::Migration
	def change
		add_column :protos, :title, :string
		add_column :protos, :desc, :string
  	end
end
