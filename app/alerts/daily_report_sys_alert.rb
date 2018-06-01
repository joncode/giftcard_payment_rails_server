class DailyReportSysAlert < Alert
	include KpiQueryHelper

#   -------------

	def text_msg
		super 'DAILY REPORT'
	end

	def email_msg
		super 'DAILY REPORT'
	end

	def msg
		text_msg
	end

#   -------------

	def get_data
		time_period = 24.hours.ago.beginning_of_day
        @header = TimeGem.dt_to_s(time_period)
		super between: (time_period ... (time_period-24.hours))
	end

end