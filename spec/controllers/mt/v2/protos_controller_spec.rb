require 'spec_helper'

include ProtoFactory

describe Mt::V2::ProtosController do

	before(:each) do
		proto_with_socials
        request.env["HTTP_TKN"] = @pws_provider.token
    end

	describe :gifts do

        it_should_behave_like("token authenticated", :post, :gifts, id: 123)

		it "should accept request for exisitng proto and return processing msg" do
			post :gifts, format: :json, id: @pws_proto.id
			rrc 202
			json["status"].should == 1
			json["data"].should   == "Request for #{@pws_socials.count} gifts from #{@pws_proto.giver_name} received."

			proto_with_users
			post :gifts, format: :json, id: @pwu_proto.id
			rrc 202
			json["status"].should == 1
			json["data"].should   == "Request for #{@pws_socials.count} gifts from #{@pws_proto.giver_name} received."
		end

		it "should thread off the call to the bulk gift creator" do
			ResqueSpec.reset!
			post :gifts, format: :json, id: @pws_proto.id
			rrc 202
			ProtoGifterJob.should_receive(:perform)
			run_delayed_jobs
		end

		it "should respond not gifts to make when proto is already completed" do
			pjs = @pws_proto.proto_joins
			fake_id = 678
			pjs.each do |pj|
				pj.update(gift_id: fake_id)
				fake_id += 1
			end
			post :gifts, format: :json, id: @pws_proto.id
			rrc 202
			json["status"].should == 1
			json["data"].should   == "Request for #{@pws_proto.giftables.count} gifts from Factory Provider Staff received."
		end

		it "should not accept request when proto is not found" do
			post :gifts, format: :json, id:234
			rrc 404
			# json["status"].should == 0
			# json["data"].should   == "Unable to find gift protoype 234"
		end

	end

end