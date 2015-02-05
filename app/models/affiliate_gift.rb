class AffiliateGift < ActiveRecord::Base
	self.table_name = "affiliates_gifts"
 	belongs_to :gift
 	belongs_to :affiliate
 	belongs_to :landing_page
end