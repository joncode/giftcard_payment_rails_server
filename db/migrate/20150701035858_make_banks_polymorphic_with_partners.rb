class MakeBanksPolymorphicWithPartners < ActiveRecord::Migration

	class Bank < ActiveRecord::Base; end;

	def up
		add_column :banks, :owner_id, :integer
		add_column :banks,  :owner_type, :string
		add_column :affiliates,  :bank_id, :integer
		add_column :merchants,  :bank_id, :integer
		set_owner_type
	end

	def down
		remove_column :banks, :owner_id
		remove_column :banks,  :owner_type
		remove_column :affiliates,  :bank_id
		remove_column :merchants,  :bank_id
	end

	def set_owner_type
		Bank.all.each  do |b|
			b.update(owner_type: 'Merchant', owner_id: b.merchant_id)
			m = Merchant.find(b.merchant_id)
			m.update(bank_id: b.id)
		end
	end

end
