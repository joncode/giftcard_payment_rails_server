class PnToken < ActiveRecord::Base
  attr_accessible :pn_token, :user_id

  belongs_to :user

  validates :pn_token, uniqueness: true
end
