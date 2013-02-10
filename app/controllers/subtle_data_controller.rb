class SubtleDataController < ApplicationController
    LOCATION_ID = "604"
    PIPE        = "%7C"
    WEB_KEY     = "RlgrM1Uw"
    SD_ROOT     = "https://www.subtledata.com/API/M/1/?Q="

    respond_to :js
    # before_filter :have_token? # - have to have this token persist between instances

    def index
        @call   ||= params[:call] 
        @data     = nil
        @token  ||= "M1UwX0ZY"

        
        @url      = "#{SD_ROOT}#{@call}"
        self.send("make_URL_for_" + @call)
        
        @response = String.new(%x{curl #{@url}})
        
        puts "Here is the request #{@url}"
        puts "Here is the response #{@response}"

        if @response.include? ("|-")
            received_error
        else
            parseQuery
        end
    end

    private

        def received_error
            x      = @response.split('|')
            @query = x[0]
            @data  = x[1]
            @data  = @data + " #{x[2]}" if x[2]
            if x[1] == "-1000000"
                get_new_token
                # should recall the method with new token ?
            end
        end

        def make_URL_for_0000
            @url  += "#{PIPE}#{WEB_KEY}"
        end

        def init_data_for_0000 item_str
            item_str.split('^')
        end

        def make_URL_for_0201 category=nil
            header = "#{@token}#{PIPE}"
            category ||= "4904"
            @url  += "#{header}#{LOCATION_ID}#{PIPE}#{category}#{PIPE}1#{PIPE}0"
        end

        def init_data_for_0201 item_str
            return SDMenuItem.new item_str 
        end

        def make_URL_for_0203
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}#{PIPE}0"
        end

        def init_data_for_0203 item_str
            return SDCategory.new item_str
        end

        def make_URL_for_0300
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}"
        end

        def init_data_for_0300 item_str
            return SDLocation.new item_str
        end

        def make_URL_for_1002
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}"
        end

        def init_data_for_1002 item_str
            return SDEmployee.new item_str 
        end        

        def make_URL_for_0109
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}#{PIPE}0"
        end

        def init_data_for_0109 item_str
            item_str.split('^')
        end 

        def make_URL_for_0110
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}#{PIPE}0"
        end

        def init_data_for_0110 item_str
            item_str.split('^')
        end

        def make_URL_for_0120
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}"
        end

        def init_data_for_0120 item_str
            item_str.split('^')
        end

        def make_URL_for_0130
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}"
        end

        def init_data_for_0130 item_str
            item_str.split('^')
        end

        def make_URL_for_0410
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}"
        end

        def init_data_for_0410 item_str
            item_str.split('^')
        end

        def make_URL_for_0620
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}"
        end

        def init_data_for_0620 item_str
            item_str.split('^')
        end

        def make_URL_for_0511
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}"
        end

        def init_data_for_0511 item_str
            item_str.split('^')
        end

        def make_URL_for_0460
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}"
        end

        def init_data_for_0460 item_str
            item_str.split('^')
        end

        def make_URL_for_1001
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}"
        end

        def init_data_for_1001 item_str
            return SDEmployee.new item_str 
        end

        def parseQuery
            x = @response.split('|')
            puts "parseQuery #{@response}"
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
            new_data_ary = []
            @data.each do |d|
                new_data_ary << self.send('init_data_for_' + @call, d)
            end
            @data = new_data_ary
        end

        def have_token?
            if @token.nil?
                get_new_token
            end
        end

        def get_new_token
            url     = "#{SD_ROOT}0000#{PIPE}#{WEB_KEY}"
            response = String.new(%x{curl #{url}})
            query , @token = response.split('|')
            puts "GET TOKEN #{@token}"  
        end
end

class SDMenuItem
    attr_reader :sd_id, :name, :price, :image_type, :image_url
    
    def initialize(item_str)
        x = item_str.split('^')
        @sd_id = x[0]
        @name  = x[1]
        @price = x[2]
        puts "AS OBJ #{self.inspect}"
        if x[3]
            ic = x[3].split('`')
            @image_type = ic[0]
            @image_url  = ic[1]
        end
    end
end

class SDCategory
    attr_reader :sd_category_id, :name, :instructs, :items, :subcategories, :image_type,
                :image_url, :modifiers
    def initialize item_str
        x = item_str.split('^')
        @sd_category_id = x[0]
        @name           = x[1]
        @instructs      = x[2]
        @items          = x[3] == "1" ? true : false
        @subcategories  = x[4] == "1" ? true : false
        if x[5]
            ic = x[5].split('`')
            @image_type = ic[0]
            @image_url  = ic[1]
        end
        @modifiers      = x[6] == "1" ? true : false
    end
end

class SDEmployee
    attr_reader :sd_employee_id, :user_name, :first_name, 
                :middle_name, :last_name, :birthday, :email,
                :manager 
    def initialize item_str
        x = item_str.split('^')
        @sd_employee_id = x[0]
        @user_name      = x[1]
        @first_name     = x[2]
        @middle_name    = x[3]
        @last_name      = x[4]
        @birthday       = x[5]
        @email          = x[6]
        @manager        = x[7] == "1" ? true : false
    end
end

class SDLocation
    attr_reader :sd_location_id, :name, :address, :address_2, :city, :state, :zip,
                :latitude, :longitude, :phone, :website_url, :neighborhood, :cross_streets,
                :price_rating, :user_rating, :logo_url, :photo_url, :employee_request,
                :color_theme, :table_instr, :receipt_instr, :specials, :ordering, :cc_on, :cat_avail,
                :fav_avail, :process_new_cc, :process_pre_auth_cc  

    def initialize item_str
        x = item_str.split('^')
        @sd_location_id     = x[0]
        @name               = x[1]
        @address            = x[2]
        @address_2          = x[3]
        @city               = x[4]
        @state              = x[5]
        @zip                = x[6]
        @latitude           = remove_trailing_zeros x[7]
        @longitude          = remove_trailing_zeros x[8]
        @phone              = x[9]
        @website_url        = x[10]
        @neighborhood       = x[11]
        @cross_streets      = x[12]
        @price_rating       = convert_price_rating x[13]
        @user_rating        = x[14] == "0" ? "No rating" : x[14]
        @logo_url           = x[15]
        @photo_url          = x[16]
        @employee_request   = x[17] == "1" ? true : false
        @color_theme        = x[18]
        @table_instr        = x[19]
        @receipt_instr      = x[20]
        @specials           = x[21] == "1" ? true : false
        @ordering           = x[22]
        @cc_on              = x[23]
        @cat_avail          = x[24] == "1" ? true : false
        @fav_avail          = x[25] == "1" ? true : false
        @process_new_cc     = x[26] == "1" ? true : false
        @process_pre_auth_cc = x[27] == "1" ? true : false
    end

    private

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
