require 'spec_helper'

include MerchantFactory

describe Client do

    it "builds from factory with associations" do
        client = FactoryGirl.create :client
        client.should be_valid
        client.should_not be_a_new_record
    end

    context "associations" do

        let(:client) { FactoryGirl.create :client }

        it "should have contents" do
            client.respond_to?(:contents).should be_true
        end

        it "should automatically make a City when a merchant is added" do
            client = FactoryGirl.create(:client)
            a = FactoryGirl.create(:affiliate)
            client.partner = a
            client.client!
            client.save
            m = make_merchant_provider('Test Invite')
            r = FactoryGirl.create(:region)
            m.city_id  = r.id
            m.save

            client.contents(:regions).count.should == 0
            client.content = m
            client.contents(:regions).count.should == 1
        end

    end

    context "validations" do

        it "should only allow one content per :client_id" do
            client = FactoryGirl.create(:client)
            a = FactoryGirl.create(:affiliate)
            client.partner = a
            client.client!
            client.save
            m = make_merchant_provider('Test Invite')
            client.contents(:merchants).count.should == 0
            client.content = m
            client.contents(:merchants).count.should == 1
            client.content = m
            client.contents(:merchants).count.should == 1
        end

        it "should only allow one content per :partner" do
            client = FactoryGirl.create(:client)
            a = FactoryGirl.create(:affiliate)
            client.partner = a
            client.partner!
            client.save
            m = make_merchant_provider('Test Invite')
            client.contents(:merchants).count.should == 0
            client.content = m
            client.contents(:merchants).count.should == 1
            client.content = m
            client.contents(:merchants).count.should == 1
        end

        it "should allow clients to have same content with different :client_id" do
            client = FactoryGirl.create(:client)
            a = FactoryGirl.create(:affiliate)
            client.partner = a
            client.client!
            client.save
            m = make_merchant_provider('Test Invite')
            client.contents(:merchants).count.should == 0
            client.content = m
            client.contents(:merchants).count.should == 1
            client = FactoryGirl.create( :client, url_name: 'another')
            a = FactoryGirl.create(:affiliate)
            client.partner = a
            client.partner!
            client.save
            client.contents(:merchants).count.should == 0
            client.content = m
            client.contents(:merchants).count.should == 1
            ClientContent.count.should == 2
        end
    end

end
