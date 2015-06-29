class AddCompanyToInvites < ActiveRecord::Migration

	def up

		rename_column :invites, :user_id, :mt_user_id
		rename_column :invites, :merchant_id, :company_id
		add_column 	  :invites, :company_type, :string
		set_company_type_to_merchant_for_all
  	end

	def down

		rename_column :invites, :mt_user_id, :user_id
		rename_column :invites, :company_id, :merchant_id
		remove_column :invites, :company_type, :string

  	end


	def set_company_type_to_merchant_for_all

		invites = Invite.unscoped.all
		invites.each {|i| i.update_column(:company_type, 'Merchant') }

  	end
end
