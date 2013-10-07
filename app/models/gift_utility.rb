class GiftUtility

    def messenger
        if Rails.env.test?
            puts "send notify_receiver"
            puts "send invoice_giver"                       if @gift.regift_id.nil?
            puts "send Relay.send_push_notification ID = #{@gift.id}"  if @gift.receiver_id
        else
            notify_receiver
            invoice_giver                       if @gift.regift_id.nil?
            Relay.send_push_notification @gift  if @gift.receiver_id
        end
    end

    def add_receiver
            # add the receiver + receiver checks to the gift object
        if @gift.receiver_id.nil?
            add_receiver_object
        else
            # check that the receiver_id is active
            if receiver = User.unscoped.find( @gift.receiver_id )
                if receiver.active == false
                    @resp["error"]      = 'User is no longer in the system , please gift to them with phone, email, facebook, or twitter'
                    @gift.remove_receiver
                else
                    puts "\n Found an acitve user #{receiver.id} \n"
                    @gift.add_receiver receiver
                end
            end
        end
    end

    def add_receiver_from_hash(recipient)
        if recipient.id.nil?
            if add_receiver_object == false
                @gift.add_receiver recipient
            end
        else
            if receiver = User.unscoped.find( recipient.id )
                if receiver.active == false
                    @resp["error"]      = 'User is no longer in the system , please gift to them with phone, email, facebook, or twitter'
                    @gift.remove_receiver
                else
                    puts "\n Found an acitve user #{receiver.id} \n"
                    @gift.add_receiver receiver
                end
            end
        end

    end

    def add_receiver_object

        unique_ids = [ ["phone", @gift.receiver_phone], ["facebook_id", @gift.facebook_id],["email", @gift.receiver_email], ["twitter", @gift.twitter ] ]
        unique_ids.each do |unique_id|
            if unique_id[1].present?
                if find_user(unique_id[0], unique_id[1])
                    return true
                end
            end
        end
        false
    end

    def find_user type_of, unique_id
        method_is = "find_by_#{type_of}"
        if receiver = User.send(method_is, unique_id)
            puts "\n FOund a user from the netowrk details \n"
            @gift.add_receiver receiver
            @resp["receiver"] = receiver_info_resp(receiver)
            @resp["origin"]   = type_of
            return true
        else
            @resp["origin"]   = "NID"
            return false
        end
    end

    def make_user_with_hash(user_data_hash)
        recipient               = User.new
        recipient.id            = user_data_hash["receiver_id"]
        recipient.first_name    = user_data_hash["name"]
        recipient.email         = user_data_hash["email"]
        recipient.phone         = user_data_hash["phone"]
        recipient.facebook_id   = user_data_hash["facebook_id"]
        recipient.twitter       = user_data_hash["twitter"]
        return recipient
    end

    def convert_if_json params
        if params.kind_of?(String)
            JSON.parse(params)
        elsif params.kind_of?(Hash) || params.kind_of?(Array)
            params
        else
            nil
        end
    end

    def stringify_if_ary_or_hsh params
        if params.kind_of?(String)
            params
        elsif params.kind_of?(Hash) || params.kind_of?(Array)
            params.to_json
        else
            nil
        end
    end

    def receiver_info_resp receiver
        { "receiver_id" => receiver.id, "receiver_name" => receiver.name, "receiver_phone" => receiver.phone }
    end



end