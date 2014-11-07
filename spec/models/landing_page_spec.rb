# require 'spec_helper'
# include LandingPageFactory

# describe LandingPage do

# 	before(:each) do
# 		LandingPage.delete_all
# 		Affiliate.delete_all
# 		Campaign.delete_all
# 		CampaignItem.delete_all
# 		LandingPage.delete_all
# 		MenuItem.delete_all
# 	end

# 	it "should build from factory" do
# 		landing_page = FactoryGirl.build :landing_page
# 		expect(landing_page).to be_valid
# 	end

#     context "Validations" do
# 		it "should require campaign_id" do
#         	landing_page = FactoryGirl.build :landing_page, { campaign_id: nil }
#         	expect(landing_page).to_not be_valid
# 		end
# 		it "should require affiliate_id" do
#         	landing_page = FactoryGirl.build :landing_page, { affiliate_id: nil }
#         	expect(landing_page).to_not be_valid
# 		end
#  	end

# 	describe "create" do
# 		before(:each) do
# 			@menu_item_1 = FactoryGirl.create :menu_item, photo: "http://res.cloudinary.com/drinkboard/image/upload/v1414092460/sample_gift_item_ejpbyl.jpg"
# 			@menu_item_2 = FactoryGirl.create :menu_item
# 			@provider  = FactoryGirl.create :provider
# 			@campaign = FactoryGirl.create :campaign
# 			@campaign_item_1 = FactoryGirl.create :campaign_item,
# 				campaign_id: @campaign.id,
# 				message: "First Come, First Served!",
# 				shoppingCart: "[{\"detail\":\"Good through Friday\",\"price\":13,\"price_promo\":10,\"quantity\":1,\"item_id\":#{@menu_item_1.id},\"item_name\":\"Original Margarita \"}]",
# 				provider_id: @provider.id
# 			@campaign_item_2 = FactoryGirl.create :campaign_item,
# 				campaign_id: @campaign.id,
# 				message: "We're Second to None!",
# 				shoppingCart: "[{\"detail\":\"Good for a year!\",\"price\":13,\"price_promo\":10,\"quantity\":1,\"item_id\":#{@menu_item_2.id},\"item_name\":\"Original Margarita \"}]",
# 				provider_id: @provider.id
# 			@affiliate = FactoryGirl.create :affiliate
# 			@landing_page_params = {
# 				campaign_id: @campaign.id,
# 				affiliate_id: @affiliate.id,
# 				example_item_id: @campaign_item_1.id,
# 				title: "We are a truly awesome bar.",
# 				template_id: nil
# 			}
# 			LandingPage.any_instance.stub_chain(:banner, :fullpath).and_return("http://res.cloudinary.com/drinkboard/image/upload/v1414092461/sample_header_x5vdk6.jpg")
# 			LandingPage.any_instance.stub_chain(:sponsor, :fullpath).and_return("http://res.cloudinary.com/drinkboard/image/upload/v1414703963/sponsor_photo_sample_mgzmo1.png")
# 		end

# 		it "should create new landing page" do
# 			LandingPage.create(@landing_page_params)
# 			expect(LandingPage.count).to eq(1)
# 			landing_page = LandingPage.last
# 			expect(landing_page.campaign).to eq(@campaign)
# 			expect(landing_page.affiliate).to eq(@affiliate)
# 			expect(landing_page.title).to eq("We are a truly awesome bar.")
# 			expect(landing_page.banner_photo_url).to eq("http://res.cloudinary.com/drinkboard/image/upload/v1414092461/sample_header_x5vdk6.jpg")
# 			expect(landing_page.sponsor_photo_url).to eq("http://res.cloudinary.com/drinkboard/image/upload/v1414703963/sponsor_photo_sample_mgzmo1.png")
# 			expect(landing_page.example_item_id).to eq(@campaign_item_1.id)
# 			expect(landing_page.link).to eq(nil)
# 		end

# 		it "should create correct page json" do
# 			LandingPage.create(@landing_page_params)
# 			landing_page = LandingPage.last
# 			page_json = {
# 				"campaign_id" => @campaign.id,
# 				"affiliate_id" => @affiliate.id,
# 				"title" => "We are a truly awesome bar.",
# 				"banner_photo_url" => "http://res.cloudinary.com/drinkboard/image/upload/v1414092461/sample_header_x5vdk6.jpg",
# 				"example" => {
# 					"photo_url" => "http://res.cloudinary.com/drinkboard/image/upload/v1414092460/sample_gift_item_ejpbyl.jpg",
# 					"title" => "Original Margarita ",
# 					"body" => "Good through Friday",
# 					"item_detail_zinger" => nil,
# 					"sponsor_photo_url" => "http://res.cloudinary.com/drinkboard/image/upload/v1414703963/sponsor_photo_sample_mgzmo1.png"
# 				},
# 				"items" => [
# 					{
# 						"campaign_item_id" => @campaign_item_1.id,
# 						"gift_detail" => nil,
# 						"loc_photo_url" => @provider.image,
# 						"loc_name" => @provider.name,
# 						"loc_street" => @provider.address,
# 						"loc_zip" => @provider.zip,
# 						"loc_city" => @provider.city,
# 						"loc_state" => @provider.state,
# 						"loc_phone" => @provider.phone,
# 						"loc_zinger" => @provider.zinger,
# 						"loc_detail" => @provider.description,
# 						"detail" => "Good through Friday",
# 						"price" => 13,
# 						"price_promo" => 10,
# 						"quantity" => 1,
# 						"item_id" => @menu_item_1.id,
# 						"item_name" => "Original Margarita ",
# 						"photo_url" => "http://res.cloudinary.com/drinkboard/image/upload/v1414092460/sample_gift_item_ejpbyl.jpg"
# 					},
# 					{
# 						"campaign_item_id" => @campaign_item_2.id,
# 						"gift_detail" => nil,
# 						"loc_photo_url" => @provider.image,
# 						"loc_name" => @provider.name,
# 						"loc_street" => @provider.address,
# 						"loc_zip" => @provider.zip,
# 						"loc_city" => @provider.city,
# 						"loc_state" => @provider.state,
# 						"loc_phone" => @provider.phone,
# 						"loc_zinger" => @provider.zinger,
# 						"loc_detail" => @provider.description,
# 						"detail" => "Good for a year!",
# 						"price" => 13,
# 						"price_promo" => 10,
# 						"quantity" => 1,
# 						"item_id" => @menu_item_2.id,
# 						"item_name" => "Original Margarita ",
# 						"photo_url" => nil
# 					}
# 				]
# 			}
# 			expect(landing_page.page_json).to eq(page_json)
# 		end
# 	end

# 	describe "build_from_template" do
# 		it "should make an exact copy of an existing landing page" do
# 			initial_page = create_landing_page
# 			campaign = Campaign.last
# 			campaign_item = CampaignItem.last
# 			affiliate = FactoryGirl.create :affiliate
# 			new_page = LandingPage.build_from_template(affiliate.id, initial_page.id)
# 			expect(LandingPage.count).to eq(2)
# 			expect(new_page.campaign).to eq(campaign)
# 			expect(new_page.affiliate).to eq(affiliate)
# 			expect(new_page.title).to eq("We are a truly awesome bar.")
# 			expect(new_page.banner_photo_url).to eq("http://res.cloudinary.com/drinkboard/image/upload/v1414092461/sample_header_x5vdk6.jpg")
# 			expect(new_page.sponsor_photo_url).to eq("http://res.cloudinary.com/drinkboard/image/upload/v1414703963/sponsor_photo_sample_mgzmo1.png")
# 			expect(new_page.example_item_id).to eq(campaign_item.id)
# 			expect(new_page.link).to eq(nil)
# 		end
# 	end

# end