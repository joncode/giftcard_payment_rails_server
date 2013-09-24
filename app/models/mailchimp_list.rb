require 'mailchimp'

module MailchimpList

  	@mc      = Mailchimp::API.new(MAILCHIMP_APIKEY)
    @list_id = MAILCHIMP_LIST_ID

    def self.subscribe email, first_name=nil, last_name=nil
    	begin
            @mc.lists.subscribe(@list_id, {'email' => email},{'fname' => first_name, 'lname' => last_name})
	    rescue Mailchimp::ListAlreadySubscribedError
	        puts"#{email} is already subscribed to the list"
	    rescue Mailchimp::ListDoesNotExistError
			puts "The list could not be found"
	    rescue Mailchimp::Error => ex
  	        if ex.message
  	          puts ex.message
  	        else
  	          puts "An unknown error occurred"
  	        end
	    end
    end

    def self.unsubscribe email
      @mc.lists.unsubscribe(@list_id, {'email' => email})
    end

    def self.member_info
      @mc.lists.member_info(@list_id, {'email' => email})
    end




 
end
