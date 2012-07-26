# == Schema Information
#
# Table name: redeems
#
#  id            :integer         not null, primary key
#  gift_id       :integer
#  reply_message :string(255)
#  redeem_code   :integer
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

class Redeem < ActiveRecord::Base
  attr_accessible :gift_id, :redeem_code, :reply_message, :special_instructions
  
  belongs_to     :gift
  has_one        :order
  
end
