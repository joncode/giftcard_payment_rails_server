module PositronicsUtils
    extend ActiveSupport::Concern

    def tickets(loc_id, next_link=nil)
    	hsh = {}
    	tag = "tickets"
    	tag += next_link.split('tickets')[1] if next_link.present?
    	resp = get(:locations, loc_id, tag)
    	tics = resp["_embedded"]["tickets"]
    	if tics.kind_of?(Array)
    		hsh["tickets"] = tics#.map { |t| PosTicket.new t }
	    	if resp["_links"]["next"].present?
	    		hsh["next"] = resp["_links"]["next"]["href"]
	    	end
	    	if resp["_links"]["prev"].present?
	    		hsh["prev"] = resp["_links"]["prev"]["href"]
	    	end
    	else
    		hsh["error"] = "Error"
    		hsh["tickets"] = []
    	end
    	hsh
    end

    def get resource, obj_id=nil, meth=nil
    	obj_id = obj_id.present? ? (obj_id + "/") : nil
    	response = RestClient.get(
		    "#{POSITRONICS_API_URL}/#{resource}/#{obj_id}#{meth}",
		    {:content_type => :json, :'Api-Key' => POSITRONICS_API_KEY }
		)
		JSON.parse response
    end

end


















