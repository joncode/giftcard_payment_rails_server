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

end
