class Gift < ActiveRecord::Base

  attr_accessible   :giver_id,      :giver_name, :credit_card,    
      :receiver_id, :receiver_name, :receiver_phone, 
      :provider_id, :provider_name, :receiver_email, 
      :message,     :shoppingCart, 
      :tip, :tax,   :total, :service,
      :facebook_id, :foursquare_id, :twitter,
      :status
      # should be removed from accessible = giver_id, giver_name, shoppingCart, status
      
      # from the app on create gift
# \"receiver_email\" \"facebook_id\"\"tax\"  \"receiver_phone\"  \"giver_name\" 
# \"receiver_id\"  \"total\"  \"provider_id\"  \"tip\"  \"service\"  \"message\"  
# \"credit_card\"  \"provider_name\"  \"receiver_name\"  \"giver_id\"  "origin"=>"d"
# "shoppingCart"=>"[{\"price\":\"10\",\"quantity\":1,\"item_id\":920,\"item_name\":\"Fireman's Special\"},{\"price\":\"10\",\"quantity\":1,\"item_id\":901,\"item_name\":\"Corona\"},{\"price\":\"10\",\"quantity\":1,\"item_id\":902,\"item_name\":\"Budwesier\"}]",
# "token"=>"LlWODlRC9M3VDbzPHuWMdA"}

  has_one     :redeem, dependent: :destroy
  has_one     :relay,  dependent: :destroy
  belongs_to  :provider
  has_many    :sales
  has_one     :order, dependent: :destroy
  has_many    :gift_items, dependent: :destroy
  belongs_to  :giver,    class_name: "User"
  belongs_to  :receiver, class_name: "User"

  validates_presence_of :giver_id, :receiver_name, :provider_id, :total, :tip, :credit_card

  before_create :extract_phone_digits
  before_create :add_giver_name,  :if => :no_giver_name
  before_create :regifted,        :if => :regift_id?
  before_create :set_status
 
  after_create  :update_shoppingCart
  after_create  :invoice_giver
  after_create  :notify_receiver
  after_save    :create_notification

  ##########   database queries

  def self.get_gifts(user)
    Gift.where(receiver_id: user.id).where("status = :open OR status = :notified", :open => 'open', :notified => 'notified').order("created_at DESC")
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
    Gift.where(provider_id: provider.id).where("status != :stat OR status != :other", :stat => 'incomplete', :other => 'unpaid').order("updated_at DESC")
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

  def set_status 
    if self.card_enabled?
        self.status = "unpaid"
    else   
        if self.receiver_id.nil?
            self.status = "incomplete"
        else
            self.status = 'open'
        end
    end
    puts "gift SET STATUS #{self.status}"
  end

  def card_enabled?
    whitelist = ["test@test.com", "deb@knead4health.com", "dfennell@graywolves.com", "dfennell@webteampros.com"]
    if whitelist.include?(self.giver.email)
        return true
    else
        return false
    end
  end

  def charge_card
        # if giver is one jb@jb.com
        # call authorize capture on the gift and create the sale object
    if self.card_enabled?
        sale = self.authorize_capture
        puts "SALE ! #{sale.req_json} #{sale.transaction_id} #{sale.revenue.to_f} == #{self.total}"
    else
        sale = Sale.new
        sale.resp_code = 1
    end
        # otherwise return a sale object with resp_code == 1
    return sale
  end

  def authorize_capture
    puts "BEGIN AUTH CAPTURE for GIFT ID #{self.id}"
      # Authorize Transaction Method
    # A - create a sale object that stores the record of the auth.net transaction    
    sale     = Sale.init self
    response = sale.auth_capture
    
    # B - authorize transaction via auth.net
      # -- returns data --
        # 1 success
          # go ahead and savre the gift - process complete
        # failure
          # credit card issues
            # card expired
            # insufficient funds
            # card is blocked
          # auth.net issues
            # cannot connect to server 
            # no response from server
            # transaction key is no longer good
          # sale db issues
            # could not save item
    case response.response_code.to_i
    when 1
      # Approved
      puts "setting the gift status off unpaid"
     self.set_status 
    when 2
      # Declined 
    when 3
      # Error 
      # duplicate transaction response subcode = 1
    when 4 
      # Held for Review
    else
      # not a listed error code
      puts "UNKNOWN ERROR CODE RECEIVED FOR AUTH.NET - CODE = #{response.response_code}"
      puts "TEXT IS #{response.response_reason_text} for GIFT ID = #{self.id}"
    end
    reply = response.response_reason_text
    puts "HERE IS THE REPLY #{reply}"
    # C - saves the sale object into the sale db
    sale.save
    puts "save of sale successful"
    return sale
  end

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
    # new_gift.special_instructions   = nil    
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
  
  def ary_of_shopping_cart_as_hash
    cart = JSON.parse self.shoppingCart
    item_ary = []
    cart.each do |item|
      item_ary << item
    end
    return item_ary
  end

  def make_gift_items(shoppingCart_array)
    puts "In make gift items #{shoppingCart_array}"
    gift_item_array = []
    shoppingCart_array.each do |item|
        gift_item = GiftItem.initFromDictionary item
        gift_item_array << gift_item
    end
    puts "made it thru gift items #{gift_item_array}"
    self.gift_items = gift_item_array
  end

  private

    def notify_receiver
      if self.receiver_email
        puts "emailing the gift receiver for #{self.id}"
        # notify the receiver via email
        user_id = self.receiver_id.nil? ?  'NID' : self.receiver_id 
        Resque.enqueue(EmailJob, 'notify_receiver', user_id , {:gift_id => self.id, :email => self.receiver_email}) 
      end      
    end

    def invoice_giver
      puts "emailing the gift giver for #{self.id}"
      # notify the giver via email
      Resque.enqueue(EmailJob, 'invoice_giver', self.giver_id , {:gift_id => self.id})
    end

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

