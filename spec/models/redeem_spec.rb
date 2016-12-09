require 'spec_helper'
include UserSessionFactory
include MocksAndStubs

describe Redeem do

    before(:each) do
        User.delete_all
        UserSocial.delete_all
        Gift.delete_all
        Client.delete_all
        SessionToken.delete_all

        stub_request(:post, "https://api.stripe.com/v1/charges")

        @user = FactoryGirl.create :user, facebook_id: nil, iphone_photo: "https://res.cloudinary.com/drinkboard/image/upload/v1398470766/myphoto.jpg"
    	@rec = FactoryGirl.create :user, email: "jon.gutwillig@itson.me"
        @merchant = FactoryGirl.create :merchant
        @menu_item = FactoryGirl.create :menu_item
        @card = FactoryGirl.create :card
        payable = FactoryGirl.create :sale
        puts @menu_item.inspect

        Sale.stub(:charge_card).and_return(payable)

        hsh = {"receiver_name"=>@rec.name, "receiver_email"=> @rec.email, "link"=>nil,
            "origin"=>"Mozilla/5.0 (Windows NT 10.0; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0",
            "client_id"=>120, "partner_id"=> @merchant.id, "partner_type"=>"Merchant", "shoppingCart"=>[@menu_item.serialize_to_app(1)].to_json,
            "giver"=>@user,  "credit_card"=> @card.id, "merchant_id"=>@merchant.id, "value"=>@menu_item.price, "message"=>"Happy Chanukah\nLove your favorite Golf Conscierge"}
            # MAKE A GIFT
        @gift = GiftSale.create hsh
        puts @gift.shoppingCart.inspect
        puts @merchant.r_sys.inspect
        puts "Original Value = #{@gift.original_value}"
        @balance = @gift.balance
        @status = @gift.status
    end

    it "should create a paper redemption" do
            # MAKE A PAPER REDEMPTION
        resp = Redeem.start(gift: @gift, api: "/papergifts/#{@gift.hex_id}", type_of: :paper)
        puts resp.inspect
        resp['success'].should be_true
        resp['gift'].status.should == @status
        resp['gift'].balance.should == @balance
        redemption = resp['redemption']
        redemption.r_sys.should == 4
        redemption.type_of.should == "paper"
        redemption.gift_id.should == @gift.id
        redemption.merchant_id.should == @merchant.id
        redemption.gift_next_value.should == 0
        redemption.gift_prev_value.should == @balance
        redemption.amount.should == @balance
        redemption.start_req.should == {"loc_id"=>nil, "amount"=>nil, "client_id"=>nil, "api"=>"/papergifts/#{@gift.hex_id}", "type_of"=>"paper"}
        redemption.start_res.should == {"response_code"=>"PENDING",
            "response_text"=>{"previous_gift_balance"=> @balance, "amount_applied"=> @balance, "remaining_gift_balance"=>0, "msg"=>"Give code #{redemption.token} to your server"}}
            # partial redeem the gift via gifts controller api on zapper / omnivore / v2 / v1 / admin
        r2 = Redeem.start(gift: @gift, loc_id: nil, amount: @balance/3, api: "web/v3/gifts/#{@gift.id}/start_redemption")
        redemption = r2['redemption']
        redemption.r_sys.should == @merchant.r_sys
        redemption.type_of.should == "v2"
        redemption.gift_id.should == @gift.id
        redemption.merchant_id.should == @merchant.id
        redemption.gift_next_value.should == @balance - @balance/3
        redemption.gift_prev_value.should == @balance
        redemption.amount.should == @balance/3
        redemption.start_req.should == {"loc_id"=>nil, "amount"=>@balance/3, "client_id"=>nil, "api"=>"web/v3/gifts/#{@gift.id}/start_redemption", "type_of"=>"merchant"}
        redemption.start_res.should == {"response_code"=>"PENDING",
            "response_text"=>{"previous_gift_balance"=> @balance, "amount_applied"=> redemption.amount,
                "remaining_gift_balance"=>redemption.gift_next_value, "msg"=>"Give code #{redemption.token} to your server"}}
            # COMPLETE THE APP REDEMPTION
        @current_redemption = Redemption.current_pending_redemption(@gift)
        @current_redemption.id.should == r2['redemption'].id

            # redeem rest of paper gift for remaining value of gift
    end

end


# make a gift
# make a paper redemption for the gift
# partial redeem the gift via gifts controller api on zapper / omnivore / v2 / v1 / admin
# redeem rest of paper gift for remaining value of gift

