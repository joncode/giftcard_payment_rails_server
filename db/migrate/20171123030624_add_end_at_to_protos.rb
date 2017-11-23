class AddEndAtToProtos < ActiveRecord::Migration
  def change
  	add_column :protos, :end_at, :datetime
  end
end
