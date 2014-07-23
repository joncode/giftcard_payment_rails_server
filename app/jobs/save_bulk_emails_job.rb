class SaveBulkEmailsJob

    @queue = :database

    def self.perform data

    	bulk_emails = BulkEmail.where(provider_id: data["provider_id"], proto_id: data["proto_id"], processed: false)
    	bulk_emails.each do |be_obj|
    		begin
	    		emails = JSON.parse be_obj.data
	    		emails.each do |email|
			    	social = SaveSocialImport.perform(email, data["provider_id"], data["proto_id"])
	    		end
	    		be_obj.update(processed: true)
	    	rescue
	    		puts "\n\n\n BULK EMAIL FAILS\n\n\n"
	    	end
    	end
    end

end



# Resque.enqueue(SaveBulkEmailsJob, { "provider_id" => @provider_id, "proto_id" => @proto_id, processed: false})