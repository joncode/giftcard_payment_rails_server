class CreateSessionTokens < ActiveRecord::Migration
  def change
    create_table :session_tokens do |t|
      t.string :token
      t.integer :user_id
      t.integer :device_id
      t.string :platform

      t.timestamps
    end
    add_index :session_tokens, :token
  end
end
