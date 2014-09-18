require 'spec_helper'

describe Admt::V2::GiftCampaignsController do

    before(:each) do
        #Gift.delete_all
        AdminUser.delete_all
        @provider      = FactoryGirl.create :provider
        @campaign      = FactoryGirl.create(:campaign, purchaser_type: "AdminGiver", name: "Cinco de Mayo Party!")
        @campaign_item = FactoryGirl.create(:campaign_item, campaign_id: @campaign.id, expires_at: Time.now.to_date, provider_id: @provider.id, value: "10", cost: "8")
        @admin_user    = FactoryGirl.create(:admin_user, remember_token: "Token")
        @user          = FactoryGirl.create(:user, email: "bob@bob.com", phone: "2222222222")
        request.env["HTTP_TKN"] = "Token"
    end

    describe :create do

        it_should_behave_like("token authenticated", :post, :create)

        it "should 400 when extra or bad keys" do
            keys = ["receiver_phone", "payable_id"]

            just_right = { "receiver_phone" => "2222222222", "payable_id" => @campaign_item.id  }
            post :create, format: :json, data: just_right
            rrc 200

            too_many = { "receiver_phone" => "2222222222", "payable_id" => @campaign_item.id, "bob" => "funny" }
            post :create, format: :json, data: too_many
            rrc 400

            wrong_keys = { "phone_number" => "2222222222", "payable_id" => @campaign_item.id }
            post :create, format: :json, data: wrong_keys
            rrc 400

        end

        it "should create an campaign gift with phone" do
            create_hsh = { "receiver_phone" => "2222222222", "payable_id" => @campaign_item.id.to_s  }
            post :create, format: :json, data: create_hsh
            rrc 200

            gift        = Gift.find_by(receiver_phone: "2222222222")

            gift.provider.should      == @provider
            gift.provider_name.should == @provider.name

            gift.giver_type.should     == "Campaign"
            gift.giver_id.should       == @campaign.id
            # gift.expires_at.should     == @campaign_item.expires_at.to_datetime
            gift.receiver_name.should  == @user.name
            gift.receiver_phone.should == "2222222222"
            gift.shoppingCart.should   == @campaign_item.shoppingCart
            gift.message.should        == @campaign_item.message
            gift.value.should          == @campaign_item.value
            gift.cost.should           == @campaign_item.cost
        end

        it "should create an campaign gift with email" do
            create_hsh = { "receiver_email" => "bob@bob.com", "payable_id" => @campaign_item.id  }
            post :create, format: :json, data: create_hsh
            rrc 200

            gift        = Gift.find_by(receiver_email: "bob@bob.com")

            gift.provider.should      == @provider
            gift.provider_name.should == @provider.name

            gift.giver_type.should     == "Campaign"
            gift.giver_id.should       == @campaign.id
            # gift.expires_at.should     == @campaign_item.expires_at.to_datetime
            gift.receiver_name.should  == @user.name
            gift.receiver_email.should == "bob@bob.com"
            gift.shoppingCart.should   == @campaign_item.shoppingCart
            gift.message.should        == @campaign_item.message
            gift.value.should          == @campaign_item.value
            gift.cost.should           == @campaign_item.cost
        end

        it "should return 200 and a basic serialized gift" do
            create_hsh = { "receiver_phone" => "2222222222", "payable_id" => @campaign_item.id  }
            post :create, format: :json, data: create_hsh
            rrc 200
            json["status"].should == 1
            keys = ["updated_at", "created_at", "receiver_name", "receiver_email", "receiver_photo", "items", "shoppingCart", "value", "cost", "status", "expires_at", "cat", "detail"]
            compare_keys(json["data"], keys)
        end

        it "should return 404 when campaign item cannot be found" do
            create_hsh = { "receiver_phone" => "2222222222", "payable_id" => "99999"}
            post :create, format: :json, data: create_hsh
            rrc 404
            json["status"].should == 0
            json["data"].should == "Campaign Item 99999 could not be found"

        end

        it "should send an email to the receiver_email" do
            ResqueSpec.reset!
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            create_hsh = { "receiver_phone" => "2222222222", "payable_id" => @campaign_item.id  }
            post :create, format: :json, data: create_hsh
            rrc 200
            gift = Gift.find_by(receiver_phone: "2222222222")
            abs_gift_id = gift.id + NUMBER_ID
            run_delayed_jobs
            WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
                b = JSON.parse(req.body);
                if b["template_name"] == "iom-gift-notify-receiver"
                    link = b["message"]["merge_vars"].first["vars"].first["content"];
                    link.match(/signup\/acceptgift\?id=#{abs_gift_id}/)
                else
                    true
                end
            }.once        end

        it "should send in-network receivers a push notification" do
            ResqueSpec.reset!
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
			stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            create_hsh = { "receiver_phone" => "2222222222", "payable_id" => @campaign_item.id  }
            post :create, format: :json, data: create_hsh
            rrc 200

            good_push_hsh = {
                :aliases => ["#{@user.ua_alias}"],
                :aps => {
                    :alert => "#{@campaign.name} sent you a gift at #{@provider.name}!",
                    :badge => 1,
                    :sound =>"pn.wav"
                },
                :alert_type=>1,
                :android => {
                    :alert => "#{@campaign.name} sent you a gift at #{@provider.name}!",
                }
            }
            Urbanairship.should_receive(:push).with(good_push_hsh)
            run_delayed_jobs
        end
    end

    describe :bulk_create do
        before do
            @user_2 = FactoryGirl.create :user, first_name: "Dos", last_name: "Equis"
            @user_3 = FactoryGirl.create :user, first_name: "Trey", last_name: "Parker"
        end

        it_should_behave_like("token authenticated", :post, :create)

        it "should 400 when extra or bad keys" do

            just_right = { "payable_id" => @campaign_item.id  }
            post :bulk_create, format: :json, data: just_right
            rrc 200

            too_many = { "payable_id" => @campaign_item.id, "bob" => "funny" }
            post :bulk_create, format: :json, data: too_many
            rrc 400

            wrong_keys = { "phone_number" => "2222222222", "payable_id" => @campaign_item.id }
            post :bulk_create, format: :json, data: wrong_keys
            rrc 400

        end

        it "should create an campaign gift" do
            create_hsh = { "payable_id" => @campaign_item.id  }
            post :bulk_create, format: :json, data: create_hsh
            rrc 200
            gift = Gift.find_by(receiver_id: @user_2.id)
            gift.provider.should      == @provider
            gift.provider_name.should == @provider.name
            gift.giver_type.should     == "Campaign"
            gift.giver_id.should       == @campaign.id
            gift.receiver_name.should  == "Dos Equis"
            gift.shoppingCart.should   == @campaign_item.shoppingCart
            gift.message.should        == @campaign_item.message
            gift.value.should          == @campaign_item.value
            gift.cost.should           == @campaign_item.cost
        end

        it "should return 200 and a success message" do
            create_hsh = { "payable_id" => @campaign_item.id  }
            post :bulk_create, format: :json, data: create_hsh
            rrc 200
            json["status"].should == 1
            json["data"].should == "Created gifts for Campaign Item #{@campaign_item.id}"
        end

        it "should return 404 when campaign item cannot be found" do
            create_hsh = { "payable_id" => "99999"}
            post :bulk_create, format: :json, data: create_hsh
            rrc 404
            json["status"].should == 0
            json["data"].should == "Campaign Item 99999 could not be found"

        end

        it "should send an email to the receiver_email" do
            ResqueSpec.reset!
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            create_hsh = { "payable_id" => @campaign_item.id  }
            post :bulk_create, format: :json, data: create_hsh
            rrc 200
            gift = Gift.find_by(receiver_id: @user_2.id)
            abs_gift_id = gift.id + NUMBER_ID
            run_delayed_jobs
            WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
                b = JSON.parse(req.body);
                if b["template_name"] == "gift"
                    link = b["message"]["merge_vars"].first["vars"].first["content"];
                    link.match(/signup\/acceptgift\?id=#{abs_gift_id}/)
                else
                    true
                end
            }.once
        end

        it "should send in-network receivers a push notification" do
            ResqueSpec.reset!
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            create_hsh = { "payable_id" => @campaign_item.id  }
            post :bulk_create, format: :json, data: create_hsh
            rrc 200

            Urbanairship.should_receive(:push).exactly(3).times
            run_delayed_jobs
        end
    end
end
