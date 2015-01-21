class AddAffiliateToUsersAndMerchants < ActiveRecord::Migration
  def change
  	add_column :users, :affiliate_url_name, :string
  	add_column :merchants, :affiliate_id, :integer
  end
end
