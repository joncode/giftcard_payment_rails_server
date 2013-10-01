class UserSocial < ActiveRecord::Base
    attr_accessible :identifier, :type_of, :user_id

    belongs_to :user
    after_save :add_to_mailchimp_list

    validates_presence_of :identifier, :type_of, :user_id

private

    def add_to_mailchimp_list
        if not Rails.env.test? || Rails.env.development?
        	if self.type_of  == "email"
                Resque.enqueue(SubscriptionJob, self.id)
        	end
        end
    end

end

# == Schema Information
#
# Table name: user_socials
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  type_of    :string(255)
#  identifier :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  active     :boolean         default(TRUE)
#

