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
			# Catch missing / incorrect `client_id`s, as these will not resolve on their own.
			#  * missing   -> misconfigured printer
			#  * incorrect -> someone deleted/deactivated the printer's <Client> object

		if client_id.blank? 	# || ClientUrlMatcher.get_app_key(client_id).nil?
			return recall(:misconfiguration)
		end

		if print_queues = PrintQueue.print_request(client_id)
			@response = true
			@xml = PrintQueue.deliver(print_queues, client_id)
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
		return if client_id.blank?
		@success = false
		unless printjob.blank?
			begin
				@success = make_boolean(printjob["PrintResponse"]["response"]["success"])
				@job = printjob["Parameter"]["printjobid"]
			rescue
				# do nothing just pass thru to job marking
			end
		end
		if @success
			puts "\n\nPrintEpsonResponder (47) " + self.inspect
			PrintQueue.mark_job_as_printed(client_id, job)
		else
			@error = 'Espon Connection Formatting Error'
			if printjob && printjob["PrintResponse"] && printjob["PrintResponse"]["response"]
				@error = printjob["PrintResponse"]["response"]
			end
			puts "\n\nPrintEpsonResponder (63) 500 Internal - EPSON PRINT ERROR #{printjob.inspect} #{@error.inspect}"

			if PrintQueue.error_reprint?(@error)
				# re-queue the print jobs
				PrintQueue.requeue_job(client_id, job, @error)
			else
				# cancel the print job
				PrintQueue.mark_job_as_error(client_id, job, @error)
			end
		end
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

#	-------------	Printer Recall

	def recall(type)
		# Fetch or create a <PrinterRecall> object
		printer_recall = PrinterRecall.where(printer_name: name).last
		if printer_recall.nil?
			printer_recall = PrinterRecall.new
			printer_recall.client_id    = client_id
			printer_recall.printer_name = name
			printer_recall.type_of      = type

			unless printer_recall.save
				puts "[service PrintEpsonResponder :: recall] save failure handler '#{client_id.inspect}' , name: '#{name}'"
			end
		end

		# Make sure we only send the notice every so often.
		if printer_recall.should_notify?
			# Log the event
			puts "[service PrintEpsonResponder :: run_check_print_queue -> recall]  caught invalid client_id: '#{client_id.inspect}' , name: '#{name}'.  Sending recall notice."
			#TODO: Send a Recall Alert


			# Tell <PrinterRecall> we're notifying the merchant.
			# and return the recall notice
			@response = true
			@xml = printer_recall.to_epson_xml
			printer_recall.notifying!
		end

		@xml
	end


end