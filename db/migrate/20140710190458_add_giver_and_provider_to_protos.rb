class AddGiverAndProviderToProtos < ActiveRecord::Migration
  def change
    add_column :protos, :giver_id, 		:integer
    add_column :protos, :giver_type, 	:string
    add_column :protos, :giver_name, 	:string
    add_column :protos, :provider_id, 	:integer
    add_column :protos, :provider_name, :string
    add_column :protos, :cat, 			:integer
  end
end
