class AddRSysSupportToRedemptions < ActiveRecord::Migration

	def up
		add_column :redemptions, :r_sys, :integer
		add_column :redemptions, :client_id, :integer
		add_column :redemptions, :token, :integer
		add_column :redemptions, :new_token_at, :datetime
		add_column :redemptions, :hex_id, :string
		add_column :redemptions, :active, :boolean, default: true
		add_index :redemptions, :hex_id
		add_index :redemptions, [:token, :status, :active]
		add_index :redemptions, [:gift_id, :status, :active]
		set_r_sys_and_client_id_columns
	end

	def down
			# columns get dropped indexes auto drop
		# remove_index :redemptions, :hex_id
		# remove_index :redemptions, [:token, :status, :active]
		# remove_index :redemptions, [:gift_id, :status, :active]
		remove_column :redemptions, :r_sys
		remove_column :redemptions, :client_id
		remove_column :redemptions, :token
		remove_column :redemptions, :new_token_at
		remove_column :redemptions, :hex_id
		remove_column :redemptions, :active
	end

	def set_r_sys_and_client_id_columns
		rs = Redemption.find_each do |redeem|
			client_id = nil
			gift = Gift.unscoped.find_by(id: redeem.gift_id) if redeem.gift_id.present?
			if gift
				client_id = gift.client_id
				client_id = gift.rec_client_id if gift.rec_client_id.present?
				redeem.token = gift.token
				redeem.new_token_at = gift.new_token_at
			end
			redeem.client_id = client_id
			redeem.r_sys = Redemption.convert_type_of_to_r_sys(redeem.type_of)
			if redeem.status == 'incomplete'
				redeem.status = 'pending'
			end
			redeem.set_unique_hex_id
			redeem.save
		end
	end
end
