class Setting < ActiveRecord::Base
  attr_accessible :email_follow_up, :email_invite, 
  :email_invoice, :email_redeem, :user_id

  belongs_to :user

  validates_uniqueness_of :user_id

  def serialize
  	setings_hash = self.serializable_hash except: [:created_at, :updated_at]
  end


end
