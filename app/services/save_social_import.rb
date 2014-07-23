class SaveSocialImport

	def self.perform email, provider_id, proto_id
        puts "\n\n in save social import :process #{Time.now} #{email}"
        social = Social.find_or_create_by(network: "email", network_id: email)

        if social.errors.messages.count > 0
            #errors.add :email, "Row #{index+1}: #{social.network_id} is not a valid email"
            puts "#{social.network_id} is not a valid email - #{social.errors.full_messages}"
        else

            Connection.create(provider_id: provider_id, social_id: social.id)
        	if proto_id > 0
        		ProtoJoin.find_or_create_by(receivable_type: "Social", receivable_id: social.id, gift_id: nil, proto_id: proto_id)
        	end
        	# number_good += 1
        end
        return social
	end

end