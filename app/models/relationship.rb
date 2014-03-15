class Relationship < ActiveRecord::Base

	belongs_to :follower, class_name: "User"
	belongs_to :followed, class_name: "User"

	validates :follower_id, presence: true
	validates :followed_id, presence: true

	def save args={}
		existing = Relationship.where(followed_id: self.followed_id, follower_id: self.follower_id).first
		if existing.nil?
			super
		else
			return existing
		end
	end

	def self.pushed ary
		ary.each do |r_push|
			r_push.update_column(:pushed, true)
		end
	end

	def self.new_contacts(user_id)
		t = Time.now - 1.hour
		where(followed_id: user_id).where('created_at > ?', t)
	end


end
# == Schema Information
#
# Table name: relationships
#
#  id          :integer         not null, primary key
#  follower_id :integer
#  followed_id :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

