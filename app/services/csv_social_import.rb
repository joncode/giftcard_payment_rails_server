class CsvSocialImport

    extend  ActiveModel::Naming
    include ActiveModel::Model

    attr_accessor :file, :status, :provider_id, :proto_id

    def initialize args={}
        if args["provider_id"].nil? || args["provider_id"].to_i == 0
            raise 'Csv Import Requires a :provider_id'
        end
    	@provider_id = args["provider_id"]
		@file        = args["file"]  	|| nil
		@proto_id    = args["proto_id"] || nil
		@status      = ""
		@number_good = 0
    end

    def persisted?
        false
    end

    def status_error
    	if errors.messages.count > 0
    		return errors.messages
    	else
    		return nil
    	end
    end

    def save
        convert_import_emails_to_socials
        if @number_good > 0
        	@status += "#{@number_good} emails were uploaded"
        	true
        else
        	false
        end
    end

private

    def convert_import_emails_to_socials
        network_ids_ary = []
        puts "\n\n Here is open spreadsheet #{open_spreadsheet.inspect}"
        ActiveRecord::Base.transaction do
            open_spreadsheet.each_with_index do |network_id, index|

            	if index < CSV_LIMIT
    	            if (email = validate_and_check_if_email(network_id[0])) && !network_ids_ary.include?(email)
    	                network_ids_ary  << email
                        puts "\n\n in convert_import_emails_to_socials #{Time.now}"
    	                social = Social.includes(:proto_joins).find_or_create_by(network: "email", network_id: email)

                        if social.errors.messages.count > 0
                            errors.add :email, "Row #{index+1}: #{social.network_id} is not a valid email"
                        else

                            Connection.create(provider_id: @provider_id, social_id: social.id)
    	                	if @proto_id
    	                		ProtoJoin.find_or_create_by(receivable_type: "Social", receivable_id: social.id, gift_id: nil, proto_id: @proto_id)
    	                	end
    	                	@number_good += 1
    	                end
    	            end
    	        else
    	        	@status += "Max Limit of #{CSV_LIMIT} has been reached. The first "
    	        	break
    	        end
            end
        end
    end

    def validate_and_check_if_email email
        if email.respond_to?(:downcase) && email.respond_to?(:strip)
            email.downcase.strip
        else
            false
        end
    end

    def open_spreadsheet
    	if Rails.env.test?
    		method_name = :path
    	else
    		method_name = :original_filename
    	end
        case File.extname(file.send(method_name))
        when ".csv"  then Roo::CSV.new(file.path)
        when ".xls"  then Roo::Excel.new(file.path, nil, :ignore)
        when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
        else errors.add(:base, "Unknown file type: #{file.send(method_name)}")
        end
    end

end