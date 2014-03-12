require 'spec_helper'

describe SlicktextGateway do

    before(:each) do
        @user = FactoryGirl.create(:user)
        @campaign      = FactoryGirl.create(:campaign)
        @campaign_item = FactoryGirl.create(:campaign_item, campaign_id: @campaign.id, textword: "itsonme")
        @sample_response = "{\"meta\":{\"limit\":20,\"offset\":0,\"total\":2},\"links\":{\"self\":\"http://api.slicktext.com/v1/contacts/\"},\"contacts\":[{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"},{\"id\":11111,\"number\":\"+5555555555\",\"city\":\"null\",\"state\":\"null\",\"zipCode\":\"null\",\"country\":\"null\",\"textword\":\"itsonme\",\"subscribedDate\":\"2013-02-04 21:12:45\",\"firstName\":\"null\",\"lastName\":\"null\",\"birthDate\":\"null\"}]}"
        @sample_response =  {"meta"=>{"limit"=>20, "offset"=>0, "total"=>2}, "links"=>{"self"=>"http://api.slicktext.com/v1/contacts/"}, "contacts"=>[{"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}, {"id"=>11111, "number"=>"+5555555555", "city"=>"null", "state"=>"null", "zipCode"=>"null", "country"=>"null", "textword"=>"itsonme", "subscribedDate"=>"2013-02-04 21:12:45", "firstName"=>"null", "lastName"=>"null", "birthDate"=>"null"}]}
    end

    describe :contacts do

        it "should set  limit / textword / status to 200 when successful" do
            textword = @campaign_item.textword
            limit    = 1000
            route = SLICKTEXT_URL + "/#{textword}/contacts?limit=#{limit}"
            stub_request(:get, route).with(:body => "data=", :headers => {'Accept'=>'application/json', 'Authorization'=>"Basic #{SLICKTEXT_PRIVATE}"}).to_return(:status => 200, :body => @sample_response )

            stg_obj = SlicktextGateway.new(textword: textword, limit: 1000)
            stg_obj.contacts
            stg_obj.status.should   == 200
            stg_obj.limit.should    == 1000
            stg_obj.textword.should == "itsonme"
        end

        it "should handle a 403 response" do
            sample_response =  {"meta"=>{"link"=>"http://api.slicktext.com/v1/textwords/itsonme/contacts?limit=1000"}, "error"=>{"message"=>"You do not have permission to access the resource at /v1/textwords/itsonme/contacts?limit=1000"}}
            textword = @campaign_item.textword
            limit    = 1000
            route = SLICKTEXT_URL + "/#{textword}/contacts?limit=#{limit}"
            stub_request(:get, route).with(:body => "data=", :headers => {'Accept'=>'application/json', 'Authorization'=>"Basic #{SLICKTEXT_PRIVATE}"}).to_return(:status => 200, :body => sample_response )
            stg_obj = SlicktextGateway.new(textword: textword, limit: 1000)
            stg_obj.contacts
            stg_obj.status.should   == 403
            stg_obj.limit.should    == 1000
            stg_obj.textword.should == "itsonme"
        end

        it "should return contact array with generic format" do
            textword = @campaign_item.textword
            limit    = 1000
            route = SLICKTEXT_URL + "/#{textword}/contacts?limit=#{limit}"
            stub_request(:get, route).with(:body => "data=", :headers => {'Accept'=>'application/json', 'Authorization'=>"Basic #{SLICKTEXT_PRIVATE}"}).to_return(:status => 200, :body => @sample_response )

            stg_obj = SlicktextGateway.new(textword: textword, limit: 1000)
            contacts = stg_obj.contacts
            contacts[10]["service_id"].should == 11111
            contacts[11]["service"].should    == "slicktext"
            contacts[9]["textword"].should   == "itsonme"
            contacts[15]["subscribed_date"].should == "2013-02-04 21:12:45".to_datetime
        end

        it "should convert phone numbers to digits only" do
            textword = @campaign_item.textword
            limit    = 1000
            route = SLICKTEXT_URL + "/#{textword}/contacts?limit=#{limit}"
            stub_request(:get, route).with(:body => "data=", :headers => {'Accept'=>'application/json', 'Authorization'=>"Basic #{SLICKTEXT_PRIVATE}"}).to_return(:status => 200, :body => @sample_response )

            stg_obj = SlicktextGateway.new(textword: textword, limit: 1000)
            contacts = stg_obj.contacts
            contacts[3]["phone"].should == "5555555555"
        end

        it "should call slicktext again when the contacts total equals the limit" do
            textword = @campaign_item.textword
            limit    = 20
            route = SLICKTEXT_URL + "/#{textword}/contacts?limit=#{limit}"
            stub_request(:get, route).with(:body => "data=", :headers => {'Accept'=>'application/json', 'Authorization'=>"Basic #{SLICKTEXT_PRIVATE}"}).to_return(:status => 200, :body => @sample_response )
            stg_obj = SlicktextGateway.new(textword: textword, limit: 20)
            contacts = stg_obj.contacts
            contacts.count.should == 200
            WebMock.should have_requested(:get, route).times(10)
        end

    end

end




