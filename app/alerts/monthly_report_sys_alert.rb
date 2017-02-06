class MonthlyReportSysAlert < Alert
    include KpiQueryHelper

#   -------------

    def text_msg
        super 'MONTHLY REPORT'
    end

    def email_msg
        super 'MONTHLY REPORT'
    end

    def msg
        text_msg
    end

#   -------------

    def get_data
        time_period_end = DateTime.now.utc.beginning_of_month
        time_period_begin = time_period_end - 1.month
        @month_name ||= TimeGem.month_name(time_period_begin)
        @year ||= time_period_begin.year
        @header = "#{@month_name} #{@year}"
        super between: [time_period_begin ... time_period_end]
    end


end