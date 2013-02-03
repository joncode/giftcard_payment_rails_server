class Gift < ActiveRecord::Base

  attr_accessible   :giver_id,      :giver_name, :credit_card,    
      :receiver_id, :receiver_name, :receiver_phone, 
      :provider_id, :provider_name, :receiver_email, 
      :message,     :special_instructions,
      :shoppingCart,
      :category,  :price, :item_id, :item_name ,  
      :tip, :tax,   :total, 
      :facebook_id, :foursquare_id,
      :redeem_id,   :status, :regift_id, :anon_id
# to be removed from db via migration
# :category, :price, :item_id, :item_name, :special_instructions. :redeem_id
  
  has_one     :redeem, dependent: :destroy
  has_one     :relay,  dependent: :destroy
  belongs_to  :provider
  belongs_to  :sales
  has_one     :order, dependent: :destroy
  has_many    :gift_items
  belongs_to  :giver,    class_name: "User"
  belongs_to  :receiver, class_name: "User"
  
  validates_presence_of :giver_id, :receiver_name, :provider_id, :total, :tip
  # validates_numericality_of  :total, :tip, :tax
  
  #before_create :add_category, :if => :no_category
  #before_create :pluralizer
  before_create :extract_phone_digits
  before_create :add_giver_name,  :if => :no_giver_name
  before_create :regifted,        :if => :regift_id?
  before_save   :set_status
  after_create  :update_shoppingCart
  after_update  :create_notification

  ##########   database queries

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
    Gift.where("giver_id = :user OR receiver_id = :user", :user => user.id).order("created_at DESC")
  end
  
  def self.get_activity_at_provider(provider)
    Gift.where(provider_id: provider.id).order("created_at ASC")
  end
  
  def self.get_provider(provider)
    Gift.where(provider_id: provider.id).where("status = :open OR status = :notified", :open => 'open', :notified => 'notified').order("created_at DESC")
  end
  
  def self.get_all_orders(provider)
    Gift.where(provider_id: provider.id).where("status != :stat ", :stat => 'incomplete').order("updated_at DESC")
  end
  
  def self.get_history_provider(provider)
    Gift.where(provider_id: provider.id).where(status: 'redeemed').order("created_at DESC") 
  end

  def self.transactions(user)
    gifts_raw = Gift.where(giver_id: user.id).order("created_at DESC") 
    gifts = []
    gifts_raw.each do |g|
      gift_hash = g.serializable_hash only: [ :provider_name, :total, :receiver_name]
      gift_hash["gift_id"] = g.id
      gift_hash["created_at"] = g.created_at.to_date.inspect
      gifts << gift_hash
    end
    return gifts
  end

  ##########  gift creation methods

  def self.init(params)
    gift = Gift.new(params[:gift])
        # add anonymous giver feature
    if params[:gift][:anon_id] 
      gift.add_anonymous_giver(params[:gift][:giver_id])
    end
    return gift
  end

  def regift(receiver=nil, message=nil)
    new_gift            = self.dup
    new_gift.regift_id  = self.id
    new_gift.add_giver receiver
    new_gift.message    = message 
    if receiver
      new_gift.add_receiver receiver
    else
      new_gift.receiver_id          = nil
      new_gift.receiver_name        = nil
      new_gift.receiver_phone       = nil
      new_gift.foursquare_id        = nil
      new_gift.facebook_id          = nil
    end
    new_gift.special_instructions   = nil    
    return new_gift
  end

  def add_receiver(receiver)
    self.receiver_id    = receiver.id
    self.receiver_name  = receiver.fullname  
    self.facebook_id    = receiver.facebook_id ? receiver.facebook_id : nil   
    self.receiver_phone = receiver.phone ? receiver.phone : nil
    self.receiver_email = receiver.email ? receiver.email : nil
    self.status = 'open' if self.status == "incomplete"
  end

  def add_giver(giver)
    self.giver_id   = giver.id
    self.giver_name = giver.fullname
  end

  def add_provider(provider)
    self.provider_id     = provider.id
    self.provider_name   = provider.name    
  end

  def add_anonymous_giver(giver_id)
    anon_user       = User.find_by_phone('5555555555')
    self.add_giver anon_user
    self.anon_id    = giver_id
  end
 
  private

    def create_notification
      puts "the gift status is #{self.status}"
      case self.status
      when 'incomplete'
        puts "Relay created for gift #{self.id}"
        Relay.createRelayFromGift self
      when 'open'
        puts "Relay created for gift if there is none #{self.id}"
        relay = Relay.createRelayFromGift self
        if relay.errors.messages.has_key? :gift_id
          relay = Relay.updateRelayFromGift self
        end 
      when 'notified'
        puts "Relay updated to notified for gift #{self.id}"
        relay = Relay.updateRelayFromGift self
      when 'redeemed'
        puts "Relay updated to redeemed for gift #{self.id}"
        relay = Relay.updateRelayFromGift self
      when 'regifted'
        puts "Relay updated to regifted for gift #{self.id}"
        relay = Relay.updateRelayFromGift self
      end
    end

    def update_shoppingCart
      updated_shoppingCart_array = []
      self.gift_items.each do |item|
        item_hash = item.prepare_for_shoppingCart
        updated_shoppingCart_array << item_hash
      end
      puts "GIFT AFTER SAVE UPDATING SHOPPNG CART = #{updated_shoppingCart_array}"
      self.update_attribute(:shoppingCart, updated_shoppingCart_array.to_json)
    end

    def extract_phone_digits
      if self.receiver_phone && !self.receiver_phone.empty?
        phone_match         = self.receiver_phone.match(VALID_PHONE_REGEX)
        self.receiver_phone = phone_match[1] + phone_match[2] + phone_match[3]
      end
    end

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
# == Schema Information
#
# Table name: gifts
#
#  id                   :integer         not null, primary key
#  giver_name           :string(255)
#  receiver_name        :string(255)
#  provider_name        :string(255)
#  item_name            :string(255)
#  giver_id             :integer
#  receiver_id          :integer
#  item_id              :integer
#  price                :string(20)
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
#  regift_id            :integer
#  foursquare_id        :string(255)
#  facebook_id          :string(255)
#  anon_id              :integer
#  sale_id              :integer
#  receiver_email       :string(255)
#  shoppingCart         :text
#

