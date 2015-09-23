class LandingPage < ActiveRecord::Base

	validates_uniqueness_of :link
	validates :link, 	length: { minimum: 6 },     on: :create

#   -------------

	belongs_to :affiliate

#   -------------

	def self.click(link: link_in)
		l2 = link.split('/')
		affiliate_url_name = l2.last.split('-').first
		# affiliate_url_name = link.split('?aid=').last
		aff = Affiliate.where(url_name: affiliate_url_name).first
		# binding.pry
		lp = self.find_or_initialize_by(link: l2.last)
		lp.clicks += 1
		lp.affiliate = aff if lp.affiliate_id.nil?
		lp.save
		lp
	end

end
# == Schema Information
#
# Table name: landing_pages
#
#  id                :integer         not null, primary key
#  campaign_id       :integer
#  affiliate_id      :integer
#  title             :string(255)
#  banner_photo_url  :string(255)
#  example_item_id   :integer
#  page_json         :json
#  sponsor_photo_url :string(255)
#  link              :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  clicks            :integer         default(0)
#  users             :integer         default(0)
#  gifts             :integer         default(0)
#

