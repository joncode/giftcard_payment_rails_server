class AddAddressToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :vendor_id,      :string
    add_column :locations, :vendor_type,    :string
    add_column :locations, :name,           :string
    add_column :locations, :street,         :string
    add_column :locations, :city,           :string
    add_column :locations, :state,          :string
    add_column :locations, :country,        :string
    add_column :locations, :zip,            :string
    add_column :locations, :checkin_id,     :string
  end
end
