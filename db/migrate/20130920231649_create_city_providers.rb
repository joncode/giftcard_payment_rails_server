class CreateCityProviders < ActiveRecord::Migration
  def change
    create_table :city_providers do |t|
      t.string :city
      t.text :providers_array

      t.timestamps
    end
  end
end
