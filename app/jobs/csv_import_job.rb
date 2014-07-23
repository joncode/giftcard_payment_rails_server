class CsvImportJob

	@queue :database


    def self.perform data

    	csv_import = CsvSocialImport.new(data)
    	resp = csv_import.save

    end

private

end