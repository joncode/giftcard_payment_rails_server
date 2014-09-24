require 'spec_helper'

include ProtoFactory

describe ProtoGifterJob do

    describe :perform do

   	    before(:each) do
            Gift.delete_all
	        proto_with_socials 4
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

    	# it "should re_run the job when contacts are added after" do
    	# 	@proto.update(contacts: 10)
    	# end

        it "should recored the correct number of contacts and processed" do
            @proto.giftables.count.should == 4
            @proto.contacts.should        == 4
            @proto.processed.should       == 0
            ProtoGifterJob.perform(@proto.id)
            Gift.count.should             == 4
            @proto.reload
            @proto.giftables.count.should == 0
            @proto.processed.should       == 4
            @proto.contacts.should        == 4
        end

    end



end