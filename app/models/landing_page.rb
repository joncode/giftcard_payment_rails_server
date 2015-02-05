class LandingPage < ActiveRecord::Base

	belongs_to :affiliate
	validates_uniqueness_of :link
	validates :link, 	length: { minimum: 6 },     on: :create

	def self.click(link: link)
		affiliate_url_name = link.split('?aid=').last
		aff = Affiliate.where(url_name: affiliate_url_name).first
		lp = self.find_or_initialize_by(link: link)
		lp.clicks += 1
		lp.affiliate = aff if lp.affiliate_id.nil?
		lp.save
		lp
	end

end
