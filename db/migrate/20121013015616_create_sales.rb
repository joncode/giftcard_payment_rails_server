class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.integer :gift_id
      t.integer :giver_id
      t.integer :card_id
      t.string  :request_string
      t.string  :response_string
      t.string  :status
      t.integer :provider_id
      t.string  :transaction_id
      t.decimal :revenue
      t.timestamps
    end
  end
end
