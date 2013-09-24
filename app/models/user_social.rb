class UserSocial < ActiveRecord::Base
    attr_accessible :identifier, :type_of, :user_id

    belongs_to :user
    after_save :add_to_mailchimp_list

    validates_presence_of :identifier, :type_of, :user_id

private 

    def add_to_mailchimp_list
    	if self.type_of == "email"
    		first_name = User.find(self.user_id).first_name
    		last_name = User.find(self.user_id).last_name
	    	MailchimpList.subscribe(self.identifier, first_name, last_name)
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

