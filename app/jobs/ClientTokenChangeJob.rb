class ClientTokenChangeJob

	@queue = :database

    def self.perform session_token_id, client_id
    	sst = SessionToken.find session_token_id
    	client = Client.find client_id
    	if sst.client_id == 2

    		if [6,7].include?(client_id)

    			sst.update(client_id: client_id)

    		end

    	else

    		puts " ClientTokenChangeJob ----  DENIED SESSION TOKEN NOT CLIENT TOKEN ---- (500 Internal)"

    	end


    end



end