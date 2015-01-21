require 'spec_helper'

describe Register do
    it "builds from factory" do
        affiliate = FactoryGirl.create :register
        affiliate.should be_valid
    end

    context 'associations' do

        it "should respond to :partner" do
            p = FactoryGirl.create(:register)
            a = FactoryGirl.create(:affiliate)
            p.partner = a
            p.partner.should == a
        end

        it "should respond to :affiliate" do
            p = FactoryGirl.create(:register)
            a = FactoryGirl.create(:affiliate)
            p.partner = a
            p.affiliate.should == a
        end

    end
end
