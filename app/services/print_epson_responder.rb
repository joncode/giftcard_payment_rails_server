#TODO: %s/client_id/application_key/g

class PrintEpsonResponder
	require 'pp'

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
		printer = find_printer
		touched = false


		# If we cannot find the printer
		if printer.nil?
			# ... and we're not provided an application_key
			if client_id.nil?
				# Trigger a recall notice.
				@response = true
				return recall!(:misconfiguration, "Missing ServerDirectPrint ID; cannot find EpsonPrinter object by name (#{name}), IP (#{request.remote_ip})")
			end

			# But if we are given a key, create a new EpsonPrinter!

			# First, fetch the associated Client (for its ID)
			client = Client.where(application_key: client_id, active: true)

			if client.nil?
				# Oh no, the client doesn't exist either!

				# If it's just deactivated, someone (likely mistakenly) deactivated the Client on our end; we should look into it.
				# (We're not sending a response to the printer since its Client is, you know, deactivated.)
				return  if deactivated_client_check key: client_id, name: name, type: :poll  ##! This does an unnecessary Client lookup (same as the one above)

				# If not, the printer is misconfigured / just sending us garbage, or (very unlikely) someone destroyed the record.
				# Either way, the printer needs servicing, so trigger a recall notice.
				@response = true
				return recall!(:misconfiguration, "Missing ServerDirectPrint ID; cannot find Client by application_key (#{client_id}). Printer name: #{name}, ip: #{request.remote_ip}")
			end

			# Alright, create the new EpsonPrinter!
			printer = EpsonPrinter.new(client)
			printer.name = name
			touched = true
		end


		# Has the printer's IP changed?
		if printer.ip != request.remote_ip  ##!? Does this work here, since it's part of Rack::Request? (we're outside of a controller)
			# Auto-enable tracking if:
			#  * printer.ip differs from this ip  -- printer has moved  (99.99% chance this means it's installed in a venue)
			#  * printer.tracking is `nil`        -- printer tracking has never been enabled/disabled yet
			#  * printer.ip is already set        -- printer has already talked to us once  (during configuration)
			printer.tracking = true  if printer.tracking.nil? && printer.ip.present?

			printer.ip = request.remote_ip
			touched = true
		end

		# Do the more expensive operations during a brief window only so many times per day.
		now = DateTime.now
		if (now.seconds_since_midnight % EPSON_TRACKING_SECONDS_BETWEEN_POLL_CAPTURES) <= EPSON_TRACKING_POLL_CAPTURE_DURATION
			printer.last_poll_capture_at = now
			printer.name = name
			touched = true

			deactivated_client_check key: client_id, name: name, type: :poll
		end

		# Expensive, so save only when necessary.
		printer.save  if touched



		# And finally! Check the PrintQueue.
		key = (client_id.present? ? client_id : printer.application_key)  # Handle a nil `client_id`
		if print_queues = PrintQueue.print_request(key)
			@response = true
			@xml = PrintQueue.deliver(print_queues, key)
			puts "PrintEpsonResponder(44) " + @xml.inspect
		end
		@xml
	end

#	------------- 	SetResponse

	def run_process_print_receipt
		puts "[service PrintEpsonResponder :: perform(:SetResponse) -> run_process_print_receipt]  data:"
		pp data
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
		printer = find_printer

		# If we cannot find the printer
		if printer.nil?
			# ... and we're not provided an application_key, just return.  There's nothing more we can do here.  It's a dead end, Jim.
			return  if client_id.nil?

			# But if we are given a key, create a new EpsonPrinter!

			# First, fetch the associated Client (for its ID)
			client = Client.where(application_key: client_id, active: true)

			# Check if the client doesn't exist or if it's deactivated. In both casess, there's nothing more we can do.
			return  if client.nil?
			return  if deactivated_client_check key: client_id, name: name, type: :status  ##! This does an unnecessary Client lookup (same as the one above)

			# Alright, create the new EpsonPrinter!
			printer = EpsonPrinter.new(client)
		end



		# Has the printer's IP changed?
		if printer.ip != request.remote_ip  ##!? Does this work here, since it's part of Rack::Request? (we're outside of a controller)
			# Auto-enable tracking if:
			#  * printer.ip differs from this ip  -- printer has moved  (99.99% chance this means it's installed in a venue)
			#  * printer.tracking is `nil`        -- printer tracking has never been enabled/disabled yet
			#  * printer.ip is already set        -- printer has already talked to us once  (during configuration)
			printer.tracking = true  if printer.tracking.nil? && printer.ip.present?

			printer.ip = request.remote_ip
		end

		now = DateTime.now

		printer.name = name
		printer.last_status_at = now


		if printer.tracking
			# Only generate alerts/warnings for known, tracked printers
			deactivated_client_check key: client_id, name: name, type: :status

			# Pluck out the status bitflags
			# For (a total lack of) details about these status responses, see page 65 of
			# https://files.support.epson.com/pdf/pos/bulk/server_direct_print_um_en_revk.pdf
			status = @data["Status"]["statusmonitor"]["printerstatus"]["asbstatus"].to_i(16)  rescue nil
			puts "[PrintEpsonResponder :: run_set_printer_status]  Could not pluck out asbstatus flags from @data"  if status.nil?

			# -- Durations --
			# Store only the first report's timestamp; reset to `nil` when resolved.  `now - timestamp` gives the duration

			# timestamp = (timestamp.nil? ? now : nil)  if (status.set? XOR timestamp.present?)
			# This looks confusing, so let me explain:
			#     If either the status bitflag is set OR the timestamp is present (but not both), flip the timestamp.
			#     This stores the first timestamp, and resets to `nil` when the status is no longer present. Yay for XOR!

			# Toggle timestamp      between nil <-> set/now                   if (status bitflag set?          XOR  timestamp.present?)
			printer.cover_open_at = (printer.cover_open_at.nil? ? now : nil)  if ((status & 0x40    == 0x40)    ^ printer.cover_open_at.present?)  # cover open
			printer.paper_low_at  = (printer.paper_low_at.nil?  ? now : nil)  if ((status & 0x20000 == 0x20000) ^ printer.paper_low_at.present?)   # paper low
			printer.paper_out_at  = (printer.paper_out_at.nil?  ? now : nil)  if ((status & 0x80000 == 0x80000) ^ printer.paper_out_at.present?)   # paper out

			# -- Last instance --
			# Update the timestamp every time.
			printer.last_mechanical_error_at = now  if status & 0x400 == 0x400  # mechanical error
			printer.last_cutter_error_at     = now  if status & 0x800 == 0x800  # auto cutter error

			# I don't know what these mean, and I haven't been able to find documentation on them, either.
			# I can determine "offline" duration by `DateTime.now - last_status_at` (to within 4 minutes)
			# The other two just sound scary. They also aren't helpful, and will only cause David to freak out if he ever sees them.
			# So, for now, I'll just leave them here as comments:
			#     0x8    => offline (?)
			#     0x2000 => unrecoverable error (?)
			#     0x4000 => auto recovery error (?)  ## I think this is from the manually-initiated firmware update/recovery mode failing. Not something we need to worry about.


			##+ Add alerts here
		end

		# Save the status
		printer.save
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


#	-------------	Printer Tracking

	def find_printer
		# Find the printer by key, name, then IP  (as IP is likely to change over time)
		# This will be expensive if a) the EpsonPrinter doesn't exist, or b) it sends us a nil key and a different name.
		# In the event it sends us a nil key, a different name, and its IP has changed,
		# this will return nil, thereby changing the behavior of the poll/status handlers above.

		EpsonPrinter.where(active: true, application_key: client_id).first \
		|| EpsonPrinter.where(active: true, name: name).first              \
		|| EpsonPrinter.where(active: true, ip: request.remote_ip).first   \
		|| nil
	end


	def deactivated_client_check key:, name:, type:
		# Check if an application_key is only associated to deactivated Clients.  If so, log it and return true.

		# If there's no active client associated with the key
		if Client.where(application_key: key, active: true).first.nil?
			# but there's a deactivated client
			if Client.where(application_key: key, active: false).first.present?
				# log it for manual inspection
				puts "[PrintEpsonResponder :: deactivated_client_check]  Oh no! There's a deactivated printer talking to us.  key:#{key}  name:#{name}  request type: #{type}"
				return true
			end
		end
		false
	end

#	-------------	Printer Recall

	def recall!(type, details=nil)
		# Fetch or create a <PrinterRecall> object
		printer_recall = PrinterRecall.where(printer_name: name).last
		if printer_recall.nil?
			printer_recall = PrinterRecall.new
			printer_recall.client_id    = client_id  #TODO: write a migration to rename this to application_key
			printer_recall.printer_name = name
			printer_recall.type_of      = type
			printer_recall.details      = details

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