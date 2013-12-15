require 'spec_helper'

describe PaymentGateway do

    context "charge card" do

        it "should require [number, month_year, first_name, last_name, amount]" do
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => '', :headers => {})
            user = FactoryGirl.create(:user)
            card = FactoryGirl.create(:visa, :name => user.name, :user_id => user.id)
            require_hsh = {}
            require_hsh["number"]     = card.number
            require_hsh["month_year"] = card.month_year
            require_hsh["first_name"] = card.first_name
            require_hsh["last_name"]  = card.last_name
            require_hsh["amount"]     = "100.00"
            pg_obj = PaymentGateway.new(require_hsh)
            pg_obj.charge

            pg_obj.credit_card.card_number.should == card.number
            pg_obj.credit_card.expiration.should  == card.month_year
            WebMock.should have_requested(:post, "https://test.authorize.net/gateway/transact.dll").with { |req|
                req.body.match(/x_card_num/)
            }
            po_num = "testing_unique"
            WebMock.should have_requested(:post, "https://test.authorize.net/gateway/transact.dll").with { |req|
                req.body.match(/#{card.number}/)
            }
            WebMock.should have_requested(:post, "https://test.authorize.net/gateway/transact.dll").with { |req|
                req.body.match(/x_exp_date/)
            }
            po_num = "testing_unique"
            WebMock.should have_requested(:post, "https://test.authorize.net/gateway/transact.dll").with { |req|
                req.body.match(/#{card.month_year}/)
            }
            WebMock.should have_requested(:post, "https://test.authorize.net/gateway/transact.dll").with { |req|
                req.body.match(/x_amount/)
            }
            po_num = "testing_unique"
            WebMock.should have_requested(:post, "https://test.authorize.net/gateway/transact.dll").with { |req|
                req.body.match(/100.00/)
            }
        end

        it "should allow optional 'unique_id'" do
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => '', :headers => {})
            user = FactoryGirl.create(:user)
            card = FactoryGirl.create(:visa, :name => user.name, :user_id => user.id)
            require_hsh = {}
            require_hsh["number"]     = card.number
            require_hsh["month_year"] = card.month_year
            require_hsh["first_name"] = card.first_name
            require_hsh["last_name"]  = card.last_name
            require_hsh["amount"]     = "100.00"
            require_hsh["unique_id"]  = "testing_unique"
            pg_obj = PaymentGateway.new(require_hsh)
            pg_obj.charge

            WebMock.should have_requested(:post, "https://test.authorize.net/gateway/transact.dll").with { |req|
                req.body.match(/x_po_num/)
            }
            po_num = "testing_unique"
            WebMock.should have_requested(:post, "https://test.authorize.net/gateway/transact.dll").with { |req|
                req.body.match(/#{po_num}/)
            }
        end

        it "should respond with transaction_id and response codes / text" do
            user = FactoryGirl.create(:user)
            card = FactoryGirl.create(:visa, :name => user.name, :user_id => user.id)

            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,100.00,CC,auth_capture,,#{card.first_name},#{card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

            require_hsh = {}
            require_hsh["number"]     = card.number
            require_hsh["month_year"] = card.month_year
            require_hsh["first_name"] = card.first_name
            require_hsh["last_name"]  = card.last_name
            require_hsh["amount"]     = "100.00"
            require_hsh["unique_id"]  = "testing_unique"


            pg_obj = PaymentGateway.new(require_hsh)
            response_hsh = pg_obj.charge

            response_hsh["transaction_id"].should   == '2202633834'
            response_hsh["revenue"].should          == BigDecimal('100.00')
            response_hsh["reason_text"].should      == 'This transaction has been approved.'
            response_hsh["reason_code"].should      == 1
            response_hsh["resp_code"].should        == 1
            response_hsh["resp_json"].should     == pg_obj.response.fields.to_json
            response_hsh["req_json"].should      == pg_obj.transaction.fields.to_json
        end


    end

    context "refund / void a transaction" do

        it "should require only transaction_id for a void and only call #void" do
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => '', :headers => {})
            AuthorizeNet::AIM::Response.any_instance.stub(:success?).and_return(true)
            AuthorizeNet::AIM::Transaction.any_instance.should_not_receive(:refund)
            user = FactoryGirl.create(:user)
            card = FactoryGirl.create(:visa, :name => user.name, :user_id => user.id)
            revenue = BigDecimal("121.00")
            sale = FactoryGirl.create(:sale, transaction_id: "9823429834", revenue: revenue)
            require_hsh = {}
            require_hsh["transaction_id"] = sale.transaction_id
            pg_obj = PaymentGateway.new(require_hsh)
            pg_obj.refund
            transaction = pg_obj.transaction
            WebMock.should have_requested(:post, "https://test.authorize.net/gateway/transact.dll").with { |req|
                req.body.match(/x_trans_id/);
                req.body.match(/#{sale.transaction_id}/)
            }.once
            WebMock.should have_requested(:post, "https://test.authorize.net/gateway/transact.dll").with { |req|
                req.body.match(/x_type/);
                req.body.match(/VOID/)
            }.once

        end

        it "should require transaction_id, cc_last_four, amount and call refund when void fails" do
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => '', :headers => {})
            AuthorizeNet::AIM::Response.any_instance.stub(:success?).and_return(false)
            user = FactoryGirl.create(:user)
            card = FactoryGirl.create(:visa, :name => user.name, :user_id => user.id)
            revenue = BigDecimal("121.00")
            sale = FactoryGirl.create(:sale, transaction_id: "9823429834", revenue: revenue)
            require_hsh = {}
            require_hsh["last_four"]      = card.last_four
            require_hsh["transaction_id"] = sale.transaction_id
            require_hsh["amount"]         = revenue
            pg_obj = PaymentGateway.new(require_hsh)
            pg_obj.refund
            transaction = pg_obj.transaction

            pg_obj.amount.should == revenue
            pg_obj.transaction_id.should == sale.transaction_id
            pg_obj.cc_last_four.should == card.last_four

            WebMock.should have_requested(:post, "https://test.authorize.net/gateway/transact.dll").with { |req|
                req.body.match(/x_card_num/);
                req.body.match(/CREDIT/);
                req.body.match(/121.00/);
                req.body.match(/#{card.last_four}/);
            }.once
            WebMock.should have_requested(:post, "https://test.authorize.net/gateway/transact.dll").with { |req|
                req.body.match(/x_trans_id/);
                req.body.match(/#{sale.transaction_id}/)
            }.twice
        end

        it "should respond with new transaction_id and response code / text" do
            user = FactoryGirl.create(:user)
            card = FactoryGirl.create(:visa, :name => user.name, :user_id => user.id)
            revenue = BigDecimal("121.00")
            sale = FactoryGirl.create(:sale, transaction_id: "9823429834", revenue: revenue)

            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,9823429834,,,121.00,CC,credit,,#{card.first_name},#{card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

            require_hsh = {}
            require_hsh["last_four"]      = card.last_four
            require_hsh["transaction_id"] = sale.transaction_id
            require_hsh["amount"]         = revenue

            pg_obj = PaymentGateway.new(require_hsh)
            response_hsh = pg_obj.refund

            response_hsh["transaction_id"].should   == '9823429834'
            response_hsh["revenue"].should          == BigDecimal('121.00')
            response_hsh["reason_text"].should      == 'This transaction has been approved.'
            response_hsh["reason_code"].should      == 1
            response_hsh["resp_code"].should        == 1
            response_hsh["resp_json"].should     == pg_obj.response.fields.to_json
            response_hsh["req_json"].should      == pg_obj.transaction.fields.to_json

        end
    end
end



# PAYMENT GATEWAY API

#     CHARGE
#         Dependencies
#             card.number
#             card.month_year
#             card.first_name
#             card.last_name
#             gift.grand_total
#             gift.unique_duplicate_gift_id
#                 gift.receiver_name
#                 gift.provider_id

#             [ number, month_year, first_name, last_name, amount, unique_id ]

#         Response

#             Auth.net response
#                 transaction_id
#                 revenue
#                 reason_text
#                 resp_code
#                 reason_code
#                 raw_response
#                 raw_request

#     VOID
#         Dependencies
#             transaction_id, cc_last_four, amount

#         Response
#             response_reason_text
#             response_code

