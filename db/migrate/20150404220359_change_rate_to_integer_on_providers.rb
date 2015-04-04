class ChangeRateToIntegerOnProviders < ActiveRecord::Migration
  def up
  	change_column :providers, :rate, :integer, default: 85
  	set_providers_to_default
  end

  def down
  	# no reason to down migrate, column was unused
  end

  def set_providers_to_default
  	ps = Provider.all
  	ps.each {|p| p.update(rate: 85)}
  end
end
