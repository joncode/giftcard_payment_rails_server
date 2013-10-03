require 'spec_helper'


describe Sale do

    it "builds from factory" do
        sale = FactoryGirl.create :sale
        puts "HERE is SALE #{sale.inspect}"
        sale.should be_valid
    end

    it "requires giver_id" do
        sale = FactoryGirl.build(:sale, :giver_id => nil)
        sale.should_not be_valid
        sale.should have_at_least(1).error_on(:giver_id)
    end

    it "requires gift_id" do
        sale = FactoryGirl.build(:sale, :gift_id => nil)
        sale.should_not be_valid
        sale.should have_at_least(1).error_on(:gift_id)
    end

    it "requires resp_code" do
        sale = FactoryGirl.build(:sale, :resp_code => nil)
        sale.should_not be_valid
        sale.should have_at_least(1).error_on(:resp_code)
    end
end
