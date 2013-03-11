class AddPntokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pntoken, :string
  end
end
