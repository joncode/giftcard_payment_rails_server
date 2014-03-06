require 'spec_helper'

describe SlicktextGateway do

    before(:each) do
        @user = FactoryGirl.create(:user)
        @campaign      = FactoryGirl.create(:campaign)
        @campaign_item = FactoryGirl.create(:campaign_item, campaign_id: @campaign.id, textword:"11111")
        @sample_response = "{\"meta\":{\"limit\":20,\"offset\":0,\"total\":2},\"links\":{\"self\":\"http://api.slicktext.com/v1/contacts/\"},\"contacts\":[{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":111,\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"}]}"
    end

    context "contacts" do

        it "should set status to 200 when successful" do
            textword = @campaign_item.textword
            limit    = 1000
        	route = SLICKTEXT_URL + "/#{textword}/contacts?limit=#{limit}"
            stub_request(:get, route).with(:body => "data=", :headers => {'Accept'=>'application/json', 'Authorization'=>"#{SLICKTEXT_API_KEY}"}).to_return(:status => 200, :body => @sample_response )
            
            response = SlicktextGateway.new(textword: textword, limit: 1000)
            response.contacts.should       == [{"service_id"}]
            response.status.should         == 200
            response.limit.should          == 1000
            response.textword.should       == "11111"
        end

    end

end



