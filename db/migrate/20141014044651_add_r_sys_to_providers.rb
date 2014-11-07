class AddRSysToProviders < ActiveRecord::Migration
  def up
  	add_column 	  	:providers, :r_sys, :integer, default: 2
  	set_r_sys
  end

  def down
	   remove_column 	:providers, :r_sys
  end

    def set_r_sys
        ps = Provider.all
        ps.each do |p|
            p.update_column(:r_sys, 1)
        end
        nil
    end
end
