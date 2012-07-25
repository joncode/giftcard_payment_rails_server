class Order < ActiveRecord::Base
  attr_accessible :gift_id, :redeem_code, :redeem_id
  
  belongs_to  :provider
  belongs_to  :redeem
  belongs_to  :gift
end
