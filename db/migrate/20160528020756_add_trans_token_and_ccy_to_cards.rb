class AddTransTokenAndCcyToCards < ActiveRecord::Migration
	def change
		add_column :cards, :ccy, :string, default: "USD", limit: 6
		add_column :cards, :trans_token, :string
	end
end
