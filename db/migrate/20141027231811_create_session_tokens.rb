class CreateSessionTokens < ActiveRecord::Migration
  def up
    create_table :session_tokens do |t|
      t.string :token
      t.integer :user_id
      t.integer :device_id
      t.string :platform

      t.timestamps
    end
    add_index :session_tokens, :token
    move_token_from_user_to_session_tokens
  end

  def down
    drop_table :session_tokens
  end


  def move_token_from_user_to_session_tokens
    us = User.all
    us.each do |u|
       SessionToken.find_or_create_by(user_id: u.id, token: u.remember_token, platform: 'old')
    end
  end
end
