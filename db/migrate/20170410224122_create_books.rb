class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.boolean :active, default: true
      t.string :name
      t.string :zinger
      t.text :detail
      t.text :notes
      t.json :members
      t.json :photos
      t.integer :advance_days
      t.integer :min_ppl
      t.integer :max_ppl
      t.string :ccy
      t.integer :price
      t.integer :price_wine

      t.timestamps null: false
    end
  end
end
