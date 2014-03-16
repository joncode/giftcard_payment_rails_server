require 'spec_helper'


describe Oauth do

    it "builds from factory" do
        oauth = FactoryGirl.build :oauth
        oauth.should be_valid
    end

    it "requires network" do
        oauth = FactoryGirl.build(:oauth, :network => nil)
        oauth.should_not be_valid
        oauth.should have_at_least(1).error_on(:network)
    end

    it "requires network_id" do
        oauth = FactoryGirl.build(:oauth, :network_id => nil)
        oauth.should_not be_valid
        oauth.should have_at_least(1).error_on(:network_id)
    end

    it "requires 'token'" do
        oauth = FactoryGirl.build(:oauth, :token => nil)
        oauth.should_not be_valid
        oauth.should have_at_least(1).error_on(:token)
    end

    it "requires 'secret' when network is twitter" do
        oauth = FactoryGirl.build(:oauth, :secret => nil, :network => "twitter")
        oauth.should_not be_valid
        oauth.should have_at_least(1).error_on(:secret)
    end

    it "requires 'handle' when network is twitter" do
        oauth = FactoryGirl.build(:oauth, :handle => nil, :network => "twitter")
        oauth.should_not be_valid
        oauth.should have_at_least(1).error_on(:handle)
    end

    it "associates with a gift" do
        gift  = FactoryGirl.create(:gift)
        oauth = FactoryGirl.build(:oauth, gift: gift)
        oauth.save
        oauth.gift.id.should           == gift.id
        oauth.gift.class.to_s.should   == "Gift"
        oauth.gift_id.should           == gift.id
        gift.oauth.should              == oauth
    end

    it "associates with a user" do
        user  = FactoryGirl.create(:user)
        oauth = FactoryGirl.build(:oauth, user: user)
        oauth.save
        oauth.user.id.should           == user.id
        oauth.user.class.to_s.should   == "User"
        oauth.user_id.should           == user.id
        user.oauths.first.should       == oauth
    end

    it "should initialize from hash" do
        hsh =  {"token"=>"9q3562341341", "secret"=>"92384619834", "network"=>"twitter", "network_id"=>"9865465748", "handle"=>"razorback", "photo"=>"cdn.akai.twitter/791823401974.png"}
        oauth = Oauth.initFromDictionary hsh
        oauth.token.should      == "9q3562341341"
        oauth.secret.should     == "92384619834"
        oauth.network.should    == "twitter"
        oauth.network_id.should == "9865465748"
        oauth.handle.should     == "razorback"
        oauth.photo.should      == "cdn.akai.twitter/791823401974.png"
    end

    it "should create correct hash via :to_proxy" do
        tw_hsh =  {"token"=>"9q3562341341", "secret"=>"92384619834", "network"=>"twitter", "network_id"=>"9865465748", "handle"=>"razorback", "photo"=>"cdn.akai.twitter/791823401974.png"}
        oauth = Oauth.initFromDictionary tw_hsh
        oauth_hsh = oauth.to_proxy
        oauth_hsh.should == { "token"=>"9q3562341341", "secret"=>"92384619834", "network"=>"twitter", "network_id"=>"9865465748", "handle"=>"razorback"}

        fb_hsh =  {"token"=>"9q3562341341", "network"=>"facebook", "network_id"=>"11237128471823", "photo"=>"cdn.akai.twitter/791823401974.png"}
        oauth = Oauth.initFromDictionary fb_hsh
        oauth_hsh = oauth.to_proxy
        oauth_hsh.should ==  {"token"=>"9q3562341341", "network"=>"facebook", "network_id"=>"11237128471823"}
    end

    context "multi-network uniqueness constraints" do

        it "should overwrite an existing oauth record for that network on :create" do
            user  = FactoryGirl.create(:user)
            oauth = FactoryGirl.build(:oauth, user: user)
            oauth.save
            new_tw_oauth = { "token"=>"new_token", "secret"=>"new_secret", "network"=>"twitter", "network_id"=>oauth.network_id, "handle"=>"razorback", "user_id" => user.id}
            Oauth.create(new_tw_oauth)
            oauth.reload
            oauth.token.should      == "new_token"
        end

        it "should overwrite an existing oauth record for that network on :create" do
            user  = FactoryGirl.create(:user)
            oauth = FactoryGirl.build(:oauth_fb, user: user)
            oauth.save
            new_tw_oauth = { "token"=>"new_token", "network"=>"facebook", "network_id"=>oauth.network_id, "user_id" => user.id}
            new_oauth    = Oauth.create(new_tw_oauth)
            new_oauth.id.should     == oauth.id
            new_oauth.token.should  == "new_token"
            oauth.reload
            oauth.token.should      == "new_token"
        end

        it "should create a new oauth record for that network on :create" do
            user  = FactoryGirl.create(:user)
            new_tw_oauth = { "token"=>"new_token", "secret"=>"new_secret", "network"=>"twitter", "network_id"=>"9865465748", "handle"=>"razorback", "user_id" => user.id}
            new_oauth    = Oauth.create(new_tw_oauth)
            new_oauth.token.should  == "new_token"

        end

        it "should create a new oauth record for that network on :create" do
            user  = FactoryGirl.create(:user)
            new_tw_oauth = { "token"=>"new_token", "network"=>"facebook", "network_id"=>"9865465748", "user_id" => user.id}
            new_oauth    = Oauth.create(new_tw_oauth)
            new_oauth.token.should  == "new_token"

        end
    end

    context "notification hooks" do

        before(:each) do
            @oauth_hsh_fb = {}
            @fb_resp    =  [{ "birthday"  =>"10/05/1987", "network_id"=>"27428352", "name" =>"Taylor Addison", "photo" =>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg"},{ "birthday"  =>"10/05/1987", "network_id"=>"27428352", "name" =>"Taylor Addison", "photo" =>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg"}].to_json
            @route      = "http://qam.itson.me/api/twitter/mention"
            @post_hsh   =   {"token"=>"9q3562341341", "secret"=>"92384619834", "network_id"=>"9865465748", "handle"=>"razorback", "merchant"=>"ichizos1", "title"=>"Original Margarita ", "url"=>"http://0.0.0.0:3001/acceptgift/649388"}
            #@request    = {"token"=> @oauth_hsh_fb["token"], "network_id"=> @oauth_hsh_fb["network_id"]}.merge!(@post_hsh)
        end

        it "should hit social proxy API with post hash afer_save" do
            stub_request(:post, @route).with(:body => @post_hsh.to_json , :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{@fb_resp}", :headers => {})
            require_hsh  = @oauth_hsh_fb
            gift  = FactoryGirl.create(:gift)
            oauth = FactoryGirl.build(:oauth, gift: gift)
            oauth.save
            SocialProxy.any_instance.should_receive(:create_post)
        end

    end

end# == Schema Information
#
# Table name: oauths
#
#  id         :integer         not null, primary key
#  gift_id    :integer
#  token      :string(255)
#  secret     :string(255)
#  network    :string(255)
#  network_id :string(255)
#  handle     :string(255)
#  photo      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# == Schema Information
#
# Table name: oauths
#
#  id         :integer         not null, primary key
#  gift_id    :integer
#  token      :string(255)
#  secret     :string(255)
#  network    :string(255)
#  network_id :string(255)
#  handle     :string(255)
#  photo      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer
#

