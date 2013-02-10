class SubtleDataController < ApplicationController
    LOCATION_ID = "604"
    USER_ID     = "1822"
    DEVICE_ID   = "1536"
    TABLE_ID    = "27493"
    TICKET_ID   = "123913"

    # 0120 0130 0140 0410 0620 0511 0460

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

            # app start up 
        def make_URL_for_0000
            @url  += "#{PIPE}#{WEB_KEY}"
        end

        def init_data_for_0000 item_str
            item_str.split('^')
        end

            # get items for category or ALL
        def make_URL_for_0201 category=nil
            header = "#{@token}#{PIPE}"
            category ||= "4904"
            @url  += "#{header}#{LOCATION_ID}#{PIPE}#{category}#{PIPE}1#{PIPE}0"
        end

        def init_data_for_0201 item_str
            return SDMenuItem.new item_str 
        end

            # menu categories for location
        def make_URL_for_0203
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}#{PIPE}0"
        end

        def init_data_for_0203 item_str
            return SDCategory.new item_str
        end

            # get location info by location id
        def make_URL_for_0300
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}"
        end

        def init_data_for_0300 item_str
            return SDLocation.new item_str
        end

            # get employees at location
        def make_URL_for_1002
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}"
        end

        def init_data_for_1002 item_str
            return SDEmployee.new item_str 
        end        

            # get clocked in employees
        def make_URL_for_1001
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}"
        end

        def init_data_for_1001 item_str
            return SDEmployee.new item_str 
        end

            # get user info
        def make_URL_for_0109
            # send sd_user_id as arg1 OR sd_user_name as arg2
            # Q=0109@@@||2025551212
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{USER_ID}"
        end

        def init_data_for_0109 item_str
            return SDUser.new item_str 
        end 

            # create new user
        def make_URL_for_0110
            header       = "#{@token}#{PIPE}"
            new_user_str = current_user.sd_serialize
            puts "USeR serialized #{new_user_str}"
            @url        += "#{header}#{new_user_str}"
        end

        def init_data_for_0110 item_str
                # parse the response
            user_ary = item_str.split("|")
                # save the sd_user_id onto the current_user object
            puts "CURRENT USER ID - sd_user_id = #{user_ary[0]}"
                # current_user.udate_attribute(:sd_user_id, user_ary[0])
        end

            # authenticate user
        def make_URL_for_0111
            header       = "#{@token}#{PIPE}"
            u = current_user
            new_user_str = "#{u.phone}#{PIPE}#{u.remember_token}#{PIPE}0#{PIPE}0#{PIPE}#{u.remember_token}"
            puts "USeR to authenticate #{new_user_str}"
            @url        += "#{header}#{new_user_str}"
        end

        def init_data_for_0111 item_str
                # parse the response
            user_ary = item_str.split("|")
                # save the sd_user_id onto the current_user object
            puts "CURRENT USER ID - sd_user_id = #{user_ary[0]}"
                # current_user.udate_attribute(:sd_user_id, user_ary[0])
        end
            # create credit card
        def make_URL_for_0120
            header = "#{@token}#{PIPE}"
            card = Card.first
            credit_card_str = "#{USER_ID}" + card.sd_serialize
            puts "Credit Card String = #{credit_card_str}"
            @url  += "#{header}#{credit_card_str}"
        end

        def init_data_for_0120 item_str
            return item_str
        end

            # get credit cards for user
        def make_URL_for_0130
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{USER_ID}"
        end

        def init_data_for_0130 item_str
            item_str.split('^')
        end

            # delete card from SD
        def make_URL_for_0140
            header = "#{@token}#{PIPE}"
            card = Card.first
            sd_card_id = card.sd_card_id 
            @url  += "#{header}#{USER_ID}#{PIPE}#{sd_card_id}"
        end

        def init_data_for_0140 item_str
            item_str.split('^')
        end

            # get tables for location
        def make_URL_for_0331
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}#{PIPE}0"
        end

        def init_data_for_0331 item_str
            return SDTable.new item_str
        end

            # get open tickets for tables
        def make_URL_for_0403
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}#{PIPE}#{TABLE_ID}"
        end

        def init_data_for_0403 item_str
           return SDTicket.new item_str
        end

            # create a ticket
        def make_URL_for_0410
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}#{PIPE}0#{PIPE}#{USER_ID}#{PIPE}#{DEVICE_ID}#{PIPE}27493#{PIPE}1#{PIPE}0#{PIPE}Drinkboard Gift#{PIPE}0#{PIPE}0#{PIPE}"
        end

        def init_data_for_0410 item_str
            "Ticket ID = #{item_str}"
        end

            # add item to ticket
        def make_URL_for_0520
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{TICKET_ID}#{PIPE}#{USER_ID}#{PIPE}#{}#{PIPE}#{DEVICE_ID}#{PIPE}27493#{PIPE}1#{PIPE}0#{PIPE}Drinkboard Gift#{PIPE}0#{PIPE}0#{PIPE}"
            
            #Arg 1:              Ticket ID
            #Arg 2:              User ID
            #Arg 3:              Order Item Collection
            #Arg 4:              Cover number
            #                1   =   Main person
            #                2+  =   If more than one person
            #Arg 5:              Date to Fire (UTC)
            #                Format:     MM/DD/YYYY HH:MM:SS AM/PM
            #                “”  =   Fire Immediately
            #Order Item Collection
            #Position 1:         Item ID
            #Position 2:         Quantity
            #Position 3:         Instructions
            #Position 4:         Order Modifier Collection
            #Order Modifier Collection
            #Position 1:         Modifier ID
        end

        def init_data_for_0520 item_str
            "Ticket ID = #{item_str}"
        end

            # add credit card payment to ticket
        def make_URL_for_0620
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{TICKET_ID}#{PIPE}#{USER_ID}#{PIPE}TEST CARD#{PIPE}0#{PIPE}100#{PIPE}20#{PIPE}#{PIPE}1"
        end

        def init_data_for_0620 item_str
            item_str
        end

            # place current order
        def make_URL_for_0511
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{TICKET_ID}#{PIPE}#{USER_ID}#{PIPE}#{PIPE}"
        end

        def init_data_for_0511 item_str
            item_str
        end

            # cancel ticket 
        def make_URL_for_0460
            header = "#{@token}#{PIPE}"
            @url  += "#{header}#{LOCATION_ID}#{PIPE}#{TICKET_ID}#{PIPE}0#{PIPE}0#{PIPE}#{USER_ID}"
        end

        def init_data_for_0460 item_str
            item_str
        end

        def parseQuery
            x = @response.split('|')
            puts "parseQuery #{@response}"
            if x.count == 2 
                    # typical remove the query from the response
                @query  = x[0]
                @data   = x[1]
                parseData
            elsif x.count == 1
                    # you get query response but no data
                @query  = x[0]
                @data   = "No Data"
            else
                    # in the case of a user object where the whole string is pipe separated
                @query  = x.shift
                @data   = x
                @data = parseUserData
            end
        end

        def parseUserData
            self.send('init_data_for_' + @call, @data)
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

class SDTicket
    attr_reader :ticket_id, :pos_ticket,  :table_id, :table_name, :sd_employee_id, :sd_user_id,
                :subtotal, :tax, :discount, :total, :remaining_balance,
                :service_charge, :date_opened, :covers
    
    def initialize(item_str)
        x = item_str.split('^')
        @ticket_id = x[0]
        @pos_ticket = x[1]
        @table_id = x[2]
        @table_name = x[3]
        @sd_employee_id = x[4]
        @sd_user_id = x[5]
        @subtotal = x[6]
        @tax = x[7]
        @discount = x[8]
        @total = x[9]
        @remaining_balance = x[10]
        @service_charge = x[11]
        @date_opened = x[12]
        @covers = x[13]
    end
end

class SDTable
    attr_reader :table_id, :name, :identifier
    
    def initialize(item_str)
        x = item_str.split('^')
        @table_id = x[0]
        @identifier  = x[1]
        @name = x[2]
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

class SDUser
    include SubtleDataHelper
    attr_reader :sd_user_id, :user_name, :first_name, 
                :middle_name, :last_name, :birthday, :phone, :email,
                :latitude, :longitude 

    def initialize x 
        x = x.split('^') if x.kind_of? String
        @sd_user_id     = x[0]
        @user_name      = x[1]
        @first_name     = x[2]
        @middle_name    = x[3]
        @last_name      = x[4]
        @birthday       = x[5]
        @phone          = x[6]
        @email          = x[7]
        @latitude       = remove_trailing_zeros x[8]
        @longitude      = remove_trailing_zeros x[9] 
    end
end

class SDLocation
    include SubtleDataHelper
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
end
