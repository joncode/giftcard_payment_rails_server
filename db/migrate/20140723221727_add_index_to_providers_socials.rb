class AddIndexToProvidersSocials < ActiveRecord::Migration
  def change

      	add_index :providers_socials, [:provider_id, :social_id], unique: true

  end
end
