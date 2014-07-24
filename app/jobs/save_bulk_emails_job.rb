class SaveBulkEmailsJob

    @queue = :database

    def self.perform bulk_emails_id
		puts "\n SaveBulkEmailsJob\n"
    	be_obj = BulkEmail.find(bulk_emails_id)
		begin
    		emails = JSON.parse(be_obj.data)
    		emails.each do |email|
    			if email.kind_of?(Array)
    				email = email[0]
    			end
		    	social = SaveSocialImport.perform(email, be_obj.provider_id, be_obj.proto_id)
    		end
    		be_obj.update(processed: true)
    	rescue
    		puts "\n\n\n BULK EMAIL FAILS\n\n\n"
    	end
    end

end



# Resque.enqueue(SaveBulkEmailsJob, bulk_emails_id)

#Jul 23 23:33:24 dbappdev heroku/web.1:  State changed from starting to up

# 15,000
# in save social import :process 2014-07-24 21:49:15 +0000 7test@itson.me
#  "2014-07-24 22:01:38.927004"
# 12:23
# 20.5 contacts per second / 48 milliseconds per contact