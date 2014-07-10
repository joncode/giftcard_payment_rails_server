require 'spec_helper'

describe Mt::V2::ProtosController do

	before(:each) do
        @provider = FactoryGirl.create(:provider)
        request.env["HTTP_TKN"] = @provider.token
        @proto    = FactoryGirl.create(:proto, provider: @provider)
        @socials = []
        4.times do
        	@socials << FactoryGirl.create(:social)
        end
        @proto.socials << @socials

    end

	describe :gifts do

        it_should_behave_like("token authenticated", :post, :gifts, id: 123)

		it "should accept request for exisitng proto and return processing msg" do
			post :gifts, format: :json, id: @proto.id
			rrc 202
			json["status"].should == 1
			json["data"].should   == "Request for #{@socials.count} gifts from #{@proto.giver_name} received."
		end

		it "should respond not gifts to make when proto is already completed" do
			pjs = @proto.proto_joins
			fake_id = 678
			pjs.each do |pj|
				pj.update(gift_id: fake_id)
				fake_id += 1
			end
			post :gifts, format: :json, id: @proto.id
			rrc 201
			json["status"].should == 1
			json["data"].should   == "All gifts have already been created for gift prototype #{@proto.id}"
		end

		it "should not accept request when proto is not found" do
			post :gifts, format: :json, id:234
			rrc 404
			# json["status"].should == 0
			# json["data"].should   == "Unable to find gift protoype 234"
		end

	end

end