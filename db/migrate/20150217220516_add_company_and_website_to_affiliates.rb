class AddCompanyAndWebsiteToAffiliates < ActiveRecord::Migration
  def change
  	add_column :affiliates, :company, :string
  	add_column :affiliates, :website_url, :string
  end
end
