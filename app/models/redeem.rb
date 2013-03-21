class Redeem < ActiveRecord::Base
  attr_accessible :gift_id, :redeem_code
  
  belongs_to      :gift
  has_one         :giver,     :through => :gift
  has_one         :receiver,  :through => :gift
  has_one         :provider,  :through => :gift
  has_one         :order

  before_create :create_redeem_code
  after_create  :add_redeem_to_gift
  
  validates :gift_id , presence: true, uniqueness: true
  # redeem must be unique for gift
  
  def self.find_or_create_with_gift(gift)
    if redeem = gift.redeem
        # redeem exists

    else
        # redeem must be created
      redeem = Redeem.init_with_gift(gift)
    end
    return redeem
  end

  def self.init_with_gift(gift)
    Redeem.create(gift_id: gift.id)
  end

  private

    def create_redeem_code
      self.redeem_code = "%04d" % rand(10000)
    end
    
    def add_redeem_to_gift
      self.gift.update_attributes({status: 'notified'})
    end
end
# == Schema Information
#
# Table name: redeems
#
#  id                   :integer         not null, primary key
#  gift_id              :integer
#  reply_message        :string(255)
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#

