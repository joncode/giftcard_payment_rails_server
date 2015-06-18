class AffiliateGift < ActiveRecord::Base
	self.table_name = "affiliates_gifts"

#   -------------

 	belongs_to :gift
 	belongs_to :affiliate
 	belongs_to :landing_page

#   -------------
end

# == Schema Information
#
# Table name: affiliates_gifts
#
#  affiliate_id    :integer
#  gift_id         :integer
#  landing_page_id :integer
#

