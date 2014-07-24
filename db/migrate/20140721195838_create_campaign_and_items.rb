class CreateCampaignAndItems < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
    	t.string :type_of
    	t.string :status
    	t.string :name
    	t.text :notes
    	t.date :live_date
    	t.date :close_date
    	t.date :expire_date
    	t.integer :purchaser_id
    	t.string :purchaser_type
    	t.string :giver_name
    	t.string :photo
    	t.integer :budget
    	t.timestamps
    	t.string :photo_path
    end

    create_table :campaign_items do |t|
    	t.integer :campaign_id
    	t.integer :provider_id
    	t.integer :giver_id
    	t.string :giver_name
    	t.integer :budget
    	t.integer :reserve
    	t.text :message
    	t.text :shoppingCart
    	t.string :value
    	t.string :cost
    	t.date :expires_at
    	t.integer :expires_in
    	t.string :textword
    	t.boolean :contract
    	t.timestamps
    	t.text :detail
    end

  end
end
