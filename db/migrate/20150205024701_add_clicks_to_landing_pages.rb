class AddClicksToLandingPages < ActiveRecord::Migration
  def change
    add_column :landing_pages, :clicks, :integer, default: 0
    add_column :landing_pages, :users, :integer, default: 0
    add_column :landing_pages, :gifts, :integer, default: 0
  end
end
