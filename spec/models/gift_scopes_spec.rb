require 'spec_helper'

describe GiftScopes do

    context "provider scopes" do

        before(:each) do
            Provider.delete_all
            User.delete_all
            Gift.delete_all
            Order.delete_all
            Redeem.delete_all
            @provider = FactoryGirl.create(:provider)
            @number = 10
            @number.times do
                FactoryGirl.create(:gift,   {:provider => nil, :provider_id => @provider.id, :provider_name => @provider.name }) # 10 incomplete  gifts
                FactoryGirl.create(:redeem) # 10 notified gifts
                FactoryGirl.create(:order) # 10 redeemed gifts
                FactoryGirl.create(:regift, {:provider => nil, :provider_id => @provider.id, :provider_name => @provider.name }) # 10 open gifts
            end
            gs = Gift.all
            gs.each do |g|
                g.provider_name = @provider.name
                g.provider_id   = @provider.id
                g.save
            end
            os = Order.all
            os.each do |o|
                o.provider_id = @provider.id
                o.save
            end
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
                gift.update_attribute(:status, 'redeemed')

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
                    gift.update_attribute(:status, status)
                end
                response = Gift.get_archive user
                response[1].count.should == 13
            end

        end

        describe :badge do

            it "should return correct badges for in-app and for springboard" do
                User.delete_all
                Provider.delete_all
                @user     = FactoryGirl.create(:user)
                2.times do
                    gift = FactoryGirl.create(:gift, receiver: @user, provider_name: "Redeemed", status: 'redeemed')
                    redeem = Redeem.create(gift_id: gift.id)
                    Order.create(gift_id: gift.id, redeem_id: redeem.id)
                end

                    # these are for the springboard and the in-app badge
                FactoryGirl.create(:gift, receiver: @user)
                FactoryGirl.create(:gift, receiver: @user)
                FactoryGirl.create(:gift, receiver: @user)

                    # do not count these
                2.times do
                    gift = FactoryGirl.create(:gift, receiver: @user,pay_stat: 'unpaid', status: 'open')
                end
                2.times do
                    gift = FactoryGirl.create(:gift, receiver: @user,pay_stat: 'duplicate', status: 'open')
                end
                2.times do
                    gift = FactoryGirl.create(:gift, receiver: @user,pay_stat: 'declined', status: 'open')
                end

                    # these are for the badge in-app only - not the springboard
                3.times do
                    gift = FactoryGirl.create(:gift, receiver: @user, pay_stat: 'charged')
                    Redeem.create(gift_id: gift.id)
                end

                    # do not count these
                2.times do
                    gift = FactoryGirl.create(:gift, receiver: @user,pay_stat: 'unpaid', status: 'open')
                    Redeem.create(gift_id: gift.id)
                end
                2.times do
                    gift = FactoryGirl.create(:gift, receiver: @user,pay_stat: 'duplicate', status: 'open')
                    Redeem.create(gift_id: gift.id)
                end
                2.times do
                    gift = FactoryGirl.create(:gift, receiver: @user,pay_stat: 'declined', status: 'open')
                    Redeem.create(gift_id: gift.id)
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