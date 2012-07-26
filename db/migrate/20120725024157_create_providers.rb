class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string  :name
      t.string  :description
      t.string  :address
      t.string  :address_2
      t.string  :city
      t.string  :state
      t.integer :zip
      t.integer :user_id
      t.string  :logo

      t.timestamps
    end
  end
end
