module SubtleDataHelper

    def remove_trailing_zeros str
        while str.chomp!('0')
        end
        return str             
    end

    def convert_price_rating rating
        rating_str = ""
        rating = rating.to_i
        case rating
        when 0
            rating_str = "No rating"
        else
            rating.times do 
                rating_str += '$'
            end
        end
        return rating_str
    end
    
    class SDRequest
	    attr_accessor :token, :location_id, :user_id, :device_id, :table_id, :ticket_id,
	                    :item_id, :card_id
	    def initialize vars
            @token       = vars["token"]
	        @location_id = vars["location_id"]
	        @user_id     = vars["user_id"]
	        @device_id   = vars["device_id"]
	        @table_id    = vars["table_id"]
	        @ticket_id   = vars["ticket_id"]
	        @item_id     = vars["item_id"]
	        @card_id     = vars["card_id"]
	    end 

	    def serialize
	        self.instance_values          
	    end              
	end
end
