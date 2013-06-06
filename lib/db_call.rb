module DbCall

    def self.pattr(attribute, item_array)
        if item_array.count > 0
            item_array.map do |i|
                puts DbCall::string_attribute_obj(attribute, i)
            end
        else
            puts "No Items in array"
        end
        nil
    end

    def self.deactivate(attribute, data, obj)
        if data.kind_of? Array
            puts "Array received"
            data.each do |item|
                DbCall::deactivate_from_attr(attribute, item, obj)
            end
        else
            puts "#{data.class.to_s} received"
            DbCall::deactivate_from_attr(attribute, data, obj)
        end
        nil
    end

    def self.deactivate_from_attr(attribute, data, obj)
        user = obj.class.where({attribute => data} ).first
        puts DbCall::string_attribute_obj(attribute, user) + " | #{user.name}"
        print "Deactivate #{user.name} ? -> (y/n) "
        response = gets.chomp.downcase
        if response == 'y'
            user.update_attribute(:active, false)
        end
    end

    def self.string_attribute_obj(attribute, obj)
        "#{obj.class.to_s} ID = #{obj.id} | #{attribute.to_s} = #{obj.send(attribute)}"
    end


end