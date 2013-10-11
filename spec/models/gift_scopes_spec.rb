require 'spec_helper'

describe GiftScopes do

    before(:all) do
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

    it "should get all incomplete / open / notified gifts for a provider" do
        gifts = Gift.get_provider(@provider)
        incomplete  = Gift.where(status: 'incomplete')
        open        = Gift.where(status: 'open')
        notified    = Gift.where(status: 'notified')
        total       = incomplete + open + notified
        gifts.count.should == total.count
    end

    it "should get all redeemed gifts for a provider" do
        gifts    = Gift.get_history_provider(@provider)
        redeemed = Order.all
        gifts.count.should == redeemed.count
    end

    # it "should get all redeemed gifts for a provider given a date range" do
    #      # go into the db and add different start times and redeemed at times
    #     gifts = Gift.get_history_provider_and_range(provider, start_time, end_time )
    #     gifts.count.should == 10
    # end






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