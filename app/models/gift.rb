# == Schema Information
#
# Table name: gifts
#
#  id                   :integer         not null, primary key
#  giver_id             :integer
#  receiver_id          :integer
#  item_id              :integer
#  price                :string(20)
#  quantity             :integer         not null
#  total                :string(20)
#  credit_card          :string(100)
#  provider_id          :integer
#  message              :text
#  special_instructions :text
#  redeem_id            :integer
#  status               :string(255)
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#

class Gift < ActiveRecord::Base
  attr_accessible :credit_card, :giver_id, :item_id, :message, :price, :provider_id, :quantity, :receiver_id, :redeem_id, :special_instructions, :status, :total
  
  belongs_to  :user
  has_one     :redeem
  belongs_to  :provider
  belongs_to  :item
  
end
