
#  this is the tests for the buy database 
#  in rails console
# load "test/buy_giver.rb"
#  b = BuyTests.new
# b.all

class BuyTests
  
  attr_accessor :user1, :user2, :correct, :incorrect, :total_tests, :last_method_name, :total_methods, :show_implemented
  
  def initialize(user1=nil,user2=nil)
      @user1 = user1.nil? ? User.first : user1
      @user2 = user2.nil? ? User.last : user2
      @correct = []
      @incorrect = []
      @total_tests = 3
      @total_methods = 3
      @last_method_name = ""
      @show_implemented = true
  end
  
  def reset_test_variables
      @correct = []
      @incorrect = []
      @total_tests = 3
      @total_methods = 3
      @last_method_name = ""    
  end
  
  def all
      reset_test_variables
      puts "Running all tests for BuyTest"
      run_all_tests
      puts "\n\nCompleted all tests for BuyTest\n"
      puts "Correct tests = #{@correct.size}"
      puts "Incorrect tests = #{@incorrect.size}"
      puts "\n\nCorrect Tests : #{@correct.size}"
      @correct.each do |c|
        puts c.keys
      end
      puts "\n\nINcorrect Tests : #{@incorrect.size}"
      @incorrect.each do |c|
        puts c.keys
      end
      puts "\n\n BuyTests complete"
      puts "Ran #{@total_tests} total tests"
      puts "In #{@total_methods} total methods"
  end
  
  def run_all_tests
    test_providers_no_data
    test_providers_with_token
    test_providers_near_me
    test_providers_best
    test_providers_best_and_city
    test_providers_favorites
    test_menu # this should test that menus are correctly built from menu db
    test_menu_from_raw_data
    test_user_get_other_users
    test_user_find_users_near_them
    test_user_get_friends
    test_user_get_other_user_location
    test_user_get_providers_near_other_user
    test_user_get_other_user_events
    test_user_get_other_user_event_locations
    test_user_get_providers_near_other_user_event
    test_user_get_other_user_favorites
    test_user_get_other_user_about_me
    td
    create_gift_has_validations
    create_gift_success_or_error
    create_gift_with_email_finds_db_users
    create_gift_with_text_finds_db_users
    create_gift_with_facebook_finds_db_users
    create_gift_with_twitter_finds_db_users
    test_create_gift_stores_data_correctly
    test_create_gift_handles_card_errors
    test_create_gift_handle_card_success
    test_create_gift_creates_correct_sale
    test_create_gift_creates_merchant_notification
    test_create_gift_creates_receiver_notification
    test_notify_user_of_card_problems
    test_server_sends_email_to_receiver_with_permalinkPage
    test_server_notifies_receiver_on_app
    test_server_notifies_receiver_on_network
    test_merchant_receives_notification
    test_merchant_receives_notification_on_chosen_network
  end
  
    # run only D tests
  def td
     test_add_cards_to_server 
     test_encrypted_card_on_server
     test_get_cards_from_server
     test_send_card_info_to_bank
  end
  ############    A TESTS - get providers
  
  def test_providers_no_data
      # route request with no remember token
    test = "Test A1"
    method_name = "test_providers_no_data"
    puts "\n\n  *******     #{test} - #{method_name}     ********* "
    s = String.new(%x{curl #{TEST_URL}/app/providers.json -d ' '})
    response = JSON.parse s
    if response.kind_of? Hash
      if response["error"]
        puts "Correct #{test} - #{method_name}"
        @correct << {test => response["error"] }
      else
        puts "Incorrect hash response to #{test} - #{method_name}"
        @incorrect << {test => response}
      end
    else
      puts "Incorrect hash response to #{test} - #{method_name}"
      @incorrect << {test => response }
    end
    puts "         ^^^^^^^^                            ^^^^^^^^^^^^^           "
    
  end
  
  def test_providers_with_token
    test = "Test A2"
    method_name = "test_providers_with_token"
    puts "\n\n  *******     #{test} - #{method_name}     ********* "
    s = String.new(%x{curl #{TEST_URL}/app/providers.json -d'token=#{@user1.remember_token}'})
    response = JSON.parse s
    data = Provider.all
    if response.size == data.size
      puts "Correct #{test} - #{method_name}"
      @correct << {test => response }
    else
      puts "Incorrect size #{test} - #{method_name}"
      puts "response.size = #{response.size}"
      puts "db query.size = #{data.size}"
      incorrect_response = {test => response}
      @incorrect << incorrect_response
      puts "response = #{incorrect_response}"
      puts "request string = {curl #{TEST_URL}/app/providers.json -d'token=#{@user1.remember_token}'}"
    end
    puts "         ^^^^^^^^                            ^^^^^^^^^^^^^           "
    
  end
  
  def test_providers_near_me
    test = "Test A3"
    method_name = "test_providers_near_me"
    puts "\n\n  *******     #{test} - #{method_name}     ********* "
    s = String.new(%x{curl #{TEST_URL}/app/providers.json -d'token=#{@user1.remember_token}&city=#{@user1.city}'})
    response = JSON.parse s
    data = Provider.where(city: @user1.city)
    if response.size == data.size
      puts "Correct #{test} - #{method_name}"
      @correct <<  {test => response }
    else
      puts "Incorrect size #{test} - #{method_name}"
      @incorrect << {test => response }
    end
    puts "         ^^^^^^^^                            ^^^^^^^^^^^^^           "
    
  end
    
  def test_providers_best
    test = "Test A4"
    method_name = "test_providers_best"
    puts "\n\n  *******     #{test} - #{method_name}     ********* "
    BUTTONS.each do |button|
      curlString = "curl #{TEST_URL}/app/providers.json -d'token=#{@user1.remember_token}&button=#{button}'"  
      #s = String.new(%x{#{curlString}})
      #response = JSON.parse s
      ###  --- >>>>>>        
      # data = Provider.where(tag_button: button)
      
      #save_results(response.size, data.size, test,method_name, curlString, button, "size")
    end
    puts "IMPLEMENT"  
    
  end
  
  def test_providers_best_and_city
    test = "Test A5"
    method_name = "test_providers_best_and_city"
    puts "\n\n  *******     #{test} - #{method_name}     ********* "
    BUTTONS.each do |button|
      curlString = "curl #{TEST_URL}/app/providers.json -d'token=#{@user1.remember_token}&button=#{button}&city=#{@user1.city}'"
      #s = String.new(%x{#{curlString}})
      #response = JSON.parse s
      ###  --- >>>>>>        
      # data = Provider.where(tag_button: button, city: user1.city)

      #save_results(response.size, data.size, test,method_name, curlString, button, "size")
    end
    puts "IMPLEMENT" 
  end
  
  def test_providers_favorites
    test = "Test A6"
    method_name = "test_providers_favorites"
    puts "\n\n  *******     #{test} - #{method_name}     ********* "
    curlString = "url #{TEST_URL}/app/providers.json -d'token=#{@user1.remember_token}&favorites=true'"
    #s = String.new(%x{#{curlString}})
    #response = JSON.parse s
    ###  --- >>>>>>        
    # data = Favorite.find_by_user(user_id)

    #save_results(response.size, data.size, test,method_name, curlString, nil, "size")
    puts "IMPLEMENT" 
  end
  
  #############   B TESTS - get menu items
  
  def test_menu
    test = "Test B1"
    method_name = "test_menu"
    puts "\n\n  *******     #{test} - #{method_name}     ********* "
    Provider.all.each do |merchant|
      curlString = "curl #{TEST_URL}/app/menu.json -d'token=#{@user1.remember_token}&data=#{merchant.id}'"
      json_string = String.new(%x{#{curlString}})
      response = JSON.parse json_string
      menuString = MenuString.find_by_provider_id(merchant.id)
      data = JSON.parse menuString.data
      save_results(response, data, test,method_name, curlString, merchant, "size")
    end
  end
  
  def test_menu_from_raw_data
      test = "Test B2"
      method_name = "test_menu_from_raw_data"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "
      Provider.all.each do |merchant|
        curlString = "curl #{TEST_URL}/app/menu.json -d'token=#{@user1.remember_token}&data=#{merchant.id}'"

        json_string = String.new(%x{#{curlString}})
        response = JSON.parse json_string
        menu_string = MenuString.new
        data = menu_string.generate_menu_string(merchant.id)
        save_results(json_string, data, test,method_name, curlString, merchant, "string")
      end
  end
  
  ###############  C TESTS - get users
  
  def test_user_get_other_users
      test = "Test C1"
      method_name = "test_user_get_other_users"
      curlString = "curl #{TEST_URL}/app/users_array.json -d'token=#{@user1.remember_token}'"
      puts "\n\n  *******     #{test} - #{method_name}     ********* " 
      
      json_string = String.new(%x{#{curlString}})
      response = JSON.parse json_string
      
      data = User.all

      save_results(response.size, data.size, test,method_name, curlString, nil, "size")
  end
  
  def test_user_find_users_near_them
      test = "Test C2"
      method_name = "test_user_find_users_near_them"
      curlString = "curl #{TEST_URL}/app/menu.json -d'token=#{@user1.remember_token}'"
      puts "\n\n  *******     #{test} - #{method_name}     ********* " 
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT"   
  end
  
  def test_user_get_friends
      test = "Test C3"
      method_name = "test_user_get_friends"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT"   
  end
  
  def test_user_get_other_user_location
      test = "Test C4"
      method_name = "test_user_get_other_user_location"
      puts "\n\n  *******     #{test} - #{method_name}     ********* " 
      
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT"    
  end
  
  def test_user_get_providers_near_other_user
      test = "Test C5"
      method_name = "test_user_get_providers_near_other_user"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT"   
  end
  
  def test_user_get_other_user_events
      test = "Test C6"
      method_name = "test_user_get_other_user_events"
      puts "\n\n  *******     #{test} - #{method_name}     ********* " 
      
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT"    
  end
  
  def test_user_get_other_user_event_locations
      test = "Test C7"
      method_name = "test_user_get_other_user_event_locations"
      puts "\n\n  *******     #{test} - #{method_name}     ********* " 
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
       puts "IMPLEMENT"   
  end
  
  def test_user_get_providers_near_other_user_event
      test = "Test C8"
      method_name = "test_user_get_providers_near_other_user_event"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT"   
  end
  
  def test_user_get_other_user_favorites
      test = "Test C9"
      method_name = "test_user_get_other_user_favorites"
      puts "\n\n  *******     #{test} - #{method_name}     ********* " 
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT"    
  end
  
  def test_user_get_other_user_about_me
      test = "Test C10"
      method_name = "test_user_get_other_user_about_me"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      curlString = "curl #{TEST_URL}/app/others_questions.json -d'token=#{@user2.remember_token}&user_id=#{@user2.id}'"
      json_string = String.new(%x{#{curlString}})
      response = JSON.parse json_string
      data = Answer.where(user_id: @user2.id)
      response_with_answer = []
      response.each do |obj|
          if obj.has_key? "answer"
              response_with_answer << obj
          end
      end
      save_results(response_with_answer.size, data.size, test,method_name, curlString, nil, "size")
  end

  ###############  D TESTS - credit cards

  def test_add_cards_to_server
      test = "Test D1"
      method_name = "test_add_cards_to_server"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "
      cc_hash = generate_credit_card(@user1) 
      cc_hash_json = cc_hash.to_json 
      curlString = "curl #{TEST_URL}/app/add_card.json -d'token=#{@user1.remember_token}&data=#{cc_hash_json}'"
      json_string = String.new(%x{#{curlString}})
      response = JSON.parse json_string
      # data = Card.create_card_from_hash cc_hash
      # saved_card_str = json_string
      # puts "json string = #{json_string}"
      # if response.keys == ["success"]
      #      saved_card = Card.last
      #      save_card_str = "#{saved_card.name},#{saved_card.nickname},#{saved_card.user_id},#{saved_card.month},#{saved_card.year}"
      # end
      data_str = "#{cc_hash['name']},#{cc_hash['nickname']},#{cc_hash['user_id']},#{cc_hash['month']},#{cc_hash['year']}"
      if response.keys == ["success"]
      elsif response.keys == ["error-server"]
      end
      save_results(json_string, data_str, test,method_name, curlString, nil, "string")
  end  
  
  def test_encrypted_card_on_server
      test = "Test D2"
      method_name = "test_encrypted_card_on_server"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      curlString = "curl #{TEST_URL}/app/users_array.json -d'token=#{@user1.remember_token}'"
      #json_string = String.new(%x{#{curlString}})
      #response = JSON.parse json_string
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      # card number on saved in db is encrypted
     puts "IMPLEMENT" 
  end
  
  def test_get_cards_from_server
      test = "Test D3"
      method_name = "test_get_cards_from_server"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      curlString = "curl #{TEST_URL}/app/cards.json -d'token=#{@user1.remember_token}'"
      json_string = String.new(%x{#{curlString}})
      response = JSON.parse json_string
      data = Card.find_all_by_user_id(@user1.id)
      if response["success"]
          response_array = response["success"]
          save_results(response_array.size, data.size, test,method_name, curlString, nil, "success")
      elsif response["error"]
          data = "User has no cards on file"
          save_results(response["error"], data, test,method_name, curlString, nil, "No Card on file")
      end
  end
  
  def test_send_card_info_to_bank
      test = "Test D4"
      method_name = "test_send_card_info_to_bank"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      curlString = "curl #{TEST_URL}/app/users_array.json -d'token=#{@user1.remember_token}'"
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      # decrypts card info and send to bank
      puts "IMPLEMENT"     
  end

  ###############  E TESTS - create a gift

  def test_create_gift_stores_data_correctly
      test = "Test E1"
      method_name = "test_create_gift_stores_data_correctly"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT" 
    
  end

  def create_gift_has_validations
      test = "Test E2"
      method_name = "create_gift_has_validations"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT" 
    
  end
  
  def create_gift_success_or_error
      test = "Test E3"
      method_name = "create_gift_success_or_error"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT" 
    
  end
  
  def create_gift_with_email_finds_db_users
      test = "Test E4"
      method_name = "create_gift_with_email_finds_db_users"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT" 
    
  end
  
  def create_gift_with_text_finds_db_users
      test = "Test E5"
      method_name = "create_gift_with_text_finds_db_users"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT" 
    
  end
  
  def create_gift_with_facebook_finds_db_users
      test = "Test E6"
      method_name = "create_gift_with_facebook_finds_db_users"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT" 
    
  end
  
  def create_gift_with_twitter_finds_db_users
      test = "Test E7"
      method_name = "create_gift_with_twitter_finds_db_users"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT" 
  end

  def test_create_gift_handles_card_errors
      test = "Test E8"
      method_name = "test_create_gift_handles_card_errors"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
    puts "IMPLEMENT" 
  end
  
  def test_create_gift_handle_card_success
      test = "Test E9"
      method_name = "test_create_gift_handle_card_success"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT" 
    
  end
  
  def test_create_gift_creates_receiver_notification
      test = "Test E10"
      method_name = "test_create_gift_creates_receiver_notification"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
    puts "IMPLEMENT"     
  end
  
  def test_create_gift_creates_merchant_notification
      test = "Test E11"
      method_name = "test_create_gift_creates_merchant_notification"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
    puts "IMPLEMENT"     
  end
  
  def test_create_gift_creates_correct_sale
      test = "Test E12"
      method_name = "test_create_gift_creates_correct_sale"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT"     
    
  end
  
    ###############  F TESTS - handle errors
    
    def test_notify_user_of_card_problems
        test = "Test F1"
        method_name = "test_notify_user_of_card_problems"
        puts "\n\n  *******     #{test} - #{method_name}     ********* "  



        #save_results(response, data, test,method_name, curlString, nil, "size")
        puts "IMPLEMENT" 
    end
    
    ###############  G TESTS - notify receiver / merchant 

    def test_server_sends_email_to_receiver_with_permalinkPage
        test = "Test G1"
        method_name = "test_server_sends_email_to_receiver_with_permalinkPage"
        puts "\n\n  *******     #{test} - #{method_name}     ********* "  



        #save_results(response, data, test,method_name, curlString, nil, "size")
        puts "IMPLEMENT" 
    end
    
    def test_server_notifies_receiver_on_app
        test = "Test G2"
        method_name = "test_server_notifies_receiver_on_app"
        puts "\n\n  *******     #{test} - #{method_name}     ********* "  



        #save_results(response, data, test,method_name, curlString, nil, "size")
        puts "IMPLEMENT" 
        
    end
    
    def test_server_notifies_receiver_on_network
        test = "Test G3"
        method_name = "test_server_notifies_receiver_on_network"
        puts "\n\n  *******     #{test} - #{method_name}     ********* "  



        #save_results(response, data, test,method_name, curlString, nil, "size")
        puts "IMPLEMENT" 
        
    end
    
    def test_merchant_receives_notification
        test = "Test G4"
        method_name = "test_merchant_receives_notification"
        puts "\n\n  *******     #{test} - #{method_name}     ********* "  



        #save_results(response, data, test,method_name, curlString, nil, "size")
        puts "IMPLEMENT" 
        
    end
    
    def test_merchant_receives_notification_on_chosen_network
        test = "Test G5"
        method_name = "test_merchant_receives_notification_on_chosen_network"
        puts "\n\n  *******     #{test} - #{method_name}     ********* "  



        #save_results(response, data, test,method_name, curlString, nil, "size")
        puts "IMPLEMENT" 
        
    end
      
   ######## class factory methods
   def generate_credit_card(user)
       cc_hash = {"csv" => "129", 
            "month" => "1",
             "year" => "2016", 
             "name" => user.fullname,
             "nickname" => "work card",
             "number" => "4034946662974813",
             "brand" => "visa",
             "user_id" => user.id,
        }					    
   end
   
   def reverse_card_number(hashed_card_number, first_six, last_four)
        0.upto(999_999) do |i|
            card_number_to_test = "#{first_six}%06d#{last_four}" % i
            hashed_to_test = Digest::SHA1.hexdigest(card_number_to_test)
            if hashed_card_number == hashed_to_test
                return card_number_to_test
            end
        end
   end
   
  private    
  
    def save_results(response, data, test, method_name, curlString, object=nil, comparitor=nil)
        puts "response = #{response}"
        @total_tests += 1
        if method_name != @last_method_name
            @total_methods += 1
        end
        @last_method_name = method_name
        if object
            if object.name
                key = "#{test} - #{object.id} - #{object.name}"
            else
                key = "#{test} - #{object.id}"
            end
        else
            key = test
        end
        if response == data
          puts "          ^^^^^^^^      Correct #{comparitor} #{key} - #{method_name}    ^^^^^^^^^^^^^           \n"
          @correct << {key => response }
        else
          puts "        ^^^^^^^^      Incorrect #{comparitor} #{key} - #{method_name}    ^^^^^^^^^^^^^           "
          incorrect_response = {key => response}
          @incorrect << incorrect_response
          puts "response = #{incorrect_response}"
          puts "db data = #{data}"
          puts "request string = #{curlString}"
          puts "         ^^^^^^^^                            ^^^^^^^^^^^^^           "
        end 
    end

end



