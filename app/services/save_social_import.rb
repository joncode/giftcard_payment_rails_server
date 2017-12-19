class SaveSocialImport
    extend ModelValidationHelper

	def self.perform email, merchant_id, proto_id
        downcased_email = strip_and_downcase(email)
        puts "\n\n in save social import :process #{Time.now} #{downcased_email}"
        social = Social.find_or_create_by_email(downcased_email)


        if social.errors.messages.count > 0
            #errors.add :email, "Row #{index+1}: #{social.network_id} is not a valid email"
            puts "#{social.network_id} is not a valid email - #{social.errors.full_messages}"
        else
            # ProvidersSocial.create(merchant_id: merchant_id, social_id: social.id)
            if proto_id && proto_id > 0
                ProtoJoin.find_or_create_by(receivable_type: "Social", receivable_id: social.id, gift_id: nil, proto_id: proto_id)
            end
        	# number_good += 1
        end
        return social
	end

end