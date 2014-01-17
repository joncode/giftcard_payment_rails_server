require 'spec_helper'

describe Sale do

    it 'builds from factory' do
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

    it "should save via Gift with card" do

        card = FactoryGirl.create(:card)
        sale = FactoryGirl.build(:sale)
        sale.card = card
        gift = FactoryGirl.build(:gift, payable: sale)
        gift.save

        sale.reload
        sale.gift.id.should    == gift.id
        sale.gift.class.should == Gift
        sale.gift_id.should    be_nil
        sale.card.should       == card
        gift.payable.class     == Sale

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

    it "should receive required fields and save gift" do
            # required => [ giver_id, provider_id, card_id, number, month_year, first_name, last_name, amount ]
            # optional => unique_id
        user = FactoryGirl.create(:user)
        card = FactoryGirl.create(:visa, :name => user.name, :user_id => user.id)

        auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,157.00,CC,auth_capture,,#{card.first_name},#{card.last_name},,,,,,,,,,,,,,,,,"
        stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

        provider = FactoryGirl.create(:provider)

        args = {}
        args["giver_id"]    = user.id
        args["provider_id"] = provider.id
        args["card"]     = card
        args["number"]      = card.number
        args["month_year"]  = card.month_year
        args["first_name"]  = card.first_name
        args["last_name"]   = card.last_name
        args["amount"]      = "157.00"
        args["unique_id"]   = "UNIQUE_GIFT_ID"
        sale = Sale.charge_card args
        gift = FactoryGirl.build(:gift, giver: user, provider: provider)
        gift.payable = sale
        gift.save

        sale.reload
        sale.giver.should           == user
        sale.gift.id.should         == gift.id
        sale.provider.should        == provider
        sale.card.should            == card
        sale.revenue.to_s.should    == "157.0"
        sale.transaction_id.should  == "2202633834"
        JSON.parse(sale.resp_json).should == {"response_code"=>"1", "response_subcode"=>"1", "response_reason_code"=>"1", "response_reason_text"=>"This transaction has been approved.", "authorization_code"=>"JVT36N", "avs_response"=>"Y", "transaction_id"=>"2202633834", "invoice_number"=>"", "description"=>"", "amount"=>"157.0", "method"=>"CC", "transaction_type"=>"auth_capture", "customer_id"=>"", "first_name"=>"Jimmy", "last_name"=>"Basic"}
        JSON.parse(sale.req_json).should  == {"first_name"=>"Jimmy", "last_name"=>"Basic", "po_num"=>"UNIQUE_GIFT_ID", "method"=>"CC", "card_num"=>"XXXX9277", "exp_date"=>"0418", "amount"=>"157.00"}
        sale.reason_text.should     == "This transaction has been approved."
        sale.reason_code.should     == 1
        sale.resp_code.should       == 1
    end

    it "should receive giver_id on sale instance and process refund" do
        user = FactoryGirl.create(:user)
        card = FactoryGirl.create(:visa, :name => user.name, :user_id => user.id)
        revenue = BigDecimal("121.00")
        sale = FactoryGirl.create(:sale, transaction_id: "9823429834", revenue: revenue)
        gift = FactoryGirl.create(:gift, value: "121.00")
        auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,345783945,,,121.00,CC,credit,,#{card.first_name},#{card.last_name},,,,,,,,,,,,,,,,,"
        stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
        gift.payable = sale
        gift.save
        refund_sale = sale.void_refund(gift.giver_id)
        refund_sale.class.should     == Sale
        refund_sale.card_id.should   == sale.card.id
        refund_sale.giver_id.should  == gift.giver_id
        refund_sale.resp_code.should == 1
        refund_sale.revenue.should   == revenue
        refund_sale.transaction_id.should  == "345783945"
    end

    it "should process refund even when card is deleted" do
        user = FactoryGirl.create(:user)
        card = FactoryGirl.create(:visa, :name => user.name, :user_id => user.id)
        revenue = BigDecimal("121.00")
        sale = FactoryGirl.create(:sale, transaction_id: "9823429834", revenue: revenue, card_id: card.id, req_json: "{\"first_name\":\"#{user.first_name}\",\"last_name\":\"\",\"method\":\"CC\",\"card_num\":\"XXXX#{card.last_four}\",\"exp_date\":\"0316\",\"amount\":121.00}"
    )
        gift = FactoryGirl.create(:gift, value: "121.00")
        auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,345783945,,,121.00,CC,credit,,#{card.first_name},#{card.last_name},,,,,,,,,,,,,,,,,"
        stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
        gift.payable = sale
        gift.save
        card_id = card.id
        card.destroy
        refund_sale = sale.void_refund(gift.giver_id)
        refund_sale.class.should     == Sale
        refund_sale.card_id.should   == card_id

        refund_sale.giver_id.should  == gift.giver_id
        refund_sale.resp_code.should == 1
        refund_sale.revenue.should   == revenue
        refund_sale.transaction_id.should  == "345783945"
    end

    it "should respond to #success?" do
        revenue = BigDecimal("121.00")
        sale = FactoryGirl.create(:sale, transaction_id: "9823429834", revenue: revenue)
        sale.respond_to?(:success?).should == true
        sale.success?.should be_true
    end

end



# == Schema Information
#
# Table name: sales
#
#  id             :integer         not null, primary key
#  gift_id        :integer
#  giver_id       :integer
#  card_id        :integer
#  provider_id    :integer
#  transaction_id :string(255)
#  revenue        :decimal(, )
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  resp_json      :text
#  req_json       :text
#  resp_code      :integer
#  reason_text    :string(255)
#  reason_code    :integer
#

