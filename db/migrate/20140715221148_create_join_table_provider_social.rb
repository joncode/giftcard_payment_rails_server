class CreateJoinTableProviderSocial < ActiveRecord::Migration
  def change
    create_join_table :providers, :socials do |t|
      t.index :provider_id
    end
  end
end
