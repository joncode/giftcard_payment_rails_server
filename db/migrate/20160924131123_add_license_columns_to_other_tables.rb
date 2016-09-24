class AddLicenseColumnsToOtherTables < ActiveRecord::Migration
	def up
		add_column :registers, :note, :string
		add_column :registers, :license_id, :uuid
		add_column :payments, :type_of, :string, default: 'payment'
		add_column :merchants, :live_at, :date
		set_live_at
  	end

  	def down
		remove_column :registers, :note
		remove_column :registers, :license_id
		remove_column :payments, :type_of
		remove_column :merchants, :live_at
  	end

  	def set_live_at
  		ms = Merchant.live_scope.each do |m|
  			if m.created_at < 14.days.ago
  				m.update_column(:live_at, (m.created_at.to_date + 14.days))
  			else
  				m.update_column(:live_at, m.updated_at.to_date)
  			end
  		end
  	end
end
