class Campaign < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :gifts, as: :payable
end
# == Schema Information
#
# Table name: campaigns
#
#  id          :integer         not null, primary key
#  campaign_id :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

