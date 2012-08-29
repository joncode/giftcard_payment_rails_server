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
  attr_accessible :gift_id, :redeem_code, :redeem_id, :server_code, :server_id, :provider_id
  
  belongs_to  :provider
  belongs_to  :redeem
  belongs_to  :gift


  # order must be unique for each gift and redeem 
        # validation for provider_id is in callback until data is being sent from iPhone
  validates_presence_of :server_id 
  validates :gift_id   , presence: true, uniqueness: true
  validates :redeem_id , presence: true, uniqueness: true
    
  before_validation :authenticate_via_code
  before_create :add_provider_id, :if => :no_provider_id
  after_create  :update_gift_status
    
  private
    
    def update_gift_status
      self.gift.update_attributes({status: 'redeemed'})
    end
    
    def authenticate_via_code
      if self.redeem_code
        # authentication code for redeem_code
        redeem = Redeem.find(self.redeem_id)
        # set flag for approved/denied - true/false
        if self.redeem_code == redeem.redeem_code
          flag = true
        else
          flag = false
        end
      elsif self.server_code
        # authenticate for server_code
        server = User.find(server_id)
        # set flag for approval/denied - true/false
        if self.server_code == server.server_code
          flag = true
        else
          flag = false
        end
      else
        # no code provided - set flag to denied - false
        flag = false
      end
      return flag
    end
    
    def no_provider_id
      self.provider_id.nil?
    end
    
    def add_provider_id
      self.provider_id = self.gift.provider_id
    end
  
end
