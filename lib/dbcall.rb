module Dbcall

    def self.create_admin_user(email, name=nil)
        user = User.new
        # we check for the name
        if name
            # we split on ' ', # set first to first last to last
            user.first_name, user.last_name  = name.split(' ')
        else
            # we assume its a drinkboard first.last@db email address
            # we split on '@'
            name_part, email_part            = email.split('@')
            # then we split first half on '.' # set that equal to first name, last name
            user.first_name, user.last_name  = name_part.split('.')
        end
        user.email    = email
        # we set password to <first name><first name>
        user.password = user.first_name + user.first_name
        user.password_confirmation = user.password
        # we set admin = true
        user.admin    = true
        user.save
        self.authorize_merchant_tools(user)
        return user
    end

    def self.mt_admin_users

        # get all users where admin:true
        users = User.where(admin: true).to_a
        # put their remeber token in an array
        users.each do |user|
            self.authorize_merchant_tools(user)
        end
    end

    def self.pattr(attribute, item_array)
        if item_array.count > 0
            item_array.map do |i|
                if attribute.kind_of? Array
                    puts self.string_attributes_ary(attribute, i)
                else
                    puts self.string_attribute_obj(attribute, i)
                end
            end
        else
            puts "No Items in array"
        end
        nil
    end

    def self.call_all(obj)
        methods_ary = obj.methods
        methods_ary.each do |o|
            print "#{o} --- "
            begin
                puts obj.send(o)
            rescue
                puts "fail"
            end
        end
        nil
    end

    def self.deactivate(attribute, data, obj)
        if data.kind_of? Array
            puts "Array received"
            data.each do |item|
                self.deactivate_from_attr(attribute, item, obj)
            end
        else
            puts "#{data.class.to_s} received"
            self.deactivate_from_attr(attribute, data, obj)
        end
        nil
    end

    def self.deactivate_from_attr(attribute, data, obj)
        if user = obj.class.where({attribute => data} ).first
            puts self.string_attribute_obj(attribute, user) + " | #{user.name}"
            print "Deactivate #{user.name} ? -> (y/n) "
            response = gets.chomp.downcase
            if response == 'y'
                user.update_attribute(:active, false)
            end
        else
            puts "no record found for #{attribute.to_s} = #{data}"
        end
    end

private

    def self.string_attribute_obj(attribute, obj)
        "#{obj.class.to_s} ID = #{obj.id} | #{attribute.to_s} = #{obj.send(attribute)}"
    end

    def self.string_attributes_ary(attribute, obj)
        str = "#{obj.class.to_s} ID = #{obj.id}"
        attribute.each do |attrb|
            str << " | #{attrb.to_s} = #{obj.send(attrb)}"
        end
        return str
    end

    def self.authorize_merchant_tools(user)
        # call the merchant tools database with the remember_token
        # make an httparty request with the admin token
        # we need an authentication token of some sort
        # we need a merchant tools route
        # we need merchant tools to save the remember token into admintokens db
        # convert the provider into json string
        route          = MERCHANT_URL + "/app/add_admin_user.json"
        admin_token    = user.remember_token
            # send json string to the merchant tools API
        auth_token     = User.where(admin: true).first.remember_token
        auth_params    = { "token" => auth_token, "data" => admin_token }
        parameters     = { :body => auth_params }
        party_response = HTTParty.post(route, parameters)
        if party_response.code == 200
            if party_response.parsed_response["status"]
                # receive true
                    # update the provider that merchant tools is activated
                    # re-render the show page without the create acount blurb
                msg        = party_response.parsed_response["message"]
                notice_msg = "Success. #{msg}"
            else
                # receive false
                    # re-render the show page with failure message
                msg        = party_response.parsed_response["message"]
                notice_msg = "#{msg}"
            end
        else
            # transmission failure
            puts "TRANSMISSION FAILED - create merchant tools account"
            notice_msg     = 'Network Failure. Merchant Account Not Created! please retry.'
        end
    end
end