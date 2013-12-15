class AddExpiresAtToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :expires_at, :datetime
  end
end
