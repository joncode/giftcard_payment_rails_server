class Redeem < ActiveRecord::Base
  attr_accessible :gift_id, :redeem_code, :reply_message
  
  has_one     :user
  has_one     :gift
end
