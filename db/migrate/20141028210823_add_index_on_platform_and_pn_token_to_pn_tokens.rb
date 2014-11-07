class AddIndexOnPlatformAndPnTokenToPnTokens < ActiveRecord::Migration
  def change
  	add_index :pn_tokens, [:platform, :pn_token]
  end
end
