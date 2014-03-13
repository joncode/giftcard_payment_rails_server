class DropTableCityProviders < ActiveRecord::Migration
  def up
    drop_table :city_providers
  end
  def down
    create_table :city_providers do |t|
      t.string :city
      t.text :providers_array

      t.timestamps
    end
  end
end
