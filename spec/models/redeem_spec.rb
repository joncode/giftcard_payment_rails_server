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
    	@user     = FactoryGirl.create :user, facebook_id: nil, iphone_photo: "https://res.cloudinary.com/drinkboard/image/upload/v1398470766/myphoto.jpg"
    	@receiver = @user
        @other1    = @user
    	other2    = @user
    	3.times { FactoryGirl.create :gift, giver: @other1, receiver_name: @user.name, receiver_id: @user.id, merchant: @merchant}
    	3.times { FactoryGirl.create :gift, giver: @user, receiver_name: other2.name, receiver_id: other2.id, merchant: @merchant}
    	3.times { FactoryGirl.create :gift, giver: @other1, receiver_name: other2.name, receiver_id: other2.id, merchant: @merchant}
        @client = make_partner_client('Gifts', 'Creator')
        @user = create_user_with_token "USER_TOKEN", @user, @client
    end

    it "should process v1 redemptions" do
    	@merchant.update(r_sys: 1)
    	gift = Gift.last
    	resp = Redeem.start(gift: gift, amount: gift.value_cents, client_id: @client.id, api: "web/v3/gifts/#{gift.id}/start_redemption")
    	puts resp.inspect
    	resp['success'].should be_false
    	resp['gift'].should be_nil
    	resp['redemption'].should be_nil
    end

end



