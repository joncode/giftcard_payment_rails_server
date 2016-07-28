class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :abbr
      t.string :name
      t.string :detail
      t.string :photo
      t.boolean :active, default: true
      t.boolean :unique, default: true
      t.string :type_of
      t.string :sub_type
      t.float :latitude
      t.float :longitude
      t.float :min_latitude
      t.float :min_longitude
      t.float :max_latitude
      t.float :max_longitude
      t.float :xaxis
      t.float :yaxis
      t.float :zaxis
      t.string :ccy
      t.string :tz
      t.timestamps null: false
    end

    add_index :places, [:abbr, :type_of]
    add_index :places, :type_of
    add_index :places, :abbr
  end
end
