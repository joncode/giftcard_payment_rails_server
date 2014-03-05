class Setting < ActiveRecord::Base
	include Utility

	belongs_to :user

	validates_uniqueness_of :user_id
	validates :confirm_email_token, uniqueness: true, length: { minimum: 20 }, :if => :confirm_email_token_exists?

	def app_serialize
		self.serializable_hash only: [:user_id, :email_redeem, :email_invoice, :email_invite, :email_follow_up, :email_receiver_new, :email_reminder_gift_receiver, :email_reminder_gift_giver]
	end

	def generate_email_link
		"#{PUBLIC_URL}/account/confirmemail/#{self.confirm_email_token}"
	end

private

	def confirm_email_token_exists?
		if self.confirm_email_token.nil?
			return false
		else
			return true
		end
	end

end


# connecting the attributes above to the notifications is as follows
# 1. Invoice Email - after purchase == "email_invoice"
# 2. Gift Redeemed - after your gift is completed == "email_redeem"
# 3. Invite Accepted - your invite to the app has been accepted == "email_invite"
# 4. Redeem Gift Follow Up - next day reminding you the details of the gift and news of the platform , new items, features == "email_follow_up"
# 5. Youve got a Gift - sent to receiver when a gift is purchased from them
# == Schema Information
#
# Table name: settings
#
#  id                           :integer         not null, primary key
#  user_id                      :integer
#  email_invoice                :boolean         default(TRUE)
#  email_redeem                 :boolean         default(TRUE)
#  email_invite                 :boolean         default(TRUE)
#  email_follow_up              :boolean         default(TRUE)
#  email_receiver_new           :boolean         default(TRUE)
#  created_at                   :datetime        not null
#  updated_at                   :datetime        not null
#  confirm_email_token          :string(255)
#  confirm_phone_token          :string(255)
#  reset_token                  :string(255)
#  confirm_phone_flag           :boolean         default(FALSE)
#  confirm_email_flag           :boolean         default(FALSE)
#  confirm_phone_token_sent_at  :datetime
#  confirm_email_token_sent_at  :datetime
#  reset_token_sent_at          :datetime
#  email_reminder_gift_receiver :boolean         default(TRUE)
#  email_reminder_gift_giver    :boolean         default(TRUE)
#

