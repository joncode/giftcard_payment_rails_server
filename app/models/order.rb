class Order < ActiveRecord::Base
  attr_accessible :gift_id, :redeem_code, :redeem_id
end
