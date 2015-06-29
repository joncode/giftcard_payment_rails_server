class AddAffiliateIdToInvites < ActiveRecord::Migration
	def up
		remove_column :invites, :code
		remove_column :invites, :merchant_tkn
	end

	def down
		add_column :invites, :code, :string
		add_column :invites, :merchant_tkn, :string
	end
end
