require 'spec_helper'

approved = "#<AuthorizeNet::AIM::Response:0x007fe7a9d958d0 @version='3.1', @raw_response=#<Net::HTTPOK 200 OK readbody=true>, @fields={:response_code=>'1', :response_subcode=>'1', :response_reason_code=>'1', :response_reason_text=>'This transaction has been approved.', :authorization_code=>'JVT36N', :avs_response=>'Y', :transaction_id=>'2202633834', :invoice_number=>'', :description=>'', :amount=>#<BigDecimal:7fe7a9d9ed68,'0.1E3',9(18)>, :method=>'CC', :transaction_type=>'auth_capture', :customer_id=>'', :first_name=>'Jimbo', :last_name=>'Snake', :company=>'', :address=>'', :city=>'', :state=>'', :zip_code=>'', :country=>'', :phone=>'', :fax=>'', :email_address=>'', :ship_to_first_name=>'', :ship_to_last_name=>'', :ship_to_company=>'', :ship_to_address=>'', :ship_to_city=>'', :ship_to_state=>'', :ship_to_zip_code=>'', :ship_to_country=>'', :tax=>#<BigDecimal:7fe7a9d9df08,'0.0',9(9)>, :duty=>#<BigDecimal:7fe7a9d9dd28,'0.0',9(9)>, :freight=>#<BigDecimal:7fe7a9d9da30,'0.0',9(9)>, :tax_exempt=>'', :purchase_order_number=>'AD-23-40', :md5_hash=>'8EF9AB71098AE0B08C197AC7203B6DB4', :card_code_response=>'', :cardholder_authentication_verification_response=>'2', :account_number=>'XXXX0002', :card_type=>'American Express'}, @transaction=#<AuthorizeNet::AIM::Transaction:0x007fe7a9cd7a38 @fields={:first_name=>'Jimbo', :last_name=>'Snake', :po_num=>'AD-23-40', :method=>'CC', :card_num=>370000000000002, :exp_date=>'1215', :amount=>'100.00'}, @custom_fields={}, @test_mode=false, @version='3.1', @api_login_id='948bLpzeE8UY', @api_transaction_key='7f7AZ66axeC386q7', @response=#<AuthorizeNet::AIM::Response:0x007fe7a9d958d0 ...>, @delimiter='', @type='AUTH_CAPTURE', @cp_version=nil, @gateway='https://test.authorize.net/gateway/transact.dll', @allow_split_transaction=false, @encapsulation_character=nil, @verify_ssl=false, @market_type=2, @device_type=1>, @custom_fields={}>"
    
describe AppController do

    describe "#create_gift" do

        before(:each) do
            Gift.delete_all
            User.delete_all
            UserSocial.delete_all
            @user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password" }
            @token = @user.remember_token
            @receiver = FactoryGirl.create(:receiver)
            @card = FactoryGirl.create(:card, name: @user.name, user_id: @user.id)
        end

        it "should not send nil to add_giver" do
            Card.any_instance.stub(:decrypt!).and_return("4111000011110000")
            Card.any_instance.stub(:number).and_return("4111000011110000")
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => approved, :headers => {})
            Sale.any_instance.stub(:resp_code).and_return(1)
            Sale.any_instance.stub(:reason_code).and_return(1)
            Sale.any_instance.stub(:reason_text).and_return("Transaction approved")
            params_hsh  = {"gift"=>"{  \"twitter\" : \"875818226\",  \"receiver_email\" : \"ta@ta.com\",  \"receiver_phone\" : \"2052920036\",  \"giver_name\" : \"Addis Dev\",  \"service\" : 0.5,  \"total\" : 10,  \"provider_id\" : 58,  \"receiver_id\" : #{@receiver.id},  \"message\" : \"\",  \"credit_card\" : #{@card.id},  \"provider_name\" : \"Artifice\",  \"receiver_name\" : \"Addis Dev\",  \"giver_id\" : #{@user.id}}","origin"=>"d","shoppingCart"=>"[{\"detail\":\"\",\"price\":10,\"item_name\":\"The Warhol\",\"item_id\":32,\"quantity\":1}]","token"=> @token}
            post :create_gift, format: :json, gift: params_hsh["gift"] , shoppingCart: params_hsh["shoppingCart"], token: params_hsh["token"]

            g_id = json["success"]["Gift_id"]
            gift = Gift.find g_id
            gift.giver_name.should == @user.name
        end

    end

    describe "#create_gift" do

        before(:each) do
            Gift.delete_all
            User.delete_all
            UserSocial.delete_all
            @user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password" }
            @cart = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            @card = FactoryGirl.create(:card, :name => @user.name, :user_id => @user.id)
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,31.50,CC,auth_capture,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
        end

        {
            email: "jon@gmail.com",
            phone: "9173706969",
            facebook_id: "123",
            twitter: "999"
        }.stringify_keys.each do |type_of, identifier|
            it "should find user account for old #{type_of}" do
                # take a user , add an email
                @user.update_attribute(type_of, identifier)
                # then we hit create gift
                # with receiver email = old email
                if (type_of == "phone") || (type_of == "email")
                    key = "receiver_#{type_of}"
                else
                    key = type_of
                end
                gift = FactoryGirl.build :gift, { key => identifier, "credit_card" => @card.id}
                post :create_gift, format: :json, gift: set_gift_as_sent(gift, key) , shoppingCart: @cart , token: @user.remember_token
                new_gift = Gift.find(json["success"]["Gift_id"])
                new_gift.receiver_id.should == @user.id
            end

            it "should look thru multiple unique ids for a user object with #{type_of}" do
                # add one unique id to the user record
                @user.update_attribute(type_of, identifier)
                # create a gift with multiple new social ids
                gift_social_id_hsh["credit_card"] = @card.id
                gift = FactoryGirl.build :gift, gift_social_id_hsh
                gift.credit_card = @card.id
                post :create_gift, format: :json, gift: create_multiple_unique_gift(gift) , shoppingCart: @cart , token: @user.remember_token
                # check that the :action assign the user_id to receiver_id and saves the gift
                new_gift = Gift.find(json["success"]["Gift_id"])
                new_gift.receiver_id.should == @user.id
            end

            it "should look thru not full gift of unique ids for a user object with #{type_of}" do
                # add one unique id to the user record
                @user.update_attribute(type_of, identifier)
                # create a gift with multiple new social ids
                gift_social_id_hsh["credit_card"] = @card.id
                missing_hsh = gift_social_id_hsh
                if type_of == "phone"
                    missing_hsh["receiver_email"] = ""
                else
                    missing_hsh["receiver_phone"] = ""
                end
                gift = FactoryGirl.build :gift, missing_hsh
                gift.credit_card = @card.id
                post :create_gift, format: :json, gift: create_multiple_unique_gift(gift, missing_hsh) , shoppingCart: @cart , token: @user.remember_token
                # check that the :action assign the user_id to receiver_id and saves the gift
                new_gift = Gift.find(json["success"]["Gift_id"])
                new_gift.receiver_id.should == @user.id
            end
        end

        # Git should validate total and service

    end

    describe "#create_gift security" do

        before do
            Gift.delete_all
            User.delete_all
            @cart = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"

        end

        it "it should not allow gift creating for de-activated givers" do

            deactivated_user = FactoryGirl.create :user, { active: false}
            # hit create gift with a receiver_id of a deactivated user
            gift = FactoryGirl.create :gift, { receiver_id: deactivated_user.id }
            # test that create gift does not create the gift or the sale
            post :create_gift, format: :json, gift: make_gift_json(gift) , shoppingCart: @cart , token: deactivated_user.remember_token
            rrc(401)
        end

        it "it should not allow gift creating for de-activated receivers" do
            giver = FactoryGirl.create(:giver)
            deactivated_user = FactoryGirl.create :receiver, { active: false}
            # hit create gift with a receiver_id of a deactivated user
            gift = FactoryGirl.create :gift, { receiver_id: deactivated_user.id }
            # test that create gift does not create the gift or the sale
            post :create_gift, format: :json, gift: make_gift_json(gift) , shoppingCart: @cart , token: giver.remember_token
            puts "here is the response #{json["success"]}"
            json["success"].should be_nil
            # test that a message returns that says the user is no longer in the system , please gift to them with a non-drinkboard identifier
            json["error"].should == 'User is no longer in the system , please gift to them with phone, email, facebook, or twitter'
        end

        it "should not charge the card when gift receiver is deactivated" do
            giver = FactoryGirl.create(:giver)
            deactivated_user = FactoryGirl.create :receiver, { active: false}
            gift = FactoryGirl.build :gift, { receiver_id: deactivated_user.id }
            post :create_gift, format: :json, gift: make_gift_json(gift) , shoppingCart: @cart , token: giver.remember_token
            new_gift = Gift.find_by(receiver_id: deactivated_user.id)
            new_gift.should be_nil
            last = Gift.last
            last.should be_nil
        end

        it "should not allow gift creation for non-app users -- AdminGiver" do
            giver = FactoryGirl.create(:giver)
            admin_user = FactoryGirl.create(:admin_user)
            receiver = admin_user.giver
            gift  = FactoryGirl.build :gift
            gift_hsh = JSON.parse(make_gift_json(gift))
            gift_hsh["receiver_id"]   = receiver.id
            gift_hsh["receiver_name"] = receiver.name
            post :create_gift, format: :json, gift: gift_hsh.to_json , shoppingCart: @cart , token: giver.remember_token
            new_gift = Gift.find_by(giver_id: giver.id)
            new_gift.should be_nil
            json["success"].should be_nil
            json["error"].should == "You cannot gift to the ItsOnMe Staff account"
        end

        it "should not allow gift creation for non-app users -- BizUser" do
            giver = FactoryGirl.create(:giver)
            provider = FactoryGirl.create(:provider)
            receiver = provider.biz_user
            gift  = FactoryGirl.build :gift
            gift_hsh = JSON.parse(make_gift_json(gift))
            gift_hsh["receiver_id"]   = receiver.id
            gift_hsh["receiver_name"] = receiver.name
            post :create_gift, format: :json, gift: gift_hsh.to_json , shoppingCart: @cart , token: giver.remember_token
            new_gift = Gift.find_by(giver_id: giver.id)
            new_gift.should be_nil
            json["success"].should be_nil
            json["error"].should == "You cannot gift to the #{provider.biz_user.name} account"
        end

        it "should create gift for user with last name 'Staff'" do
            giver = FactoryGirl.create(:giver)
            @user = giver
            @card = FactoryGirl.create(:card, :name => @user.name, :user_id => @user.id)
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,31.50,CC,auth_capture,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

            receiver = FactoryGirl.create(:receiver, last_name: "Staff")
            gift  = FactoryGirl.build :gift
            gift_hsh = JSON.parse(make_gift_json(gift))
            gift_hsh["receiver_id"]   = receiver.id
            gift_hsh["receiver_name"] = receiver.name
            gift_hsh["credit_card"]   = @card.id
            post :create_gift, format: :json, gift: gift_hsh.to_json , shoppingCart: @cart , token: giver.remember_token
            new_gift = Gift.find_by(giver_id: giver.id)
            new_gift.receiver.should == receiver
            json["error"].should be_nil
        end
    end

    def make_gift_json gift
        {
            giver_id:       1,
            giver_name:     "French",
            total:          gift.total,
            service:        gift.service,
            receiver_id:    gift.receiver_id,
            receiver_name:  gift.receiver_name,
            provider_id:    gift.provider.id,
            credit_card:    gift.credit_card
        }.to_json
    end

    def gift_social_id_hsh
        {
            receiver_email: "jon@gmail.com",
            receiver_phone: "9173706969",
            facebook_id: "123",
            twitter: "999"
        }
    end

    def create_multiple_unique_gift gift, missing_hsh=nil
        missing_hsh ||= gift_social_id_hsh
        {
            total:          gift.total,
            service:        gift.service,
            receiver_name:  gift.receiver_name,
            provider_id:    gift.provider.id,
            credit_card:    gift.credit_card
        }.merge(missing_hsh).to_json
    end

    def set_gift_as_sent gift, key
        {
            key => gift.send(key),
            total: gift.total,
            service: gift.service,
            receiver_name:  gift.receiver_name,
            provider_id:    gift.provider.id,
            credit_card:    gift.credit_card
        }.to_json
    end

end