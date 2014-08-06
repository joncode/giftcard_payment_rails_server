class SaveBulkEmailsAtJob

    @queue = :database_at

    def self.perform bulk_emails_id
		puts "\n SaveBulkEmailsJob\n"
    	be_obj = BulkEmail.find(bulk_emails_id)
		begin
    		emails = JSON.parse(be_obj.data)
    		emails.each do |email|
    			if email.kind_of?(Array)
    				email = email[0]
    			end
		    	social = save_social_import(email, be_obj.at_user_id, be_obj.proto_id)
    		end
    		be_obj.update(processed: true)
    	rescue
    		puts "\n\n\n BULK EMAIL FAILS\n\n\n"
    	end
    end

	def save_social_import(email, at_user_id, proto_id)
        downcased_email = strip_and_downcase(email)
        puts "\n\n in save social import :process #{Time.now} #{downcased_email}"
        social = Social.find_or_create_by(network: "email", network_id: downcased_email)

        if social.errors.messages.count > 0
            #errors.add :email, "Row #{index+1}: #{social.network_id} is not a valid email"
            puts "#{social.network_id} is not a valid email - #{social.errors.full_messages}"
        else

            AtUsersSocial.create(at_user_id: at_user_id, social_id: social.id)
        	if be_obj.proto_id > 0
        		ProtoJoin.find_or_create_by(receivable_type: "Social", receivable_id: social.id, gift_id: nil, proto_id: be_obj.proto_id)
        	end
        	# number_good += 1
        end
        return social
	end


end
