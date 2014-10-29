require 'spec_helper'

describe Affiliate do

    it "builds from factory" do
        affiliate = FactoryGirl.create :affiliate
        affiliate.should be_valid
    end

    it_should_behave_like "phone storage" do
        let(:object) { FactoryGirl.build(:affiliate) }
        let(:field) { :phone }
    end

    it_should_behave_like "email storage" do
        let(:object) { FactoryGirl.build(:affiliate) }
        let(:field) { :email }
    end
end
