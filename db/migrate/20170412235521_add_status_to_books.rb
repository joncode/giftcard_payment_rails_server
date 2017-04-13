class AddStatusToBooks < ActiveRecord::Migration
  def change
    add_column :books, :status, :string, default: :coming_soon
  end
end
