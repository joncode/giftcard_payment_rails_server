class Relay < ActiveRecord::Base

	attr_accessible :gift_id, :giver_id, :name, :provider_id, :receiver_id, :status

	belongs_to :gift
	belongs_to :provider
	belongs_to :giver ,    class_name: "User"
	belongs_to :receiver , class_name: "User"

	validates_presence_of :provider_id, :status, :name
	validates :gift_id,   presence: true, uniqueness: true

#######  CLASS METHODS

	class << self

		def send_push_notification gift
				# get the user tokens from the pn_token db
			unless Rails.env.development? || Rails.env.test?
				if gift.receiver_id
					Resque.enqueue(PushJob, gift.id)
				end
			end

		end
	end

end

# == Schema Information
#
# Table name: relays
#
#  id          :integer         not null, primary key
#  gift_id     :integer
#  giver_id    :integer
#  provider_id :integer
#  receiver_id :integer
#  status      :string(255)
#  name        :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

