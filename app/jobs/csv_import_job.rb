class CsvImportJob

    @queue = :database


    def self.perform data
    	log_bars "input #{data.inspect}"
    	csv_import = CsvSocialImport.new(data)
    	log_bars "import obj #{csv_import.inspect}"
    	resp = csv_import.save
    	log_bars "response #{resp.inspect}"
    end

private

end