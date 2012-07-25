class Gift < ActiveRecord::Base
  attr_accessible :credit_card, :giver_id, :menu_item_id, :message, :price, :provider_id, :quantity, :receiver_id, :redeem_id, :special_instructions, :status, :total
end
