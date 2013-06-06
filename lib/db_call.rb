module DbCall


    def self.status_for(gift_array)
        # print the gift ID and status
        if gift_array[0].kind_of? Gift
            gift_array.map  do |g|
                puts "Gift ID = #{g.id} | status = #{g.status}"
            end
        else
            puts "These are not gifts"
        end
        nil
    end


end