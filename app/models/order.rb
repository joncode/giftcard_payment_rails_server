class Order < ActiveRecord::Base
  attr_accessible :gift_id, :redeem_code, :redeem_id
  
  belongs_to :provider
  has_one    :redeem
  has_one    :gift
end
