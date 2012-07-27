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
  attr_accessible :credit_card, :giver_id, :item_id, :message, :price, :provider_id, :quantity, :receiver_id, :redeem_id, :special_instructions, :status, :total, :giver_name, :receiver_name, :receiver_name ,  :provider_name, :item_name 
  
  belongs_to  :user
  has_one     :redeem
  belongs_to  :provider
  belongs_to  :item
  has_many    :orders
  
  def self.get_gifts(user)
    gifts = Gift.where( receiver_id: user).where(status: 'open').order("created_at DESC")
    gifts.concat Gift.where( receiver_id: user).where(status: 'notified').order("created_at DESC")
    gifts.concat Gift.where( receiver_id: user).where(status: 'redeemed').order("created_at DESC")
  end
  
  def self.get_buy_history(user)
    gifts = Gift.where( giver_id: user).where(status: 'open').order("created_at DESC")
    gifts.concat Gift.where( giver_id: user).where(status: 'notified').order("created_at DESC")
    gifts.concat Gift.where( giver_id: user).where(status: 'redeemed').order("created_at DESC")
  end
  
  def self.get_activity
    gifts = Gift.where(status: 'open').order("created_at DESC")
    gifts.concat Gift.where(status: 'notified').order("created_at DESC")
    gifts.concat Gift.where(status: 'redeemed').order("created_at DESC") 
  end
  
  def self.get_provider(provider)
    gifts = Gift.where(provider_id: provider.id).where(status: 'open').order("created_at DESC")
    gifts.concat Gift.where(provider_id: provider.id).where(status: 'notified').order("created_at DESC")
    gifts.concat Gift.where(provider_id: provider.id).where(status: 'redeemed').order("created_at DESC") 
  end
  
  def convert_date
    created_at.time_ago_in_words
  end
    
end
