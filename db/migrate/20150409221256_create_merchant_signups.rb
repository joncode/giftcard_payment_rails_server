class CreateMerchantSignups < ActiveRecord::Migration
  def change
    create_table :merchant_signups do |t|
      t.string :name
      t.string :position
      t.string :email
      t.string :phone
      t.string :website
      t.string :venue_name
      t.string :venue_url
      t.string :point_of_sale_system
      t.string :message

      t.timestamps
    end
  end
end
