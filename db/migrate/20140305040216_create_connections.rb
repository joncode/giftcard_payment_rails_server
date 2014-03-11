class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.integer :friend_id
      t.integer :contact_id

      t.timestamps
    end

    add_index :connections, :friend_id
    add_index :connections, :contact_id
    add_index :connections, [:friend_id, :contact_id], unique: true

  end
end
