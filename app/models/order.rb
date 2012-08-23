# == Schema Information
#
# Table name: orders
#
#  id          :integer         not null, primary key
#  redeem_id   :integer
#  gift_id     :integer
#  redeem_code :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Order < ActiveRecord::Base
  attr_accessible :gift_id, :redeem_code, :redeem_id
  
  belongs_to  :provider
  belongs_to  :redeem
  belongs_to  :gift
  
  validates_presence_of :gift_id, :redeem_code, :redeem_id
end
