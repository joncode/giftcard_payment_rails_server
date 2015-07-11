module ProtoFactory

	def proto_with_socials receivables=4
        @pws_provider = FactoryGirl.create(:merchant)
        @pws_giver    = FactoryGirl.create(:campaign)
        @pws_proto    = FactoryGirl.create(:proto, merchant: @pws_provider, giver: @pws_giver, contacts: receivables)
        @pws_socials = []
        receivables.times do
        	@pws_socials << FactoryGirl.create(:social)
        end
        @pws_proto.socials << @pws_socials
	end

	def proto_with_users receivables=4
        @pwu_provider = FactoryGirl.create(:merchant)
        @pwu_giver    = FactoryGirl.create(:campaign)
        @pwu_proto    = FactoryGirl.create(:proto, merchant: @pwu_provider, giver: @pwu_giver, contacts: receivables)
        @pwu_users = []
        receivables.times do
        	@pwu_users << FactoryGirl.create(:user)
        end
        @pwu_proto.users << @pwu_users
	end


end