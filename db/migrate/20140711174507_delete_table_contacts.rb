class DeleteTableContacts < ActiveRecord::Migration
  def up
    drop_table :contacts
  end

  def down
    # do nothing
  end
end
