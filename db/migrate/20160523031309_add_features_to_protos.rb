class AddFeaturesToProtos < ActiveRecord::Migration
	include MoneyHelper

	def change
		add_column :protos, :ccy, :string, default: "USD", limit: 6
		add_column :protos, :quick, :boolean, default: false
		add_column :protos, :expires_in, :integer

		add_column :protos, :value_cents, :integer
		add_column :protos, :cost_cents, :integer

		move_value_and_cost_to_cents
	end

	def move_value_and_cost_to_cents
		Proto.find_each do |proto|
			proto.value_cents = currency_to_cents(proto.value)
			proto.cost_cents = currency_to_cents(proto.cost)

			proto.save
		end
	end

end
