class WeeklyReportSysAlert < Alert
	include KpiQueryHelper

#   -------------

	def text_msg
		super 'WEEKLY REPORT'
	end

	def email_msg
		super 'WEEKLY REPORT'
	end

	def msg
		text_msg
	end

#   -------------

	def get_data
		time_period = 1.week.ago
		week_day = TimeGem.dt_to_s(time_period)
		@header = "Week of #{week_day}"
		super since: time_period
	end

end