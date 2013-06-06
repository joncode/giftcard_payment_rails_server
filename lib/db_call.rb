module DbCall

    def self.pattr(item_array, attribute)
        if item_array.count > 0
            item_array.map do |i|
                puts "#{i.class.to_s} ID = #{i.id} | #{attribute.to_s} = #{i.send(attribute)}"
            end
        else
            puts "No Items in array"
        end
        nil
    end


end