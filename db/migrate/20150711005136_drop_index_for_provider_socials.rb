class DropIndexForProviderSocials < ActiveRecord::Migration
  def change

  	remove_index :providers_socials, [:provider_id, :social_id]
  	remove_index :providers_socials, [:merchant_id, :social_id]

  	add_index :providers_socials, [:merchant_id, :social_id], unique: true

  end
end
