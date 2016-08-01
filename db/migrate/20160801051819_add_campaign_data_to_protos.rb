class AddCampaignDataToProtos < ActiveRecord::Migration
  def change
    add_column :protos, :camp, :boolean, default: false
    add_column :protos, :active, :boolean, default: true
    add_column :protos, :live, :boolean, default: true
    add_column :protos, :delivery, :string
    add_column :protos, :promo_code, :string
    add_column :protos, :maximum, :integer
    add_column :protos, :start_in, :integer
  end
end
