class AddDurationToBooks < ActiveRecord::Migration
  def change
    add_column :books, :duration, :integer, default: 120
  end
end
