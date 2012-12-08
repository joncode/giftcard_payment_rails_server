
#  this is the tests for the buy database 
#  in rails console
# load "test/redeem_rec.rb"
#  r = RedeemTests.new
# r.all

class RedeemTests
  
  attr_accessor :user1, :user2, :correct, :incorrect, :total_tests, :last_method_name, :total_methods, :show_implemented
  
  def initialize(user1=nil,user2=nil)
      @user1 = user1.nil? ? User.first : user1
      @user2 = user2.nil? ? User.last : user2
      @correct = []
      @incorrect = []
      @total_tests = 0
      @total_methods = 0
      @last_method_name = ""
      @show_implemented = true
  end
  
  def reset_test_variables
      @correct = []
      @incorrect = []
      @total_tests = 0
      @total_methods = 0
      @last_method_name = ""    
  end
  
  def all
      reset_test_variables
      puts "Running all tests for RedeemTests"
      run_all_tests

      @correct.each do |c|
        puts c.keys
      end
      puts "\n\nINcorrect Tests : #{@incorrect.size}"
      @incorrect.each do |c|
        puts c.keys
      end
      puts "\n\nCompleted all tests for RedeemTests\n"
      puts "Correct tests = #{@correct.size}"
      puts "Incorrect tests = #{@incorrect.size}"
      puts "\n\nCorrect Tests : #{@correct.size}"
      puts "\n\n RedeemTests complete"
      puts "Ran #{@total_tests} total tests"
      puts "In #{@total_methods} total methods"
  end
  
  def run_all_tests
      a
      b
      c
      d
      e
      f
  end
  
  ############    A TESTS - notifications
  def a
      test_receives_notification_request_and_replies
      test_correct_badge_count
      test_sends_new_gifts_as_json
      test_sends_correct_info_when_no_gifts
  end

  # A. returns the correct notification data when requested by app
  #     - creates the correct badge count
  #     - sends the correct gift json objects
  #     - sends correct data when there are no gifts
    
  def test_receives_notification_request_and_replies
    test = "Test A1"
    method_name = "test_receives_notification_request_and_replies"
    puts "\n\n  *******     #{test} - #{method_name}     ********* "
    BUTTONS.each do |button|
      curlString = "curl #{TEST_URL}/app/providers.json -d'token=#{@user1.remember_token}'"  
      #s = String.new(%x{#{curlString}})
      #response = JSON.parse s
      ###  --- >>>>>>        
      # data = Provider.where(tag_button: button)
      
      #save_results(response.size, data.size, test,method_name, curlString, button, "size")
    end
    puts "IMPLEMENT"  
    
  end
  
  def test_correct_badge_count
    test = "Test A2"
    method_name = "test_correct_badge_count"
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
  
  def test_sends_new_gifts_as_json
    test = "Test A3"
    method_name = "test_sends_new_gifts_as_json"
    puts "\n\n  *******     #{test} - #{method_name}     ********* "
    curlString = "url #{TEST_URL}/app/providers.json -d'token=#{@user1.remember_token}'"
    #s = String.new(%x{#{curlString}})
    #response = JSON.parse s
    ###  --- >>>>>>        
    # data = Favorite.find_by_user(user_id)

    #save_results(response.size, data.size, test,method_name, curlString, nil, "size")
    puts "IMPLEMENT" 
  end
  
  def test_sends_correct_info_when_no_gifts
    test = "Test A4"
    method_name = "test_sends_correct_info_when_no_gifts"
    puts "\n\n  *******     #{test} - #{method_name}     ********* "
    curlString = "url #{TEST_URL}/app/providers.json -d'token=#{@user1.remember_token}'"
    #s = String.new(%x{#{curlString}})
    #response = JSON.parse s
    ###  --- >>>>>>        
    # data = Favorite.find_by_user(user_id)

    #save_results(response.size, data.size, test,method_name, curlString, nil, "size")
    puts "IMPLEMENT" 
  end
  
  #############   B TESTS - gift objects to the app
  def b
    test_sends_location_info_for_redeem_button
    test_gift_status_is_correct
    test_gift_giver_photo_is_correct
  end
  
  # B. gift data is correct
  #     - sends updated location information for the redeem button
  #         - get merchant info on gift object  
  #     - gift status is correct - incomplete is changed to app connected
  	
  def test_sends_location_info_for_redeem_button
    test = "Test B1"
    method_name = "test_sends_location_info_for_redeem_button"
    puts "\n\n  *******     #{test} - #{method_name}     ********* "

      curlString = "curl #{TEST_URL}/app/menu.json -d'token=#{@user1.remember_token}'"
      # json_string = String.new(%x{#{curlString}})
      # response = JSON.parse json_string
      # menuString = MenuString.find_by_provider_id(merchant.id)
      # data = JSON.parse menuString.data
      # save_results(response, data, test,method_name, curlString, merchant, "size")
      puts "IMPLEMENT" 
  end
  
  def test_gift_status_is_correct
      test = "Test B2"
      method_name = "test_gift_status_is_correct"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "

        curlString = "curl #{TEST_URL}/app/menu.json -d'token=#{@user1.remember_token}'"


        puts "IMPLEMENT" 
  end
  
  def test_gift_giver_photo_is_correct
      test = "Test B3"
      method_name = "test_gift_status_is_correct"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "

        curlString = "curl #{TEST_URL}/app/menu.json -d'token=#{@user1.remember_token}'"


        puts "IMPLEMENT" 
  end
  
  ###############  C TESTS 
  def c
    test_app_notifies_server_of_gift_status_changes
    test_server_transfer_notifications_to_giver
    test_server_transfer_notifications_to_merchant
  end
  # C. sends an update flag to any response 
  #     - when gift is saved for user as receiver
  #     - response is read by app as a command to call app/update with remember token
  	  
  def test_app_notifies_server_of_gift_status_changes
      test = "Test C1"
      method_name = "test_app_notifies_server_of_gift_status_changes"
      curlString = "curl #{TEST_URL}/app/users_array.json -d'token=#{@user1.remember_token}'"
      puts "\n\n  *******     #{test} - #{method_name}     ********* " 
      
      # json_string = String.new(%x{#{curlString}})
      # response = JSON.parse json_string
      # 
      # data = User.all

      #save_results(response.size, data.size, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT"  
  end
  
  def test_server_transfer_notifications_to_giver
      test = "Test C2"
      method_name = "test_server_transfer_notifications_to_giver"
      curlString = "curl #{TEST_URL}/app/menu.json -d'token=#{@user1.remember_token}'"
      puts "\n\n  *******     #{test} - #{method_name}     ********* " 
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT"   
  end
  
  def test_server_transfer_notifications_to_merchant
      test = "Test C3"
      method_name = "test_server_transfer_notifications_to_merchant"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT"   
  end

  ###############  D TESTS
  def d
      test_correct_employees_for_location
      test_sends_only_customer_employees
      test_gives_correct_route_for_employee_public_photo
      test_gives_correct_route_for_employee_secure_image
  end
  # D. sends employee list with photos and secure images to app
  #     - employee list is correct for location
  #     - employee list does not included employees who are not customer facing
  #     - employee list gives correct routes for profile photo
  #     - employee list givers correct routes for secure image
  
  def test_correct_employees_for_location
      test = "Test D1"
      method_name = "test_correct_employees_for_location"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "
      Gift.all.each do |gift|
          puts "gift id = #{gift.id}"
          curlString = "curl #{TEST_URL}/app/employees.json -d'token=#{@user1.remember_token}&data=#{gift.id}'"
          json_string = String.new(%x{#{curlString}})
          r = JSON.parse json_string
          if r.kind_of? Array
            h = r[1].pop
            resp = h["employee_id"].to_i
          else
            resp = r
          end
          data = nil
          if gift.provider
            employee = Employee.where(provider_id: gift.provider.id)
            data = employee.pop if employee
          end
          if !data.nil? 
              data = data.id 
          end
          save_results(resp, data, test,method_name, curlString, nil, "id compare")
      end
  end  
  
  def test_sends_only_customer_employees
      test = "Test D2"
      method_name = "test_sends_only_customer_employees"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      Gift.all.each do |gift|
          puts "gift id = #{gift.id}"
          curlString = "curl #{TEST_URL}/app/employees.json -d'token=#{@user1.remember_token}&data=#{gift.id}'"
          json_string = String.new(%x{#{curlString}})
          r = JSON.parse json_string
          h = r[1].pop
          resp = h["employee_id"].to_i
          data = nil
          if gift.provider
            employee = Employee.where(provider_id: gift.provider.id, active: true, retail: true)
            data = employee.pop if employee
          end
          if !data.nil? 
              data = data.id 
          end
          save_results(resp, data, test,method_name, curlString, nil, "id compare")
      end
  end
  
  def test_gives_correct_route_for_employee_public_photo
      test = "Test D3"
      method_name = "test_gives_correct_route_for_employee_public_photo"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      Gift.all.each do |gift|
          puts "gift id = #{gift.id}"
          curlString = "curl #{TEST_URL}/app/employees.json -d'token=#{@user1.remember_token}&data=#{gift.id}'"
          json_string = String.new(%x{#{curlString}})
          r = JSON.parse json_string
          if r == "no employees set up yet"
            r = ""
            user_photo = ""
          else
            h = r[1].pop
            resp = h["photo"]
            employee_id = h["employee_id"].to_i
            employee = Employee.find(employee_id)
            user_photo = employee.user.get_photo
          end
          save_results(resp, user_photo, test,method_name, curlString, nil, "id compare")
      end  
  end
  
  def test_gives_correct_route_for_employee_secure_image
      test = "Test D4"
      method_name = "test_gives_correct_route_for_employee_secure_image"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      Gift.all.each do |gift|
          puts "gift id = #{gift.id}"
          curlString = "curl #{TEST_URL}/app/employees.json -d'token=#{@user1.remember_token}&data=#{gift.id}'"
          json_string = String.new(%x{#{curlString}})
          r = JSON.parse json_string
          if r == "no employees set up yet"
            r = ""
            user_secure_img = ""
          else
            h = r[1].pop
            resp = h["secure_image"]
            employee_id = h["employee_id"].to_i
            employee = Employee.find(employee_id)
            user_secure_img = employee.user.secure_image
          end
          save_results(resp, user_secure_img, test,method_name, curlString, nil, "id compare") 
      end   
  end

  ###############  E TESTS 
  def e
    test_receives_complete_order_request_and_create_order
    test_server_updates_gift_object_status
    test_creates_completed_order_notification_to_giver
    test_creates_completed_order_notification_to_merchant
    test_send_payment_order_to_bank_payout
  end
  # E. server responds to complete order (redeem)
    # - server updates the order db to record the information
    # - updates the gift object 
    # - updates the notification to giver of successful gift received
    #   - using their default method (text, email , social networks)
    #   - notify giver in their app notifications   
    # - updates information to merchant of fullfilled gift
    #   - update their open apps immediately (merchant notification)
    #   - update their daily pdf reports
    # - send payment-order to bank payout db

  def test_receives_complete_order_request_and_create_order
      test = "Test E1"
      method_name = "test_receives_complete_order_request_and_create_order"
      puts "\n\n  *******     #{test} - #{method_name}     ********* " 
      #curlString = "curl #{TEST_URL}/app/complete_order.json -d'token=#{@user1.remember_token}&gift_id=#{gift.id}&employee_id=#{employee.id}'"
      #json_string = String.new(%x{#{curlString}})
      #response = JSON.parse json_string 
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT" 
    
  end

  def test_server_updates_gift_object_status
      test = "Test E2"
      method_name = "test_server_updates_gift_object_status"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT" 
    
  end
  
  def test_creates_completed_order_notification_to_giver
      test = "Test E3"
      method_name = "test_creates_completed_order_notification_to_giver"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT" 
    
  end
  
  def test_creates_completed_order_notification_to_merchant
      test = "Test E4"
      method_name = "test_creates_completed_order_notification_to_merchant"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT" 
    
  end
  
  def test_send_payment_order_to_bank_payout
      test = "Test E5"
      method_name = "test_send_payment_order_to_bank_payout"
      puts "\n\n  *******     #{test} - #{method_name}     ********* "  
      
      
      
      #save_results(response, data, test,method_name, curlString, nil, "size")
      puts "IMPLEMENT" 
    
  end

  
    ###############  F TESTS 
    def f
       test_receives_updates_for_post_gift_messages 
       test_receives_updates_for_post_gift_photos
       test_sends_notifications_to_giver_of_receiver_post_gift_actions
    end
    # F. receive data of return space and return photo urls
    #   - store data correctly
    #   - transmit new information back to giver
    
    def test_receives_updates_for_post_gift_messages
        test = "Test F1"
        method_name = "test_receives_updates_for_post_gift_messages"
        puts "\n\n  *******     #{test} - #{method_name}     ********* "  


        #save_results(response, data, test,method_name, curlString, nil, "size")
        puts "IMPLEMENT" 
    end

    def test_receives_updates_for_post_gift_photos
        test = "Test F2"
        method_name = "test_receives_updates_for_post_gift_photos"
        puts "\n\n  *******     #{test} - #{method_name}     ********* "  


        #save_results(response, data, test,method_name, curlString, nil, "size")
        puts "IMPLEMENT" 
    end

    def test_sends_notifications_to_giver_of_receiver_post_gift_actions
        test = "Test F3"
        method_name = "test_sends_notifications_to_giver_of_receiver_post_gift_actions"
        puts "\n\n  *******     #{test} - #{method_name}     ********* "  


        #save_results(response, data, test,method_name, curlString, nil, "size")
        puts "IMPLEMENT" 
    end
     
   ######## class factory methods

   
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



