module DbCall

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


end