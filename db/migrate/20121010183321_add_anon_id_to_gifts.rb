class AddAnonIdToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :anon_id, :integer
  end
end
