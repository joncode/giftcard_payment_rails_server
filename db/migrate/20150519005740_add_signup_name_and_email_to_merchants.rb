class AddSignupNameAndEmailToMerchants < ActiveRecord::Migration
  def change
  	add_column :merchants, :signup_email, :string
  	add_column :merchants, :signup_name, :string
  end
end
