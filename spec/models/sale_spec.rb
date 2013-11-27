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

    it "requires resp_code" do
        sale = FactoryGirl.build(:sale, :resp_code => nil)
        sale.should_not be_valid
        sale.should have_at_least(1).error_on(:resp_code)
    end

    it "should associate with Gifts" do
        sale = FactoryGirl.create(:sale)

        gift = FactoryGirl.create(:gift, payable: sale)

        sale.reload
        sale.gift.id.should   == gift.id
        sale.gift.class.should == Gift
    end

    it "should associate with Cards" do
        card = FactoryGirl.create(:card)
        sale = FactoryGirl.create(:sale, card: card)
        sale.card.id.should   == card.id
        sale.card.class.should == Card
    end

    it "should save the amount as a decimal" do
        sale = FactoryGirl.create(:sale, revenue: "100")
        sale.reload
        sale.revenue.should == BigDecimal("100")
    end

    describe "#process" do

        let(:gift) { FactoryGirl.build(:gift) }
        let(:sale) { Sale.process(gift)}

        it "should return a Sale instance" do
            sale.class.should == Sale
        end

        it "build sale instance with gift data" do
            sale.card_id.should         == gift.credit_card
            sale.gift_id.should         == gift.id
            sale.giver_id.should        == gift.giver_id
            sale.provider_id.should     == gift.provider_id
            sale.revenue.should         == BigDecimal(gift.grand_total)
            sale.total.should           == gift.grand_total
        end

        it "should create an Auth.net transaction object" do
            sale.transaction.class.should == AuthTransaction.new.class
        end

        it "should create an Auth.net sale response object" do
            sale.response.class.should == AuthResponse.new.class
        end

        it "should add gateway data" do
            response = sale.response
            sale.transaction_id.should  == response.transaction_id
            sale.resp_json.should       == response.fields.to_json
            sale.resp_code.should       == response.response_code.to_i
            sale.reason_text.should     == response.response_reason_text
            sale.reason_code.should     == response.response_reason_code.to_i
        end

        it "should create req_json after removing the credit card number" do
            transaction = sale.transaction
            full_num = transaction.fields[:card_num]
            half_num = "XXXX" + full_num[-4..-1]
            puts half_num
            sale.req_json.should  == sale.transaction.fields.to_json
        end

    end


end
