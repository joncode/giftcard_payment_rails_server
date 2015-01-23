class AddAffiliateIdToMtUsers < ActiveRecord::Migration
  def change
  	add_column :mt_users, :affiliate_id, :integer
  	add_index :mt_users, :affiliate_id
  end
end
