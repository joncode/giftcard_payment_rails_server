class OmnivoreLocation

	attr_reader :name, :id, :address, :phone, :website, :status, :raw,
		:pos_type, :health, :concept_name, :display_name, :development,
		:system_health, :ticket_status

	def initialize resp
		# @raw = resp
		@address = resp["address"].values.compact.join(', ')
		@concept_name = resp["concept_name"]
		@development = resp["development"]
		@display_name = resp["display_name"]
		@name = resp["name"]
		@id = resp["id"]
		@phone = resp["phone"]
		@website = resp["website"]
		@status = resp["status"]
		@pos_type = resp['pos_type']
		@health = resp['health']
		@system_health = @health['healthy']
		@ticket_status = @health['tickets']['status']

	end
end

# ["_links", "address", "concept_name", "created", "development", "display_name",
# "health", "id", "modified", "name", "owner", "phone", "pos_type", "status", "website"]