require 'spec_helper'

describe Slicktext do

    let(:word_hsh) { [{"id"=>"15892", "word"=>"its on me", "autoReply"=>"Welcome to It's On Me!  You're one click away from gifting! iPhone Users: http://www.sos.me/join Android Users Can Join Our Alpha Here: http://www.sos.me/aJoin", "added"=>"2013-10-11 13:45:57", "optOuts"=>"1", "ageRequirement"=>"0"}, {"id"=>"15893", "word"=>"itsonme", "autoReply"=>"Welcome to It's On Me!  You're one click away from gifting! iPhone Users: http://www.sos.me/join Android Users Can Join Our Alpha Here: http://www.sos.me/aJoin", "added"=>"2013-10-11 13:46:16", "optOuts"=>"0", "ageRequirement"=>"0"}, {"id"=>"17429", "word"=>"no kid hungry", "autoReply"=>"Welcome to It's On Me!  You're one click away from gifting! iPhone Users: http://www.sos.me/join Android Users Can Join Our Alpha Here: http://www.sos.me/aJoin", "added"=>"2013-10-17 09:57:19", "optOuts"=>"0", "ageRequirement"=>"0"}, {"id"=>"68214", "word"=>"testcampaign", "autoReply"=>"This is a test! Go to http://bit.ly/O3eRbm to download the IOM app and receive your test campaign gift! If you're already an IOM user, check your Gift Center!", "added"=>"2014-03-12 14:32:36", "optOuts"=>"0", "ageRequirement"=>"21"}] }
    let(:slicktext_response) { {"meta"=>{"limit"=>1000, "offset"=>0, "total"=>4, "self"=>"http://api.slicktext.com/v1/textwords?limit=1000limit=1000"}, "links"=>{"self"=>"http://api.slicktext.com/v1/textwords/limit=1000"}, "textwords"=>[{"id"=>"15892", "word"=>"its on me", "autoReply"=>"Welcome to It's On Me!  You're one click away from gifting! iPhone Users: http://www.sos.me/join Android Users Can Join Our Alpha Here: http://www.sos.me/aJoin", "added"=>"2013-10-11 13:45:57", "optOuts"=>"1", "ageRequirement"=>"0"}, {"id"=>"15893", "word"=>"itsonme", "autoReply"=>"Welcome to It's On Me!  You're one click away from gifting! iPhone Users: http://www.sos.me/join Android Users Can Join Our Alpha Here: http://www.sos.me/aJoin", "added"=>"2013-10-11 13:46:16", "optOuts"=>"0", "ageRequirement"=>"0"}, {"id"=>"17429", "word"=>"no kid hungry", "autoReply"=>"Welcome to It's On Me!  You're one click away from gifting! iPhone Users: http://www.sos.me/join Android Users Can Join Our Alpha Here: http://www.sos.me/aJoin", "added"=>"2013-10-17 09:57:19", "optOuts"=>"0", "ageRequirement"=>"0"}, {"id"=>"68214", "word"=>"testcampaign", "autoReply"=>"This is a test! Go to http://bit.ly/O3eRbm to download the IOM app and receive your test campaign gift! If you're already an IOM user, check your Gift Center!", "added"=>"2014-03-12 14:32:36", "optOuts"=>"0", "ageRequirement"=>"21"}]} }

    describe :new do

        it "should accept :limit, :word_hsh and make textword, word_id" do
            sltxt_obj = Slicktext.new(word_hsh[0], 20)
            sltxt_obj.limit.should    == 20
            sltxt_obj.textword.should == "its on me"
            sltxt_obj.word_id.should  == "15892"
        end

        it "should run w/o :limit, :word_hsh and make textword, word_id" do
            sltxt_obj = Slicktext.new()
            sltxt_obj.limit.should    == 1000
            sltxt_obj.textword.should == nil
            sltxt_obj.word_id.should  == nil
        end
    end

    describe :textwords do

        it "should accept no argument and return :word_hsh" do
            Slicktext.stub(:get).and_return(slicktext_response)
            word_hsh = Slicktext.textwords
            word_hsh.should == word_hsh
        end

    end

    describe :contacts do

        it "should create hash with textword not word id" do
            sltxt_obj = Slicktext.new(word_hsh[1], 20)
            sltxt_obj.limit.should    == 20
            sltxt_obj.textword.should == "itsonme"
            sltxt_obj.word_id.should  == "15893"
            sltxt_obj.resp = {"meta"=>{"limit"=>50, "offset"=>0, "total"=>2}, "links"=>{"self"=>"http://api.slicktext.com/v1/contacts/limit=50&textword=15893"}, "contacts"=>[{"id"=>"508833", "number"=>"+17026728462", "city"=>"LAS VEGAS", "state"=>"NV", "zipCode"=>"89120", "country"=>"US", "textword"=>"15893", "subscribedDate"=>"2014-03-18 14:32:02", "firstName"=>nil, "lastName"=>nil, "birthDate"=>nil}, {"id"=>"509992", "number"=>"+18056740958", "city"=>"PASO ROBLES", "state"=>"CA", "zipCode"=>"93451", "country"=>"US", "textword"=>"15893", "subscribedDate"=>"2014-03-18 20:44:49", "firstName"=>nil, "lastName"=>nil, "birthDate"=>nil}]}
            data = sltxt_obj.contacts
            data[0]["service_id"].should      == sltxt_obj.resp["contacts"][0]["id"]
            data[0]["service"].should         == "slicktext"
            data[0]["textword"].should        == "itsonme"
            data[0]["subscribed_date"].should == sltxt_obj.resp["contacts"][0]["subscribedDate"].to_datetime
            data[0]["phone"].should           == sltxt_obj.resp["contacts"][0]["number"].gsub('+1','')
        end
    end

    describe :count do

        it "should return 0 when no contacts exist" do
            Slicktext.stub(:get).and_return(slicktext_response)
            Slicktext.any_instance.stub(:resp).and_return(nil)
            sltxt_obj = Slicktext.new(word_hsh[3], 20)
            sltxt_obj.count.should == 0
        end

    end
end