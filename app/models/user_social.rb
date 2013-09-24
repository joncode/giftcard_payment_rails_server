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
