require 'mailchimp'

class MailchimpList

	attr_reader :mc, :list_id, :email, :first_name, :last_name

	def initialize email, first_name=nil, last_name=nil
		@mc      	= Mailchimp::API.new(MAILCHIMP_APIKEY)
		@list_id 	= MAILCHIMP_LIST_ID
		@email   	= email
		@first_name = first_name
		@last_name 	= last_name
	end

	def subscribe
		begin
			resp = self.mc.lists.subscribe(self.list_id, {'email' => self.email}, { 'fname' => self.first_name, 'lname' => self.last_name })
			puts "user email #{self.email} is added to subscription list - #{resp}"
		rescue Mailchimp::ListAlreadySubscribedError
			puts"#{email} is already subscribed to the list"
		rescue Mailchimp::ListDoesNotExistError
			puts "The list could not be found"
		rescue Mailchimp::Error => ex
			puts "in Mailchimp::Error"
			if ex.message
				puts ex.message
			else
				puts "An unknown error occurred"
			end
		end
	end

	def unsubscribe
		begin
    		self.mc.lists.unsubscribe(self.list_id, {'email' => self.email})
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





	def member_info
		self.mc.lists.member_info(self.list_id, {'email' => self.email})
	end

end
