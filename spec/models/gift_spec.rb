require 'spec_helper'


describe Gift do

    it_should_behave_like "payable ducktype" do
        let(:object) { FactoryGirl.build(:gift) }
    end

	it "builds from factory" do
		gift = FactoryGirl.build :gift
		gift.should be_valid
		gift.save
	end

	it "requires giver" do
		gift = FactoryGirl.build(:gift, :giver => nil)
		gift.should_not be_valid
		gift.should have_at_least(1).error_on(:giver)
	end

	it "requires receiver_name" do
		gift = FactoryGirl.build(:gift, :receiver_name => nil)
		gift.should_not be_valid
		gift.should have_at_least(1).error_on(:receiver_name)
	end

	it "requires provider_id" do
		gift = FactoryGirl.build(:gift, :provider_id => nil)
		gift.should_not be_valid
		gift.should have_at_least(1).error_on(:provider_id)
	end

	it "requires value" do
		gift = FactoryGirl.build(:gift, :value => nil)
		gift.should_not be_valid
		gift.should have_at_least(1).error_on(:value)
	end

	it "requires cat" do
		user = FactoryGirl.create :user
		provider = FactoryGirl.create :provider
		gift = Gift.create(giver: user, receiver_name: user.name, receiver_email: user.email, provider_id: provider.id, value: "100", shoppingCart: "[{\"detail\":null,\"price\":13,\"quantity\":1,\"item_id\":82,\"item_name\":\"Original Margarita \"}]")
		gift.should_not be_valid
		gift.should have_at_least(1).error_on(:cat)
	end

	it "requires shoppingCart" do
		gift = FactoryGirl.build(:gift, :shoppingCart => nil)
		gift.should_not be_valid
		gift.should have_at_least(1).error_on(:shoppingCart)
	end

	it "should save gift_items on create" do
		gift = FactoryGirl.build(:gift)
		gift.save
		items = JSON.parse gift.shoppingCart
		gift.gift_items.count.should == items.count
		gift.gift_items.first.menu_id.should == items.first["item_id"]
	end

	it "should save sale as payable on create" do
		gift = FactoryGirl.build(:gift)
		sale = FactoryGirl.build(:sale)
		gift.payable = sale
		gift.save
		saved_gift = Gift.last
		saved_gift.payable.should == Sale.last
	end

	it "should get the provider name if it does not have one" do
		gift = FactoryGirl.build(:gift, :provider_name => nil)
		gift.save
		gift.provider_name.should_not be_nil
	end

    it "should not run add provider if it has provider ID and name" do
        Gift.any_instance.should_not_receive(:add_provider_name)
        gift = FactoryGirl.create(:gift, :provider_name => "Jelly Donut")
    end

    it "should downcase an capitalized receiver_email" do
        gift = FactoryGirl.create(:gift, receiver_email: "JONMERCHANT@GMAIL.COM")
        gift.receiver_email.should == "JONMERCHANT@GMAIL.COM".downcase
    end

    it "should validate email" do
        gift = FactoryGirl.build(:gift, receiver_email: "JONMERCHANT")
        gift.should_not be_valid
        gift.should have_at_least(1).error_on(:receiver_email)
    end

    it "should not validate email when a receiver_id is present" do
        gift = FactoryGirl.build(:gift, receiver_id: 2, receiver_email: "JONMERCHANT")
        gift.should be_valid
        gift.should have_at_most(0).error_on(:receiver_email)
    end

    it "should format cost to be money string" do
        gift = FactoryGirl.create(:gift, receiver_email: "jonmerchat@gmail.com", cost: "31.049999999")
        gift.cost.should == "31.05"
    end

    it "should format nil cost to be money string" do
        gift = FactoryGirl.create(:gift, receiver_email: "jonmerchat@gmail.com", cost: nil)
        gift.cost.should == "0"
    end

    it "should format value to be money string" do
        gift = FactoryGirl.create(:gift, receiver_email: "jonmerchat@gmail.com", value: "36.49999999")
        gift.value.should == "36.50"
    end

    it "should resave legacy gift with currency formats" do
        gift = FactoryGirl.create(:gift, receiver_email: "jonmerchat@gmail.com")
        gift.update_columns(cost: "31.049999999", value: "36.49999999" )
        gift.cost.should  == "31.049999999"
        gift.value.should == "36.49999999"
        gift.save
        gift.cost.should  == "31.05"
        gift.value.should == "36.50"
    end

	describe :update do

		it "should extract phone digits" do
			gift = FactoryGirl.create(:gift)
			gift.update_attributes({ "receiver_phone" => "262-554-3628" })
			gift.reload
			gift.receiver_phone.should == "2625543628"
		end

		it "should save sale as refund on update" do
			gift = FactoryGirl.build(:gift)
			sale = FactoryGirl.build(:sale)
			gift.payable = sale
			gift.save
			sale.reload
			saved_gift = Gift.find_by(payable_id: sale.id)
			refund = FactoryGirl.create(:sale)
			saved_gift.update(refund: refund)
			saved_gift.reload
			refund.reload
			saved_gift.refund_id.should == refund.id
			saved_gift.refund_type.should == refund.class.to_s
			refund.refunded.should == saved_gift
		end
	end

	it "should associate with a user as giver" do
		user = FactoryGirl.create(:user)
		gift = FactoryGirl.build(:gift)
		gift.giver = user
		gift.save
		gift.giver.id.should    == user.id
		gift.giver.name.should  == user.name
		gift.giver_name.should  == user.name
		gift.giver_id.should    == user.id
		gift.giver.class.should == User
	end

	it "should associate with a BizUser as giver" do
		biz_user = FactoryGirl.create(:provider).biz_user

		gift = FactoryGirl.create(:gift, giver: biz_user)

		gift.reload
		gift.giver.id.should    == biz_user.id
		gift.giver.name.should  == biz_user.name
		gift.giver.class.should == BizUser
	end

	it "should associate with a user as receiver" do
		user = FactoryGirl.create(:user)
		gift = FactoryGirl.create(:gift, receiver: user)

		gift.reload
		gift.receiver.id.should    == user.id
		gift.receiver.name.should  == user.name
		gift.receiver_name.should  == user.name
		gift.receiver_id.should    == user.id
		gift.receiver.class.should == User
	end

	it "should associate with provider" do
		provider = FactoryGirl.create(:provider)
		gift = FactoryGirl.create(:gift, provider: provider)

		gift.reload
		gift.provider.id.should    == provider.id
		gift.provider.name.should  == provider.name
		gift.provider_id.should    == provider.id
		gift.provider_name.should  == provider.name
		gift.provider.class.should == Provider
	end

	it "should associate with a Sale as payment" do
		sale = FactoryGirl.create(:sale)

		gift = FactoryGirl.build(:gift)
		gift.payable = sale
		gift.save

		gift.payable.id.should       == sale.id
		gift.payable.class.should    == Sale
		gift.payable.resp_code.should == sale.resp_code
	end

	it "should associate with a Debt as payment" do
		debt = FactoryGirl.create(:debt)

		gift = FactoryGirl.create(:gift, payable: debt)

		gift.reload
		gift.payable.id.should      == debt.id
		gift.payable.class.should   == Debt
	end

	it "should associate with another Gift as payable" do
		gift  = FactoryGirl.create(:gift)
		gift2 = FactoryGirl.create(:gift, payable: gift)

		gift2.reload
		gift2.payable.id.should     == gift.id
		gift2.payable.class.should  == Gift
	end

	it "should set the status of parent Gift to regifted" do
		gift  = FactoryGirl.create(:gift)
		gift2 = FactoryGirl.create(:gift, payable: gift)
        gift.reload
        gift.status.should   == "regifted"
        gift.pay_stat.should == "charge_regifted"
	end

	it "should save the total as string" do
		gift = FactoryGirl.create(:gift, value: "100.00")
		gift.value.should == "100"
		gift.total.should == "100"
	end

	context	"save with oauth credentials only" do

		it "should accept create gift with oauth key and save data to oauth.db" do
			oauth = FactoryGirl.build(:oauth)
			gift  = FactoryGirl.create(:gift, oauth: oauth)
			gift.id.should_not be_nil
			oauth.reload.id.should_not be_nil
			oauth.gift_id.should == gift.id
		end

	    it "should save automatically with gift" do
	        gift  = FactoryGirl.build(:gift)
	        oauth = FactoryGirl.build(:oauth, gift_id: nil)
	        gift.oauth = oauth
	        gift.save
	        oauth.reload
	        oauth.id.should_not be_nil
	        gift.oauth.should       == oauth
	        oauth.gift_id.should    == gift.id
	    end

		it "should accept hash of oauth data and autosave" do
            hsh  =  {"token"=>"9q3562341341", "secret"=>"92384619834", "network"=>"twitter", "network_id"=>"9865465748", "handle"=>"razorback", "photo"=>"cdn.akai.twitter/791823401974.png"}
	        gift = FactoryGirl.build(:gift)
	       	gift.receiver_oauth = hsh
	        gift.save
	        oauth = gift.oauth
	        oauth.id.should_not be_nil
	        gift.oauth.should       == oauth
	        oauth.gift_id.should    == gift.id
		end

		it "should reject hash and gift save when oauth data network id is missing" do
            hsh  =  {"token"=>"9q3562341341", "secret"=>"92384619834", "network"=>"twitter", "handle"=>"razorback", "photo"=>"cdn.akai.twitter/791823401974.png"}
	        gift = FactoryGirl.build(:gift, receiver_email: nil)
	       	gift.receiver_oauth = hsh
	        gift.save
	        oauth = gift.oauth
	        oauth.id.should be_nil
	        gift.oauth.should   == oauth
	        oauth.gift_id.should   be_nil
	        gift.id.should be_nil
		end

		it "should reject hash and gift save when oauth data is not complete" do
            hsh  =  { "secret"=>"92384619834", "network"=>"twitter", "network_id"=>"9865465748", "handle"=>"razorback", "photo"=>"cdn.akai.twitter/791823401974.png"}
	        gift = FactoryGirl.build(:gift, receiver_email: nil)
	       	gift.receiver_oauth = hsh
	        gift.save
	        oauth = gift.oauth
	        oauth.id.should be_nil
	        gift.oauth.should   == oauth
	        oauth.gift_id.should   be_nil
	        gift.id.should be_nil
		end

		it "should find the receiver with oauth data and auto associate" do
            user = FactoryGirl.create(:user, twitter: "9865465748")
            hsh  =  {"token"=>"9q3562341341", "secret"=>"92384619834", "network"=>"twitter", "network_id"=>"9865465748", "handle"=>"razorback", "photo"=>"cdn.akai.twitter/791823401974.png"}
	        gift = FactoryGirl.build(:gift)
	       	gift.receiver_oauth = hsh
	        gift.save
	        gift.reload
			gift.receiver_id.should == user.id
			receiver = gift.receiver
			receiver.twitter.should == gift.twitter
		end

		it "should save gift when no oauth is present" do
			gift  = FactoryGirl.create(:gift, oauth: nil)
			no_oauth = Oauth.find_by(gift_id: gift.id)
			no_oauth.should be_nil
		end
	end

	context "save with sale" do

	    it "should save the giver and the provider from the gift when saved via Gift" do
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
	        args["card_id"]     = card.id
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
	        sale.gift.should     == gift
	        sale.giver_id.should == gift.giver_id

	        sale.giver.should    == gift.giver

	        sale.provider_id.should == gift.provider_id
	    end
	end

	context "receiver Information" do

		let(:giver) { FactoryGirl.create(:user, first_name: "Howard", last_name: "Stern", email: "howard@stern.com")}
		let(:provider) { FactoryGirl.create(:provider) }

		it "should find a receiver via email & secondary email and add to gift" do
			user = FactoryGirl.create(:user, first_name: "Tommy", last_name: "Trash", email: "tony@email.com")
			gift = FactoryGirl.create(:gift_no_association, giver: giver, provider: provider, receiver_name: user.name, receiver_email: user.email)
			gift.reload
			gift.receiver_id.should == user.id

			user.email = "second@tony.com"
			user.save
			gift = FactoryGirl.create(:gift_no_association, giver: giver, provider: provider, receiver_name: user.name, receiver_email: "tony@email.com")
			gift.reload
			gift.receiver_id.should == user.id
		end

		it "should find a receiver via facebook_id & secondary facebook_id  and add to gift" do
			user = FactoryGirl.create(:user, first_name: "Tommy", last_name: "Trash", facebook_id: "123456789")
			gift = FactoryGirl.create(:gift_no_association, giver: giver, provider: provider, receiver_name: user.name, facebook_id: user.facebook_id)
			gift.reload
			gift.receiver_id.should == user.id
			user.facebook_id = "456876234"
			user.save
			gift = FactoryGirl.create(:gift_no_association, giver: giver, provider: provider, receiver_name: user.name, facebook_id: "123456789")
			gift.reload
			gift.receiver_id.should == user.id
		end

		it "should find a receiver via phone & secondary phone  and add to gift" do
			user = FactoryGirl.create(:user, first_name: "Tommy", last_name: "Trash", phone: "2154007586")
			gift = FactoryGirl.create(:gift_no_association, giver: giver, provider: provider, receiver_name: user.name, receiver_phone: user.phone)
			gift.reload
			gift.receiver_id.should == user.id
			user.phone = "4568762342"
			user.save
			gift = FactoryGirl.create(:gift_no_association, giver: giver, provider: provider, receiver_name: user.name, receiver_phone: "2154007586")
			gift.reload
			gift.receiver_id.should == user.id
		end

		it "should find a receiver via twitter & secondary twitter  and add to gift" do
			user = FactoryGirl.create(:user, first_name: "Tommy", last_name: "Trash", twitter: "987654765")
			gift = FactoryGirl.create(:gift_no_association, giver: giver, provider: provider, receiver_name: user.name, twitter: user.twitter)
			gift.reload
			gift.receiver_id.should == user.id
			user.twitter = "777777777"
			user.save
			gift = FactoryGirl.create(:gift_no_association, giver: giver, provider: provider, receiver_name: user.name, twitter: "987654765")
			gift.reload
			gift.receiver_id.should == user.id
		end

		it "should not look for a receiver when it already has an ID" do
			user  = FactoryGirl.create(:user, first_name: "Tommy", last_name: "Trash", twitter: "987654765")
			user2 = FactoryGirl.create(:user, first_name: "Keepr", last_name: "McGee", twitter: "676767676" )
			gift  = FactoryGirl.create(:gift_no_association, giver: giver, receiver_id: user2.id, provider: provider, receiver_name: user2.name, twitter: user.twitter)
			gift.reload
			gift.receiver_id.should == user2.id
		end

		it "should not save a gift when no unique receiver info is provided" do
			gift = FactoryGirl.build(:gift_no_association, giver: giver, provider: provider, receiver_name: "No Uniques", receiver_email: nil)
			gift.save
			gift.should have_at_least(1).error_on(:receiver)
			gift.errors.messages[:receiver].should == ["No unique receiver data. Cannot process gift. Please re-log in if this is an error."]
		end
	end

	context "status" do

		let(:giver) { FactoryGirl.create(:user, first_name: "Howard", last_name: "Stern", email: "howard@stern.com")}
		let(:provider) { FactoryGirl.create(:provider) }
		let(:gift) { FactoryGirl.create(:gift_no_association, giver: giver, provider: provider, receiver_name: "George Washington", receiver_phone: "8326457787") }

		context	"incomplete" do

		  	it "should correctly rep incomplete" do
		  		gift.receiver_id.should be_nil
		  		gift.status.should 				== 'incomplete'
		  		gift.giver_status.should 		== 'incomplete'
		  		gift.receiver_status.should 	== 'incomplete'
		  		gift.bar_status.should 			== 'live'
		  	end

	        it_should_behave_like "gift serializer" do
	            let(:object) { gift }
	        end
		end

		context	"open" do

			before(:each) do
				gift.receiver_id = giver.id
		  		gift.status = 'open'
			end

		  	it "should correctly rep open" do
		  		gift.save
		  		gift.status.should 				== 'open'
		  		gift.giver_status.should 		== 'notified'
		  		gift.receiver_status.should 	== 'notified'
		  		gift.bar_status.should 			== 'live'
		  	end

	        it_should_behave_like "gift serializer" do
	            let(:object) { gift }
	        end
		end

		context	"notified" do

			before(:each) do
				gift.receiver_id = giver.id
		  		gift.update(status: 'notified')
			end

		  	it "should correctly rep notified" do
		  		gift.status.should 				== 'notified'
		  		gift.giver_status.should 		== 'notified'
		  		gift.receiver_status.should 	== 'open'
		  		gift.bar_status.should 			== 'live'
		  	end

	        it_should_behave_like "gift serializer" do
	            let(:object) { gift }
	        end
		end

		context	"redeemed" do

			before(:each) do
		  		gift.receiver_id = giver.id
		  		gift.update(status: 'redeemed', redeemed_at: Time.now)
			end

		  	it "should correctly rep redeemed" do
		  		gift.status.should 				== 'redeemed'
		  		gift.giver_status.should 		== 'complete'
		  		gift.receiver_status.should 	== 'redeemed'
		  		gift.bar_status.should 			== 'redeemed'
		  	end

	        it_should_behave_like "gift serializer" do
	            let(:object) { gift }
	        end
		end

		context	"regifted" do

			before(:each) do
		  		gift.receiver_id = giver.id
		  		gift.update(status: 'regifted')
		  		gift.update(status: 'regifted', redeemed_at: Time.now)
			end

		  	it "should correctly rep regifted" do
		  		gift.status.should 				== 'regifted'
		  		gift.giver_status.should 		== 'complete'
		  		gift.receiver_status.should 	== 'regifted'
		  		gift.bar_status.should 			== 'regifted'
		  	end

	        it_should_behave_like "gift serializer" do
	            let(:object) { gift }
	        end
		end

		context	"cancel" do

			before(:each) do
		  		gift.update(status: 'cancel')
			end

		  	it "should correctly rep cancel" do
		  		gift.status.should 				== 'cancel'
		  		gift.giver_status.should 		== 'cancel'
		  		gift.receiver_status.should 	== 'cancel'
		  		gift.bar_status.should 			== 'cancel'
		  	end

	        it_should_behave_like "gift serializer" do
	            let(:object) { gift }
	        end
		end

		context	"expired" do

			before(:each) do
		  		gift.update(status: 'expired', expires_at: Time.now)
			end

		  	it "should correctly rep expired" do
		  		gift.status.should 				== 'expired'
		  		gift.giver_status.should 		== 'expired'
		  		gift.receiver_status.should 	== 'expired'
		  		gift.bar_status.should 			== 'expired'
		  	end

	        it_should_behave_like "gift serializer" do
	            let(:object) { gift }
	        end
	  	end
	end

	context "void_refund_cancel" do

		before do
			@user = FactoryGirl.create(:user)
			@card = FactoryGirl.create(:visa, name: @user.name, user_id: @user.id)
			@gift = FactoryGirl.build(:gift, giver_id: @user.id, giver_name: @user.name)
			revenue = BigDecimal(@gift.value)
			@sale = FactoryGirl.build(:sale, revenue: revenue, giver_id: @user.id)
			@gift.payable = @sale
			@gift.giver   = @user
			@gift.save
		end

		context "success" do

			it "should save refund to gift , set status to cancel and set pay_stat to refund_cancel on success" do
        		auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,345783945,,,#{@sale.revenue},CC,credit,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
        		stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

				@gift.void_refund_cancel
				@gift.reload

				refund = @gift.refund

				@gift.status.should 				== 'cancel'
				@gift.pay_stat.should 				== 'refund_cancel'
				@gift.payable_id.should 			== @sale.id

				refund.class.should 				== Sale
				refund.id.should_not 				== @sale.id
				refund.transaction_id.should_not 	== @sale.transaction_id
				refund.revenue.should 				== @sale.revenue
				refund.giver_id.should 				== @gift.giver_id
			end

			it "should return response reason text and status = 1 on success" do
        		auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,345783945,,,#{@sale.revenue},CC,credit,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
        		stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

				resp_hsh = @gift.void_refund_cancel
				resp_hsh["msg"].should 	== "This transaction has been approved."
				resp_hsh["status"].should 		== 1
			end
		end

		context "fail" do

			it "should save gift_id on the refund , but not change status or pay_stat" do
				auth_response = "2,2,2,You have exceeded the credit available for this transaction.,JVT36N,Y,345783945,,,#{@sale.revenue},CC,credit,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
				stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

				@gift.void_refund_cancel
				@gift.reload

				refund = @gift.refund

				@gift.status.should_not 			== 'cancel'
				@gift.pay_stat.should_not 			== 'refund_cancel'
				@gift.payable_id.should 			== @sale.id

				refund.class.should 				== Sale
				refund.id.should_not 				== @sale.id
				refund.transaction_id.should_not 	== @sale.transaction_id
				refund.revenue.should 				== @sale.revenue
				refund.giver_id.should 				== @gift.giver_id
			end

			it "should return response reason text and status = 0 on failed" do
				auth_response = "2,2,2,You have exceeded the credit available for this transaction.,JVT36N,Y,345783945,,,#{@sale.revenue},CC,credit,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
				stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

				resp_hsh = @gift.void_refund_cancel
				resp_hsh["msg"].should 	== "You have exceeded the credit available for this transaction. ID = #{@gift.id}."
				resp_hsh["status"].should 		== 0
			end
		end

	end

	context "void_refund_live" do

		before do
			@user = FactoryGirl.create(:user)
			@card = FactoryGirl.create(:visa, name: @user.name, user_id: @user.id)
			@gift = FactoryGirl.build(:gift, giver_id: @user.id, giver_name: @user.name)
			revenue = BigDecimal(@gift.value)
			@sale = FactoryGirl.build(:sale, revenue: revenue, giver_id: @user.id)
			@gift.payable = @sale
			@gift.giver = @user
			@gift.save
			@status = @gift.status

		end

		context "success" do

			it "should save refund to gift ,  set pay_stat to refund_comp on success" do
        		auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,345783945,,,#{@sale.revenue},CC,credit,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
        		stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

				@gift.void_refund_live
				@gift.reload

				refund = @gift.refund

				@gift.status.should 				== @status
				@gift.pay_stat.should 				== 'refund_comp'
				@gift.payable_id.should 			== @sale.id
				refund.class.should 				== Sale
				refund.id.should_not 				== @sale.id
				refund.transaction_id.should_not 	== @sale.transaction_id
				refund.revenue.should 				== @sale.revenue
				refund.giver_id.should 				== @gift.giver_id
			end

			it "should return response reason text and status = 1 on success" do
        		auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,345783945,,,#{@sale.revenue},CC,credit,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
        		stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

				resp_hsh = @gift.void_refund_live
				resp_hsh["msg"].should 	== "This transaction has been approved."
				resp_hsh["status"].should 		== 1
			end
		end

		context "fail" do

			it "should save gift_id on the refund , but not change status or pay_stat" do
				auth_response = "3,2,33,A valid referenced transaction ID is required.,JVT36N,Y,345783945,,,#{@sale.revenue},CC,credit,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
				stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

				@gift.void_refund_live
				@gift.reload

				refund = @gift.refund

				@gift.status.should 	 			== @status
				@gift.pay_stat.should_not			== 'refund_comp'
				@gift.payable_id.should 			== @sale.id
				refund.class.should 				== Sale
				refund.id.should_not 				== @sale.id
				refund.transaction_id.should_not 	== @sale.transaction_id
				refund.revenue.should 				== @sale.revenue
				refund.giver_id.should 				== @gift.giver_id
			end

			it "should return response reason text and status = 0 on failed" do
				auth_response = "2,2,2,You have exceeded the credit available for this transaction.,JVT36N,Y,345783945,,,#{@sale.revenue},CC,credit,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
				stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

				resp_hsh = @gift.void_refund_live
				resp_hsh["msg"].should 	== "You have exceeded the credit available for this transaction. ID = #{@gift.id}."
				resp_hsh["status"].should 		== 0
			end
		end
	end
end

# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  total          :string(20)
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  facebook_id    :string(255)
#  anon_id        :integer
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
#  cost           :string(255)
#

