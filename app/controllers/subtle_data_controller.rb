class SubtleDataController < ApplicationController
    LOCATION_ID = "604"
    PIPE        = "%7C"

    def index
        @data   = nil
        sd_root = "https://www.subtledata.com/API/M/1/?Q="
        web_key = "RlgrM1Uw"
        token   = "M1UwX0ZY"
        call    = params[:call] 
        url     = "#{sd_root}#{call}"

        if call = "0000"
            url += "#{PIPE}#{web_key}"
        else
            url += "#{token}#{PIPE}"
            case call
            when "0203"
                url += get0203
            when "0300"
                url += get0203
            when "1002"
                url += get0203
            end
        end
        
        @response = String.new(%x{curl #{url}})
        
        puts "Here is the request #{url}"
        puts "Here is the response #{@response}"

        parseQuery
        
        respond_to do |format|
            format.js 
        end
    end

    private

        def get0203
            return "#{LOCATION_ID}#{PIPE}#{0}"
        end

        def parseQuery
            x = @response.split('|')
            if x.count == 2
                @query  = x[0]
                @data   = x[1]
                parseData
            elsif x.count == 1
                @query  = x[0]
                @data   = "No Data"
            end
        end

        def parseData
            @data = @data.split('~')

        end
end
