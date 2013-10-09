require 'spec_helper'

describe AppController do

    describe "#providers" do
        before do
            User.delete_all
            Provider.delete_all
            @user            = FactoryGirl.create :user
            @first_provider  = FactoryGirl.create :provider
            @second_provider = FactoryGirl.create :provider
        end

        it "should send all providers with correct scope" do
            post :providers, format: :json, city: "New York", token: @user.remember_token
            puts json
            p_ary = json
            p_ary[0].should == @first_provider.serialize
            p_ary[1].should == @second_provider.serialize
        end

        it "should send all providers with photo key and full URL" do
            post :providers, format: :json, city: "New York", token: @user.remember_token
            puts json
            json.each do |j|
                photo = j["photo"]
                photo.class.should == String
                photo.match("http://").should_not be_nil
            end

        end
    end

end





# response
# [
# { city: "Las Vegas", name: "American Fish", photo: { photo: { url: "http://res.cloudinary.com/hsdbwezkg/image/upload/v1368884650/ryoiufxfnypv90oerl37.jpg" } }, phone: ... },
# { city: "Las Vegas", name: "Artifice" photo: { photo: { url: "http://res.cloudinary.com/hsdbwezkg/image/upload/v1372783758/utucnqk55jfbfvkxtft4.jpg" } }, phone: ... },
# { city: "Las Vegas", name: "Blue Limon" photo: "http://res.cloudinary.com/drinkboard/image/upload/v1375763254/dylssmstvcpynfusivtr.jpg", phone: ... },
# { city: "Las Vegas", name: "Double Down Saloon" photo: { photo: { url: "http://res.cloudinary.com/hsdbwezkg/image/upload/v1368884947/jfxow40nq7wcvg32ee2f.jpg" } }, phone: ... },
# { city: "Las Vegas", name: "Encore" photo: "http://res.cloudinary.com/drinkboard/image/upload/v1349150293/upqygknnlerbevz4jpnw.png", phone: ... }
# ]