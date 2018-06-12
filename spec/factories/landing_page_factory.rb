module LandingPageFactory

	def create_landing_page
		menu_item_1 = FactoryGirl.create :menu_item, photo: "http://res.cloudinary.com/drinkboard/image/upload/v1414092460/sample_gift_item_ejpbyl.jpg"
		menu_item_2 = FactoryGirl.create :menu_item
		provider  = FactoryGirl.create :merchant
		campaign = FactoryGirl.create :campaign
		campaign_item = FactoryGirl.create :campaign_item,
			campaign_id: campaign.id,
			message: "First Come, First Served!",
			shoppingCart: "[{\"detail\":\"Good through Friday\",\"price\":13,\"price_promo\":10,\"quantity\":1,\"item_id\":#{menu_item_1.id},\"item_name\":\"Original Margarita \"}]",
			provider_id: provider.id
		affiliate = FactoryGirl.create :affiliate

		landing_page_params = {
			campaign_id: campaign.id,
			affiliate_id: affiliate.id,
			example_item_id: campaign_item.id,
			title: "We are a truly awesome bar.",
			template_id: nil
		}
		LandingPage.any_instance.stub_chain(:banner, :fullpath).and_return("http://res.cloudinary.com/drinkboard/image/upload/v1414092461/sample_header_x5vdk6.jpg")
		LandingPage.any_instance.stub_chain(:sponsor, :fullpath).and_return("http://res.cloudinary.com/drinkboard/image/upload/v1414703963/sponsor_photo_sample_mgzmo1.png")
		landing_page = FactoryGirl.create :landing_page, landing_page_params
		landing_page
	end

	def landing_page_json_fake
		provider = FactoryGirl.create :merchant
		{
			"campaign_id" => 12,
			"affiliate_id" => 12441,
			"title" => "We are a truly awesome bar.",
			"banner_photo_url" => nil,
			"link" => "landing_page_link",
			"example" => {
				"photo_url" => "http://res.cloudinary.com/drinkboard/image/upload/v1414092460/sample_gift_item_ejpbyl.jpg",
				"title" => "Original Margarita",
				"body" => "Good through Friday",
				"item_detail_zinger" => nil,
				"sponsor_photo_url" => nil
			},
			"items" => [
				{
					"campaign_item_id" => 343,
					"gift_detail" => nil,
					"loc_photo_url" => provider.image,
					"loc_name" => provider.name,
					"loc_street" => provider.address,
					"loc_zip" => provider.zip,
					"loc_city" => provider.city_name,
					"loc_state" => provider.state,
					"loc_phone" => provider.phone,
					"loc_zinger" => provider.zinger,
					"loc_detail" => provider.description,
					"detail" => "Good through Friday",
					"price" => 13,
					"price_promo" => 10,
					"quantity" => 1,
					"item_id" => 123,
					"item_name" => "Original Margarita",
					"photo_url" => "http://res.cloudinary.com/drinkboard/image/upload/v1414092460/sample_gift_item_ejpbyl.jpg"
				},
				{
					"campaign_item_id" => 344,
					"gift_detail" => nil,
					"loc_photo_url" => provider.image,
					"loc_name" => provider.name,
					"loc_street" => provider.address,
					"loc_zip" => provider.zip,
					"loc_city" => provider.city_name,
					"loc_state" => provider.state,
					"loc_phone" => provider.phone,
					"loc_zinger" => provider.zinger,
					"loc_detail" => provider.description,
					"detail" => "Good for a year!",
					"price" => 13,
					"price_promo" => 10,
					"quantity" => 1,
					"item_id" => 144,
					"item_name" => "Original Margarita",
					"photo_url" => nil
				}
			]
		}
	end

	# def create_page_json campaign, affiliaite


	# end

end