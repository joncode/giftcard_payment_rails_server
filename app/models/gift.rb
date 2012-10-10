# == Schema Information
#
# Table name: gifts
#
#  id                   :integer         not null, primary key
#  giver_name           :string(255)  !!!
#  receiver_name        :string(255)
#  provider_name        :string(255)
#  item_name            :string(255)
#  giver_id             :integer      !!!
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
#  status               :string(255)     default("open")
#  category             :string(255)
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  receiver_phone       :string(255)
#  tax                  :string(255)
#  tip                  :string(255)
#  regift_id           :integer
#  foursquare_id        :string(255)
#  facebook_id          :string(255)
#

class Gift < ActiveRecord::Base
  attr_accessible :credit_card, :giver_id, :item_id, :message, :price, :provider_id, :quantity, :receiver_id, :redeem_id, :special_instructions, :status, :total, :giver_name, :receiver_name, :receiver_name ,  :provider_name, :item_name , :category, :receiver_phone, :tip, :tax, :facebook_id, :foursquare_id, :regift_id, :anon_id
  
  has_one     :redeem
  belongs_to  :provider
  belongs_to  :item
  has_one     :order
  belongs_to  :giver,    class_name: "User"
  belongs_to  :receiver, class_name: "User"
  
  # add tax and tip when the iphone is ready 
  validates_presence_of :giver_id, :item_id, :price, :provider_id, :quantity, :total
  # validates_numericality_of  :total, :quantity
  
  before_create :add_category,    :if => :no_category
  before_create :pluralizer
  before_create :add_giver_name,  :if => :no_giver_name
  before_create :regifted,        :if => :regift_id?
  before_save   :set_status

  def self.get_gifts(user)
    Gift.where(receiver_id: user).where("status = :open OR status = :notified", :open => 'open', :notified => 'notified').order("created_at DESC")
  end

  def self.get_past_gifts(user)
    gifts = Gift.where( receiver_id: user).where(status: 'redeemed').order("created_at DESC")
  end

  def self.get_all_gifts(user)
    Gift.where( receiver_id: user).order("created_at DESC")
  end
  
  def self.get_all_gifts(user)
    Gift.where(receiver_id: user).order("created_at DESC")
  end
  
  def self.get_buy_history(user)
    gifts = Gift.where( giver_id: user).where("status = :open OR status = :notified", :open => 'open', :notified => 'notified').order("created_at DESC") 
    past_gifts = Gift.where( giver_id: user).where(status: 'redeemed').order("created_at DESC")
    return gifts, past_gifts
  end
  
  def self.get_buy_recents(user)
    Gift.where( giver_id: user).order("created_at DESC").limit(10)
  end
  
  def self.get_activity
    Gift.order("created_at DESC")
  end
  
  def self.get_user_activity(user)
    Gift.where("giver_id = :user OR receiver_id = :user", :user => user.id).order("created_at ASC")
  end
  
  def self.get_activity_at_provider(provider)
    Gift.where(provider_id: provider.id).order("created_at ASC")
  end
  
  def self.get_provider(provider)
    Gift.where(provider_id: provider.id).where("status = :open OR status = :notified", :open => 'open', :notified => 'notified').order("created_at DESC")
  end
  
  def self.get_all_orders(provider)
    Gift.where(provider_id: provider.id).order("updated_at DESC")
  end
  
  def self.get_history_provider(provider)
    Gift.where(provider_id: provider.id).where(status: 'redeemed').order("created_at DESC") 
  end

  def regift(receiver=nil, message=nil)
    new_gift            = self.dup
    new_gift.regift_id  = self.id
    new_gift.giver_id   = self.receiver_id
    new_gift.giver_name = self.receiver_name
    new_gift.message    = message 
    if receiver
      new_gift.add_receiver receiver
    else
      new_gift.receiver_id          = nil
      new_gift.receiver_name        = nil
      new_gift.receiver_phone       = nil
    end
    new_gift.foursquare_id          = nil
    new_gift.facebook_id            = nil
    new_gift.special_instructions   = nil    
    return new_gift
  end

  def add_receiver(receiver)
    self.receiver_id          = receiver.id
    self.receiver_name        = receiver.username
    if receiver.phone       
      self.receiver_phone     = receiver.phone 
    else
      self.receiver_phone     = nil
    end
  end

  def add_anonymous_giver(giver_id)
    anon_user       = User.find_by_phone('5555555555')
    self.giver_id   = anon_user.id
    self.giver_name = anon_user.username
    self.anon_id    = giver_id
  end
 
  private
    
    def set_status    
      if !self.receiver_id
        self.status =  "incomplete"
      end
    end
    
    def pluralizer
      if self.quantity > 1
        name_to_match = self.item_name
              # if item name already has a /'s/ then abort 
        if !name_to_match.match /'s/
           self.item_name << "\'s"
        end 
      end
    end
    
    def add_category
      self.category = self.item.category
    end
    
    def no_category
      self.category.nil?
    end

    def add_giver_name
      self.giver_name = User.find(self.giver_id).username
    end

    def no_giver_name
      self.giver_name.nil?
    end

    def regifted
      old_gift = Gift.find(self.regift_id)
      old_gift.update_attributes(status: 'regifted')
    end

    def regift_id?
      self.regift_id
    end    
end
