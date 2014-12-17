require 'spec_helper'

describe Admt::V2::BrandsController do

    before(:each) do
        Brand.delete_all

         # should require valid admin credentials in every spec
        unless admin_user = AtUser.find_by(remember_token: "Token")
            FactoryGirl.create(:admin_user, remember_token: "Token")
        end
        request.env["HTTP_TKN"] = "Token"
    end

    describe "#create" do

        it_should_behave_like("token authenticated", :post, :create)

        it "should create new brand" do
            new_brand_hsh = { "name" => "Starwood" , "website" => "www.starwood.com" , "description" => "AMAZING!", "photo" => "res.cloudinary.com/drinkboard/images/kasdhfiaoewhfas.png"}
            post :create, format: :json, data: new_brand_hsh
            brand = Brand.last
            brand.name.should        == new_brand_hsh["name"]
            brand.description.should == new_brand_hsh["description"]
            brand.website.should     == new_brand_hsh["website"]
            brand.photo.should       == new_brand_hsh["city"]
            brand.active.should      be_true
        end

        it "should return validation errors when failed validation" do
            new_brand_hsh = { "name" => "" , "website" => "www.starwood.com" , "description" => "AMAZING!", "photo" => "res.cloudinary.com/drinkboard/images/kasdhfiaoewhfas.png"}
            post :create, format: :json, data: new_brand_hsh
            json["status"].should == 0
            json["data"].class.should == Hash
        end

    end


    describe "#update" do

        it_should_behave_like("token authenticated", :put, :update, id: 1)


        {
            name: "House Bar",
            description: "really crappy place",
            website: "www.fake.com"
        }.stringify_keys.each do |type_of, identifier|

            it "should update #{type_of}" do
                brand = FactoryGirl.create(:brand)
                new_brand_hsh = { type_of => identifier }
                put :update, id: brand.id, format: :json, data: new_brand_hsh
                brand = Brand.find(brand.id)
                brand.send(type_of).should == identifier
            end

        end

        it "should update cropped photo" do
            brand = FactoryGirl.create(:brand)
            photo_url = "http://res.cloudinary.com/drinkboard/image/upload/asdfhjaieroifhaw.jpeg"
            new_brand_hsh = { "photo" => photo_url }
            put :update, id: brand.id, format: :json, data: new_brand_hsh
            brand = Brand.find(brand.id)
            brand.get_photo.should == photo_url
        end
    end

end