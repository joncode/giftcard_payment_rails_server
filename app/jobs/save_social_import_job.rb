class SaveSocialImportJob

    @queue = :database

    def self.perform data
    	social = SaveSocialImport.process(data["email"], data["provider_id"], data["proto_id"])
    	puts "\nhere is the input #{data.inspect} - and the social = #{social.inspect}"
    end

end