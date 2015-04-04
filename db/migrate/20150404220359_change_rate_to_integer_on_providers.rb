class ChangeRateToIntegerOnProviders < ActiveRecord::Migration
  def up
    # leaving the rate as big decimal, but adding default
  	change_column :providers, :rate, :decimal, default: 85
    change_column :merchants, :rate, :decimal, default: 85
  	set_providers_to_default
  end

  def down
  	# no reason to down migrate, column was unused
  end

  def set_providers_to_default
  	ps = Provider.all
    ms = Merchant.all
    pms_ary = ps + ms
  	pms_ary.each do |p|
      if p.rate.nil? || p.rate == 0
        p.update(rate: 85)
      end
    end
  end
end
