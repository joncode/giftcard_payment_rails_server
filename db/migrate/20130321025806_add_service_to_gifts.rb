class AddServiceToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :service, :string
  end
end
