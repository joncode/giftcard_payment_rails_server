class CreateRedeems < ActiveRecord::Migration
  def change
    create_table :redeems do |t|
      t.integer :gift_id
      t.string  :reply_message
      t.integer :redeem_code
      t.text    :special_instructions
      t.timestamps
    end
  end
end
