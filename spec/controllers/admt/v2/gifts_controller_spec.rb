require 'spec_helper'

describe Admt::V2::GiftsController do

    before(:each) do
        #Gift.delete_all
        @provider = FactoryGirl.create(:provider)
        unless @admin_user = AdminUser.find_by(remember_token: "Token")
            @admin_user = FactoryGirl.create(:admin_user, remember_token: "Token")
        end
        @user = FactoryGirl.create(:user)
        request.env["HTTP_TKN"] = "Token"
    end

    describe :update do

        it_should_behave_like("token authenticated", :put, :update, id: 1)

        let(:gift) { FactoryGirl.create(:gift_no_association, giver: @user, giver_id: @user.id, provider: @provider) }

        it "should require a valid gift_id" do
            destroy_id = gift.id
            gift.destroy
            put :update, id: destroy_id, format: :json, data: { "receiver_name" => "JonBoy Shark"}
            response.response_code.should  == 404
        end

        it "should require a update hash" do
            put :update, id: gift.id, format: :json, data: "updated data"
            rrc(400)
            put :update, id: gift.id, format: :json, data: nil
            rrc(400)
            put :update, id: gift.id, format: :json
            rrc(400)
            put :update, id: gift.id, format: :json, data: { "receiver_name" => "Jon Goodness"}
            rrc(200)
        end

        it "should return success msg when success" do
            put :update, id: gift.id, format: :json, data: { "receiver_name" => "Jon Goodness"}
            json["status"].should == 1
            json["data"].should   == "#{gift.id} updated"
        end

        it "should return validation errors" do
            put :update, id: gift.id, format: :json, data: { "receiver_name" => "" }
            json["status"].should == 0
            json["data"].class.should   == Hash
        end

        {
            receiver_name: "Ray Davies",
            receiver_email: "ray@davies.com",
            receiver_phone: "5877437859"
        }.stringify_keys.each do |type_of, value|

            it "should update the gift information in database" do
                put :update, id: gift.id, format: :json, data: { type_of => value }
                new_gift = Gift.last
                new_gift.send(type_of).should == value

            end
        end

        it "should not update attributes that are not allowed or dont exist" do
            hsh = { "house" => "chill" }
            put :update, id: gift.id, format: :json, data: hsh
            rrc(400)
        end

        it "should update from these params" do
            g_params = {"receiver_name"=>"Addis Dev", "receiver_email"=>"ta2@ta.com", "receiver_phone"=>"2052920036"}
            put :update, id: gift.id, format: :json, data: g_params
            response.response_code == 200
            json["status"].should == 1
            gift.reload
            gift.receiver_name.should == g_params["receiver_name"]
            gift.receiver_email.should == g_params["receiver_email"]
            gift.receiver_phone.should == g_params["receiver_phone"]
            json["data"].should_not be_nil

        end

    end

    describe :refund do

        it_should_behave_like("token authenticated", :put, :refund, id: 1)

        context "behavior" do

            let(:gift) { FactoryGirl.create(:gift_no_association, provider: @provider, giver: @user, giver_id: @user.id, pay_stat: 'charged', status: 'open') }


            it "should set the gift 'pay_stat' to 'refunded' and not change the gift status" do
                AuthorizeNet::AIM::Transaction.any_instance.stub(:void).and_return(AuthResponse.new)
                post :refund, id: gift.id, format: :json
                new_gift = Gift.find gift.id
                new_gift.pay_stat.should == "refunded"
                new_gift.status.should   == gift.status
            end

            it "should not 500 when sending back 'reason text' for 'A valid referenced transaction ID is required.'" do
                auth_response_json = "{\"response_code\":\"3\",\"response_subcode\":\"2\",\"response_reason_code\":\"33\",\"response_reason_text\":\"A valid referenced transaction ID is required.\",\"authorization_code\":\"\",\"avs_response\":\"P\",\"transaction_id\":\"0\",\"invoice_number\":\"\",\"description\":\"\",\"amount\":0.0,\"method\":\"CC\",\"transaction_type\":\"void\",\"customer_id\":\"\",\"first_name\":\"\",\"last_name\":\"\",\"company\":\"\",\"address\":\"\",\"city\":\"\",\"state\":\"\",\"zip_code\":\"\",\"country\":\"\",\"phone\":\"\",\"fax\":\"\",\"email_address\":\"\",\"ship_to_first_name\":\"\",\"ship_to_last_name\":\"\",\"ship_to_company\":\"\",\"ship_to_address\":\"\",\"ship_to_city\":\"\",\"ship_to_state\":\"\",\"ship_to_zip_code\":\"\",\"ship_to_country\":\"\",\"tax\":0.0,\"duty\":0.0,\"freight\":0.0,\"tax_exempt\":\"\",\"purchase_order_number\":\"\",\"md5_hash\":\"87C72AD0D50F84E05E8E833C16D41192\"}"
                AuthorizeNet::AIM::Transaction.any_instance.stub(:void).and_return(AuthResponse.new(auth_response_json))
                post :refund, id: gift.id, format: :json
                json["status"].should == 0
                json["data"].should   == "A valid referenced transaction ID is required."
            end

        end
    end

    describe :refund_cancel do

        it_should_behave_like("token authenticated", :put, :refund_cancel, id: 1)

        context "behavior" do

            let(:gift) { FactoryGirl.create(:gift_no_association, provider: @provider, giver: @user, giver_id: @user.id, pay_stat: 'charged', status: 'open') }

            it "should set the gift 'pay_stat' to 'refunded' " do
                AuthorizeNet::AIM::Transaction.any_instance.stub(:void).and_return(AuthResponse.new)
                post :refund_cancel, id: gift.id, format: :json
                new_gift = Gift.find gift.id
                new_gift.pay_stat.should == "refunded"
                new_gift.status.should   == 'cancel'
            end

            it "should not 500 when sending back 'reason text' for 'A valid referenced transaction ID is required.'" do
                auth_response_json = "{\"response_code\":\"3\",\"response_subcode\":\"2\",\"response_reason_code\":\"33\",\"response_reason_text\":\"A valid referenced transaction ID is required.\",\"authorization_code\":\"\",\"avs_response\":\"P\",\"transaction_id\":\"0\",\"invoice_number\":\"\",\"description\":\"\",\"amount\":0.0,\"method\":\"CC\",\"transaction_type\":\"void\",\"customer_id\":\"\",\"first_name\":\"\",\"last_name\":\"\",\"company\":\"\",\"address\":\"\",\"city\":\"\",\"state\":\"\",\"zip_code\":\"\",\"country\":\"\",\"phone\":\"\",\"fax\":\"\",\"email_address\":\"\",\"ship_to_first_name\":\"\",\"ship_to_last_name\":\"\",\"ship_to_company\":\"\",\"ship_to_address\":\"\",\"ship_to_city\":\"\",\"ship_to_state\":\"\",\"ship_to_zip_code\":\"\",\"ship_to_country\":\"\",\"tax\":0.0,\"duty\":0.0,\"freight\":0.0,\"tax_exempt\":\"\",\"purchase_order_number\":\"\",\"md5_hash\":\"87C72AD0D50F84E05E8E833C16D41192\"}"
                AuthorizeNet::AIM::Transaction.any_instance.stub(:void).and_return(AuthResponse.new(auth_response_json))
                post :refund_cancel, id: gift.id, format: :json
                json["status"].should == 0
                json["data"].should   == "A valid referenced transaction ID is required."
            end

        end
    end

    describe :add_receiver do

        it_should_behave_like("token authenticated", :post, :add_receiver, id: 1)

        context "gift has no receiver ID but unique receiver info - merge" do

            it "should merge user_id with receiver id and gift-uniques info with user_socials" do
                gift = FactoryGirl.create(:gift, :facebook_id => "100005220484939")
                user = FactoryGirl.create(:user, :email => "christie.parker@gmail.com", phone: "7025237365")
                post :add_receiver, id: gift.id, data: user.id, format: :json
                json["status"].should == 1
                rrc 200

                gift.reload
                gift.receiver_id.should == user.id
                user = User.find_by(email: "christie.parker@gmail.com")
                user.phone.should       == "7025237365"
                user.facebook_id.should == "100005220484939"

                gift = FactoryGirl.create(:gift, :twitter => "100005220484939")
                user = FactoryGirl.create(:user, :email => "christie.parker2@gmail.com", phone: "7035237365")
                post :add_receiver, id: gift.id, data: user.id, format: :json
                json["status"].should == 1
                rrc 200

                gift.reload
                gift.receiver_id.should == user.id
                user = User.find_by(email: "christie.parker2@gmail.com")
                user.phone.should       == "7035237365"
                user.twitter.should == "100005220484939"

                gift = FactoryGirl.create(:gift, :receiver_email => "new@gmail.com")
                user = FactoryGirl.create(:user, :email => "christie.parker4@gmail.com", phone: "7045237365")
                post :add_receiver, id: gift.id, data: user.id, format: :json
                json["status"].should == 1
                rrc 200

                gift.reload
                gift.receiver_id.should == user.id
                user = User.find_by(phone: "7045237365")
                user.email.should == "new@gmail.com"
            end
        end

        context "gift has the wrong receiver - changing receivers" do

            it "should remove old receiver info and add new receiver info and NOT merge socials" do
                bad_rec  = FactoryGirl.create(:user, email: "bad@receiver.com")
                good_rec = FactoryGirl.create(:user, email: "christie.parker@gmail.com", phone: "7025237365")
                gift = FactoryGirl.create(:gift)
                gift.remove_receiver
                gift.add_receiver(bad_rec)
                gift.save

                post :add_receiver, id: gift.id, data: good_rec.id, format: :json
                good_rec.reload
                good_rec.email.should_not == "bad@receiver.com"
            end


        end

    end

end


























