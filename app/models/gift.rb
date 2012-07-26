class Gift < ActiveRecord::Base
  attr_accessible :credit_card, :giver_id, :item_id, :message, :price, :provider_id, :quantity, :receiver_id, :redeem_id, :special_instructions, :status, :total
  
  belongs_to  :user
  has_one     :redeem
  belongs_to  :provider
  belongs_to  :item
  
end
