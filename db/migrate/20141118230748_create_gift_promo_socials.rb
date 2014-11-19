class CreateGiftPromoSocials < ActiveRecord::Migration
  def change
    create_table :gift_promo_socials do |t|
	    t.integer  :gift_promo_mock_id
	    t.string   :network
	    t.string   :network_id
	    t.timestamps
    end
  end
end
