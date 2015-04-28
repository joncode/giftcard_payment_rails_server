class InternalMailerJob
	extend EmailerInternal

	@queue = :r_email

	def self.perform data
		return nil if data['method'].nil? || data['args'].nil?

		self.send(data['method'], data['args'])
	end

end