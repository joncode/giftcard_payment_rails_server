class ApplicationController < ActionController::Base

	protect_from_forgery
	helper :all
	include CommonUtils
	include SessionsHelper

	# before_filter :prepare_for_mobile
	before_filter :method_start_log_message
	after_filter  :method_end_log_message
	helper_method :mobile_device?

	def required_params(param_arr)
		param_arr.each do |p|
			next if params[p]
			return false
		end
		return true
	end

	def populate_locals
		id = params[:id].to_i
		@provider       = Provider.find(id) if id > 0
		@current_user   = current_user
	end

	def sanitize_filename(file_name)
		just_filename = File.basename(file_name)
		just_filename.sub(/[^\w\.\-]/,'_')
	end


	def create_menu_from_items(provider)
		menu_bulk  = Menu.where(provider_id: provider.id)
		menu_bulk.map do |item|
			 indi  = Item.find(item.item_id)
			 [indi, item.price]
		end
	end

	def human_readable_error_message obj
		messages = obj.errors.messages
		message_ary = ["Error! Data not saved"]
		messages.each_key do |k|
			if k != :password_digest
				values = messages[k]
				values.each do |v|
					human_str = "#{k.to_s} "
					human_str += v
					message_ary << human_str
				end
			end
		end
		return message_ary
	end

private

	def mobile_device?
		if session[:mobile]
			session[:mobile] == "1"
		else
			if request.user_agent =~ /Mobile|webOS/
				request.user_agent =~ /iPad|tablet|GT-P1000/ ? false : true
				false
				 # ^^ remove this is you want this to work
			else
				false
			end
		end
	end

	def sniff_browser
		if request.user_agent =~ /Mobile|webOS/
			request.user_agent =~ /iPad|tablet|GT-P1000/ ? false : true
		else
			false
		end
	end

	def prepare_for_mobile
		session[:mobile] = params[:mobile] if params[:mobile]
		#  request.format   = :mobile if mobile_device?
	end


end
