require 'spec_helper'

describe GiftScopes do

    before(:each) do
        @provider = FactoryGirl.create(:provider)
        @number = 10
        @number.times do
            #FactoryGirl.create(:gift,   :provider => provider) # 10 incomplete  gifts
            #FactoryGirl.create(:redeem, :provider => provider) # 10 notified gifts
            #FactoryGirl.create(:order,  :provider => provider) # 10 redeemed gifts
            FactoryGirl.create(:regift, :provider => @provider) # 10 open gifts
        end

    end

    it "should get all open / notified gifts for a provider" do

        gifts = Gift.get_provider(provider)
        gifts.count.should == 20

    end

    it "should get all redeemed gifts for a provider" do
        gifts = Gift.get_history_provider(provider)
        gifts.count.should == 10
    end

    it "should get all redeemed gifts for a provider given a date range" do
         # go into the db and add different start times and redeemed at times
        gifts = Gift.get_history_provider_and_range(provider, start_time, end_time )
        gifts.count.should == 10
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