class AddAffiliateIdToInvites < ActiveRecord::Migration
	def up
		add_column :invites, :affiliate_id, :integer
		remove_column :invites, :code
		remove_column :invites, :merchant_tkn
	end

	def down
		remove_column :invites, :affiliate_id
		add_column :invites, :code, :string
		add_column :invites, :merchant_tkn, :string
	end
end
