class AddRSysSupportToRedemptions < ActiveRecord::Migration

	def up
		add_column :redemptions, :r_sys, :integer
		add_column :redemptions, :client_id, :integer
		add_column :redemptions, :token, :integer
		add_column :redemptions, :new_token_at, :datetime
		add_column :redemptions, :hex_id, :string
		add_column :redemptions, :active, :boolean, default: true
		set_r_sys_column
	end

	def down
		remove_column :redemptions, :r_sys
		remove_column :redemptions, :client_id
		remove_column :redemptions, :token
		remove_column :redemptions, :new_token_at
		remove_column :redemptions, :hex_id
		remove_column :redemptions, :active
	end

	add_index :redemptions, [:hex_id]
	add_index :redemptions, [:token, :status, :active]

	def set_r_sys_column
		rs = Redemption.find_each do |redeem|
			r_sys = Redemption.convert_type_of_to_r_sys(redeem.type_of)
			redeem.update(r_sys: r_sys)
		end
	end
end
