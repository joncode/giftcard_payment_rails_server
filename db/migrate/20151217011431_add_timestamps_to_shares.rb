class AddTimestampsToShares < ActiveRecord::Migration
  def change
  	add_timestamps(:shares)
  end
end
