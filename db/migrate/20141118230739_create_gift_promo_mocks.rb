class CreateGiftPromoMocks < ActiveRecord::Migration
  def change
    create_table :gift_promo_mocks do |t|
	    t.string   :type_of
	    t.string   :receiver_name
	    t.datetime :expires_at
	    t.text     :message
	    t.text     :shoppingCart
	    t.text     :detail
	    t.timestamps
    end
  end
end
