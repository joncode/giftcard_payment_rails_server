class PrintEpsonResponder

	attr_reader :client_id, :connection_type, :name, :data, :xml, :response, :job, :success, :error

	CONNECTION_TYPES = ["GetRequest", "SetResponse", "SetStatus"]

	def initialize args
		@data = clean_hash(args.dup)
		puts @data.inspect
		@client_id = @data.delete("ID")
		@connection_type =  @data.delete("ConnectionType")
		@name =  @data.delete("Name")
		@response = false
		@xml = ''
	end

#	-------------

	def perform
		case connection_type
		when "GetRequest"
			run_check_print_queue
		when "SetResponse"
			run_process_print_receipt
		when "SetStatus"
			run_set_printer_status
		else # new connection-type
				# Alert devs
			puts "500 Internal NEW EPSON CONNECTION TYPE #{connection_type}"
		end
		puts self.inspect
	end

#	------------- 	GetRequest

	def run_check_print_queue
		if print_queues = PrintQueue.print_request(client_id)
			@response = true
			@xml = PrintQueue.deliver(print_queues)
			puts "PrintEpsonResponder(44) " + @xml.inspect
		end
		@xml
	end

#	------------- 	SetResponse

	def run_process_print_receipt
		header = data["ResponseFile"]["PrintResponseInfo"]["ePOSPrint"]
		header = [header] unless header.kind_of?(Array)
		header.each do |printjob|
			parse_print_receipts(printjob)
		end
	end

	def parse_print_receipts printjob
		@success = make_boolean(printjob["PrintResponse"]["response"]["success"])
		@job = printjob["Parameter"]["printjobid"]
		if @success
			puts "PrintEpsonResponder (47) " + self.inspect
			PrintQueue.mark_job_as_printed(client_id, job)
		else
			@error = printjob["PrintResponse"]["response"]
			puts "500 Internal - EPSON PRINT ERROR #{data.inspect}"
			PrintQueue.mark_job_as_error(client_id, job, @error)
		end
	rescue
		puts "500 Internal - EPSON XML SCHEMA ERROR #{data.inspect}"
	end

#	------------- 	SetStatus

	def run_set_printer_status
		# no plan for this yet
	end

#	-------------	Utilities

	def make_boolean thing
		ActiveRecord::Type::Boolean.new.type_cast_from_user(thing)
	end

	def convert_xml xml_str
		Hash.from_xml(xml_str)
	rescue
		xml_str
	end

	def clean_hash hash
		hash.update(hash) do |k,v|
			if ["ConnectionType", "ID", "Name"].include?(k)
				v
			else
				convert_xml(v)
			end
		end
	end

end