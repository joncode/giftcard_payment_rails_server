class AddConfirmToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirm, :string, :default => "00"
  end
end
