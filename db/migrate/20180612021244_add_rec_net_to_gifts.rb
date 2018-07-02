class AddRecNetToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :rec_net, :string, limit: 2
  end
end
