require 'spec_helper'

describe Client do

    it "builds from factory with associations" do
        client = FactoryGirl.create :client
        client.should be_valid
        client.should_not be_a_new_record
    end

    context "associations" do

        let(:client) { FactoryGirl.create :client }

        it "should have cities" do
            client.respond_to?(:content_cities).should be_true
        end

        it "should have users" do
            client.respond_to?(:content_users).should be_true
        end

        it "should have merchants" do
            client.respond_to?(:content_merchants).should be_true
        end

        it "should have providers" do
            client.respond_to?(:content_providers).should be_true
        end

        it "should have gifts" do
            client.respond_to?(:content_gifts).should be_true
        end

    end

end
