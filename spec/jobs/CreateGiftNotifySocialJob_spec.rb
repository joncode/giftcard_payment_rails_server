require 'spec_helper'

# describe CreateGiftNotifySocialJob do

    describe :perform do

        before(:each) do
            @oauth_hsh_fb = {}
            @fb_resp    =  [{ "birthday"  =>"10/05/1987", "network_id"=>"27428352", "name" =>"Taylor Addison", "photo" =>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg"},{ "birthday"  =>"10/05/1987", "network_id"=>"27428352", "name" =>"Taylor Addison", "photo" =>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg"}].to_json
            @route      = "http://qam.itson.me/api/twitter/mention"
            #@request    = {"token"=> @oauth_hsh_fb["token"], "network_id"=> @oauth_hsh_fb["network_id"]}.merge!(@post_hsh)
        end

        it "should find gift and call social proxy" do

            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json")
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json")
            require_hsh  = @oauth_hsh_fb
            gift  = FactoryGirl.create(:gift)
            oauth = FactoryGirl.build(:oauth, gift: gift)
            @post_hsh   =   {"token"=>"9q3562341341", "secret"=>"92384619834", "network_id"=>"9865465748", "handle"=>"razorback", "merchant"=>"ichizos1", "title"=>"Original Margarita ", "url"=>"http://0.0.0.0:3001/signup/acceptgift/#{gift.obscured_id}"}
            stub_request(:post, @route).with(:body => @post_hsh.to_json , :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{@fb_resp}", :headers => {})

            ResqueSpec.reset!
            oauth.save
            #SocialProxy.any_instance.should_receive(:create_post)
            run_delayed_jobs
        end

    end
# end