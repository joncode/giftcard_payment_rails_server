class ClientContents < ActiveRecord::Base

	validates_uniqueness_of :content_id, :content_type, :client_id

#	-------------





#	-------------


end
