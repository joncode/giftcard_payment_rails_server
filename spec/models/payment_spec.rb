require 'spec_helper'

describe Payment do
    it "builds from factory" do
        payment = FactoryGirl.create :payment
        payment.should be_valid
    end

    context 'associations' do

        it "should respond to :partner" do
            p = FactoryGirl.create(:payment)
            a = FactoryGirl.create(:affiliate)
            p.partner = a
            p.partner.should == a
        end

        it "should respond to :affiliate" do
            p = FactoryGirl.create(:payment)
            a = FactoryGirl.create(:affiliate)
            p.partner = a
            p.affiliate.should == a
        end

    end
end
