class Setting < ActiveRecord::Base
  attr_accessible :email_follow_up, :email_invite, 
  :email_invoice, :email_redeem, :user_id

  belongs_to :user

  validates_uniqueness_of :user_id

  def serialize
  	setings_hash = self.serializable_hash except: [:created_at, :updated_at]
  end


end


# connecting the attributes above to the notifications is as follows
# 1. Invoice Email - after purchase == "email_invoice"
# 2. Gift Redeemed - after your gift is completed == "email_redeem"
# 3. Invite Accepted - your invite to the app has been accepted == "email_invite"
# 4. Redeem Gift Follow Up - next day reminding you the details of the gift and news of the platform , new items, features == "email_follow_up"