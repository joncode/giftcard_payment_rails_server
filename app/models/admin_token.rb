class AdminToken < ActiveRecord::Base
  attr_accessible :token

  validates_presence_of   :token
  validates_uniqueness_of :token
end
# == Schema Information
#
# Table name: admin_tokens
#
#  id         :integer         not null, primary key
#  token      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

