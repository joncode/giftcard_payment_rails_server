class DropAdminTokens < ActiveRecord::Migration
  def up
    drop_table :admin_tokens
  end

  def down
    create_table :admin_tokens do |t|
      t.string :token

      t.timestamps
    end

    add_index :admin_tokens, :token
  end
end
