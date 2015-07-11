require 'spec_helper'

describe GiftScopes do

    before(:each) do
        User.any_instance.stub(:init_confirm_email).and_return(true)
    end

    context "provider scopes" do

        before(:each) do
            @provider = FactoryGirl.create(:merchant)
            @number = 10
            @number.times do
                FactoryGirl.create(:gift,   {:merchant => nil, :merchant_id => @provider.id, :provider_name => @provider.name }) # 10 incomplete  gifts
                FactoryGirl.create(:regift, {:merchant => nil, :merchant_id => @provider.id, :provider_name => @provider.name }) # 10 open gifts
            end
            gs = Gift.all
            gs.each do |g|
                g.provider_name = @provider.name
                g.merchant_id   = @provider.id
                g.save
            end
            # os = Order.all
            # os.each do |o|
            #     o.merchant_id = @provider.id
            #     o.save
            # end
        end

        describe :get_provider do

            it "should get all incomplete / open / notified gifts for a provider" do
                gifts = Gift.get_provider(@provider)
                incomplete  = Gift.where(status: 'incomplete')
                open        = Gift.where(status: 'open')
                notified    = Gift.where(status: 'notified')
                total       = incomplete + open + notified
                gifts.count.should == total.count
            end

        end

        describe :get_history_provider do

            it "should get all redeemed gifts for a provider" do
                gifts    = Gift.get_history_provider(@provider)
                redeemed = Order.all
                gifts.count.should == redeemed.count
            end

        end

    end

    context "user scopes" do

        describe :get_archive do

            it "should return and array = [ given gifts , received gifts ] " do
                user = FactoryGirl.create(:simple_user)

                FactoryGirl.create(:gift, :giver => user, :giver_name => user.name)
                gift = FactoryGirl.build(:gift)
                gift.add_receiver user
                gift.save
                gift.reload
                gift.update(status: 'redeemed')

                response = Gift.get_archive user
                response.class.should == Array
                response[0][0].giver_id.should == user.id
                response[1][0].receiver_id.should == user.id
            end

            it "should return regifted and redeemed gifts with received gifts" do
                user = FactoryGirl.create(:simple_user)

                13.times do |index|
                    if index.even?
                        status = 'redeemed'
                    else
                        status = 'regifted'
                    end
                    gift = FactoryGirl.build(:gift)
                    gift.add_receiver user
                    gift.save
                    gift.reload
                    gift.update(status: status)
                end
                response = Gift.get_archive user
                response[1].count.should == 13
            end

        end

        describe :badge do

            it "should return correct badges for in-app and for springboard" do

                User.delete_all
                Merchant.delete_all
                @user     = FactoryGirl.create(:user)
                2.times do
                    gift = FactoryGirl.create(:gift, receiver: @user, provider_name: "Redeemed", status: 'redeemed')
                    gift.notify
                    gift.redeem_gift
                end

                    # these are for the springboard and the in-app badge
                FactoryGirl.create(:gift, receiver: @user)
                FactoryGirl.create(:gift, receiver: @user)
                FactoryGirl.create(:gift, receiver: @user)

                    # do not count these
                2.times do
                    Sale.any_instance.stub(:resp_code).and_return(2)
                    gift = FactoryGirl.create(:gift, receiver: @user)
                end
                2.times do
                    Sale.any_instance.stub(:resp_code).and_return(2)
                    gift = FactoryGirl.create(:gift, receiver: @user)
                end
                2.times do
                    Sale.any_instance.stub(:resp_code).and_return(2)
                    gift = FactoryGirl.create(:gift, receiver: @user)
                end

                    # these are for the badge in-app only - not the springboard
                3.times do
                    Sale.any_instance.stub(:resp_code).and_return(1)
                    gift = FactoryGirl.create(:gift, receiver: @user)
                   gift.notify
                end

                    # do not count these
                2.times do
                    Sale.any_instance.stub(:resp_code).and_return(2)
                    gift = FactoryGirl.create(:gift, receiver: @user)
                    gift.notify
                end
                2.times do
                    Sale.any_instance.stub(:resp_code).and_return(2)
                    gift = FactoryGirl.create(:gift, receiver: @user)
                    gift.notify
                end
                2.times do
                    Sale.any_instance.stub(:resp_code).and_return(2)
                    gift = FactoryGirl.create(:gift, receiver: @user)
                    gift.notify
                end
                gift_count = Gift.get_notifications @user
                gift_count.should  == 3

                gifts = Gift.get_gifts @user
                gifts.count.should == 6
            end

        end


    end




end



        # data  = params["data"]
        # if data.kind_of? Hash
        #     if data["page"] == "new"
        #         gifts = Gift.get_provider(@provider)
        #     elsif data["page"]  == 'reports'

        #         start_time = data["start_time"].to_datetime if data["start_time"]
        #         end_time   = data["end_time"].to_datetime   if data["end_time"]
        #         puts "hitting the date correct #{start_time}|#{end_time}"
        #         gifts = Gift.get_history_provider_and_range(@provider, start_time, end_time )
        #     end
        # else
        #     gifts = Gift.get_history_provider(@provider)
        # end