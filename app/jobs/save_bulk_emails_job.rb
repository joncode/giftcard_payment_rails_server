class SaveBulkEmailsJob

    @queue = :database

    def self.perform data
		puts "\n SaveBulkEmailsJob\n"
    	be_obj = BulkEmail.find(data)
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



# Resque.enqueue(SaveBulkEmailsJob, { "provider_id" => @provider_id, "proto_id" => @proto_id, processed: false})