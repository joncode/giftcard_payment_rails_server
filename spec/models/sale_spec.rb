require 'spec_helper'

auth_response = "#<AuthorizeNet::AIM::Response:0x007fe7a9d958d0 @version='3.1', @raw_response=#<Net::HTTPOK 200 OK readbody=true>, @fields={:response_code=>'1', :response_subcode=>'1', :response_reason_code=>'1', :response_reason_text=>'This transaction has been approved.', :authorization_code=>'JVT36N', :avs_response=>'Y', :transaction_id=>'2202633834', :invoice_number=>', :description=>', :amount=>#<BigDecimal:7fe7a9d9ed68,'0.1E3',9(18)>, :method=>'CC', :transaction_type=>'auth_capture', :customer_id=>', :first_name=>'Jimbo', :last_name=>'Snake', :company=>', :address=>', :city=>', :state=>', :zip_code=>', :country=>', :phone=>', :fax=>', :email_address=>', :ship_to_first_name=>', :ship_to_last_name=>', :ship_to_company=>', :ship_to_address=>', :ship_to_city=>', :ship_to_state=>', :ship_to_zip_code=>', :ship_to_country=>', :tax=>#<BigDecimal:7fe7a9d9df08,'0.0',9(9)>, :duty=>#<BigDecimal:7fe7a9d9dd28,'0.0',9(9)>, :freight=>#<BigDecimal:7fe7a9d9da30,'0.0',9(9)>, :tax_exempt=>', :purchase_order_number=>'AD-23-40', :md5_hash=>'8EF9AB71098AE0B08C197AC7203B6DB4', :card_code_response=>', :cardholder_authentication_verification_response=>'2', :account_number=>'XXXX0002', :card_type=>'American Express'}, @transaction=#<AuthorizeNet::AIM::Transaction:0x007fe7a9cd7a38 @fields={:first_name=>'Jimbo', :last_name=>'Snake', :po_num=>'AD-23-40', :method=>'CC', :card_num=>370000000000002, :exp_date=>'1215', :amount=>'100.00'}, @custom_fields={}, @test_mode=false, @version='3.1', @api_login_id='948bLpzeE8UY', @api_transaction_key='7f7AZ66axeC386q7', @response=#<AuthorizeNet::AIM::Response:0x007fe7a9d958d0 ...>, @delimiter=',', @type='AUTH_CAPTURE', @cp_version=nil, @gateway='https://test.authorize.net/gateway/transact.dll', @allow_split_transaction=false, @encapsulation_character=nil, @verify_ssl=false, @market_type=2, @device_type=1>, @custom_fields={}>"

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

        before do
            @card = FactoryGirl.create(:card)
            @gift = FactoryGirl.build(:gift, credit_card: @card.id)
        end

        it "should return a Sale instance" do
            Card.any_instance.stub(:decrypt!).and_return("4111000011110000")
            Card.any_instance.stub(:number).and_return("4111000011110000")
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
            @sale = Sale.process(@gift)
            @sale.class.should == Sale
        end

        it "build sale instance with gift data" do
            Card.any_instance.stub(:decrypt!).and_return("4111000011110000")
            Card.any_instance.stub(:number).and_return("4111000011110000")
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
            @sale = Sale.process(@gift)
            @sale.card_id.should         == @gift.credit_card
            @sale.gift_id.should         == @gift.id
            @sale.giver_id.should        == @gift.giver_id
            @sale.provider_id.should     == @gift.provider_id
            @sale.revenue.should         == BigDecimal(@gift.grand_total)
            @sale.total.should           == @gift.grand_total
        end

        it "should hit Auth.net endpoint with 'po_num' of gift ID - fix duplicate transaction bug" do
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
            Card.any_instance.stub(:decrypt!).and_return("4111000011110000")
            Card.any_instance.stub(:number).and_return("4111000011110000")
            Card.any_instance.stub(:month_year).and_return("1216")
            @sale = Sale.process(@gift)

            WebMock.should have_requested(:post, "https://test.authorize.net/gateway/transact.dll").with { |req|
                puts req.body;
                req.body.match(/x_po_num/)
            }
            po_num = "#{@gift.receiver_name}_#{@gift.provider_id}".gsub(' ','_')
            WebMock.should have_requested(:post, "https://test.authorize.net/gateway/transact.dll").with { |req|
                req.body.match(/#{po_num}/)
            }
        end

        it "should create an Auth.net transaction object" do
            Card.any_instance.stub(:decrypt!).and_return("4111000011110000")
            Card.any_instance.stub(:number).and_return("4111000011110000")
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
            @sale = Sale.process(@gift)
            @sale.transaction.class.should == AuthorizeNet::AIM::Transaction
        end

        it "should create an Auth.net sale response object" do
            Card.any_instance.stub(:decrypt!).and_return("4111000011110000")
            Card.any_instance.stub(:number).and_return("4111000011110000")
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
            @sale = Sale.process(@gift)
            @sale.response.class.should == AuthorizeNet::AIM::Response
        end

        it "should add gateway data" do
            Card.any_instance.stub(:decrypt!).and_return("4111000011110000")
            Card.any_instance.stub(:number).and_return("4111000011110000")
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
            @sale = Sale.process(@gift)
            response = @sale.response
            @sale.transaction_id.should  == response.transaction_id
            @sale.resp_json.should       == response.fields.to_json
            @sale.resp_code.should       == response.response_code.to_i
            @sale.reason_text.should     == response.response_reason_text
            @sale.reason_code.should     == response.response_reason_code.to_i
        end

        it "should create req_json after removing the credit card number" do
            Card.any_instance.stub(:decrypt!).and_return("4111000011110000")
            Card.any_instance.stub(:number).and_return("4111000011110000")
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
            @sale = Sale.process(@gift)
            transaction = @sale.transaction
            full_num = transaction.fields[:card_num]
            half_num = "XXXX" + full_num[-4..-1]
            puts half_num
            @sale.req_json.should  == @sale.transaction.fields.to_json
        end

    end


end
