class AddCanonicalIdToPnTokens < ActiveRecord::Migration
  def change
    add_column :pn_tokens, :canonical_id, :string
    add_column :pn_tokens, :device_id, :string
  end
end
