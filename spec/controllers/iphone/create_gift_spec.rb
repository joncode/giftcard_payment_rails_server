require 'spec_helper'

describe IphoneController do

    # describe "#create_gift" do

    #     before(:each) do
    #         Gift.delete_all
    #         User.delete_all
    #         UserSocial.delete_all
    #         @user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password" }
    #         @token = @user.remember_token
    #         @token = "NOOOO"
    #         @receiver = FactoryGirl.create(:receiver)
    #     end

    #     it "should not send nil to add_giver" do
    #         params_hsh  = {"gift"=>"{  \"twitter\" : \"875818226\",  \"receiver_email\" : \"ta@ta.com\",  \"receiver_phone\" : \"2052920036\",  \"giver_name\" : \"Addis Dev\",  \"service\" : 0.5,  \"total\" : 10,  \"provider_id\" : 58,  \"receiver_id\" : #{@receiver.id},  \"message\" : \"\",  \"credit_card\" : 77,  \"provider_name\" : \"Artifice\",  \"receiver_name\" : \"Addis Dev\",  \"giver_id\" : 115}","origin"=>"d","shoppingCart"=>"[{\"detail\":\"\",\"price\":10,\"item_name\":\"The Warhol\",\"item_id\":32,\"quantity\":1}]","token"=> @token}
    #         post :buy_gift, format: :json, gift: params_hsh["gift"] , shoppingCart: params_hsh["shoppingCart"], token: params_hsh["token"]
    #         gift = Gift.last
    #         gift.giver_name.should == "Jimmy Basic"
    #     end

    # end

end