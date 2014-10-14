class AddRSysToProviders < ActiveRecord::Migration
  def up
  	add_column 	  	:providers, :r_sys, :integer, default: 2
  end

  def down
	remove_column 	:providers, :r_sys
  end
end
