class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :name
      t.string :description
      t.string :address
      t.string :city
      t.string :state
      t.string :phone
      t.string :website
      t.string :logo
      t.string :banner
      t.string :portrait
      t.integer :user_id

      t.timestamps
    end
  end
end
