require 'spec_helper'

include ProtoFactory

describe ProtoGifterJob do

    describe :perform do

   	    before(:each) do
	        proto_with_socials 2
	        @pj        = ProtoJoin.where(receivable_type: "Social").first
	        @proto 	   = @pj.proto
	        @gift_hsh  = { 'proto_join' => @pj, 'proto' => @proto }
	    end

    	it "should complete the transfer to the gift_proto.rb" do
    		ProtoGifterJob.perform(@proto.id)
	    	gift = Gift.last
	    	gift.payable.should == @proto
    	end

    	it "should batch the proto_joins" do
    		ProtoGifterJob.perform(@proto.id)
	    	gs = Gift.order created_at: :desc
	    	(gs[0].created_at - gs[1].created_at).should > 0.1.second
    	end

    end

end