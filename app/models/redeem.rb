class Redeem < ActiveRecord::Base
  attr_accessible :gift_id, :redeem_code, :reply_message
end
