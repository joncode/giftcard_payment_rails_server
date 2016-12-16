class OpsGolfnowRevenue

	attr_reader :start_date, :end_date, :data, :gifts

	def initialize args={}
		@data = {}
		@start_date = args[:start_date]
		@end_date = args[:end_date]

		if @start_date.blank?
			@start_date = (DateTime.now.utc - 1.day).to_date.to_s
		end
		if @end_date.blank?
			@end_date = DateTime.now.utc.to_date.to_s
		end

		@start_scope = TimeGem.string_to_datetime(@start_date).beginning_of_day
		@end_scope = TimeGem.string_to_datetime(@end_date).beginning_of_day
	end

	def res
		@data.values
	end

	def perform
		get_gifts
		make_data
		"Completed! Data available at .data or .res"
	end

	def make_data
        @data = {}
        @gifts.each do |gift|
        	merchant = gift.merchant
            fid = merchant && merchant.building_id
            client = gift.client
            if client.nil? && fid.nil?
            	url_name = 'no_client'
            	uniq_key = "NA"
            elsif client.nil? && !fid.nil?
            	url_name = 'no_client'
            	uniq_key = "NA-#{fid}"
            else
            	url_name = client.url_name
            	uniq_key = client.id
            end
            if @data[uniq_key].nil?
            	@data[uniq_key] = make_hsh(url_name, fid)
            end
            h = @data[uniq_key]
            h[:GrossRevenue] += gift.value_cents
            h[:NetRevenueToGolfNow] += gift.override_fee
            h[:NetRevenueToCourse] += gift.cost_cents
            h[:TransactionCount] += 1
            h[:GiftCount] += 1
        end
        @data
	end


#   -------------


	def get_gifts
		@gifts ||= Gift.get_purchases_for_affiliate(GOLFNOW_ID, @start_scope, @end_scope)
	end

	def make_hsh url_name=nil, fid=nil
		{ 	start_date: @start_date, end_date: @end_date,
			url: url_name, golfnow_facility_id: fid,
			GrossRevenue: 0,
			NetRevenueToGolfNow: 0,
			NetRevenueToCourse: 0,
			TransactionCount: 0,
			GiftCount: 0,
		}
	end


end

=begin
sd = TimeGem.string_to_datetime('2016-12-11').beginning_of_day
ed = TimeGem.string_to_datetime('2016-12-14').beginning_of_day

o = OpsGolfnowRevenue.new(start_date: '2016-12-11', end_date: '2016-12-14')
=end

# start_date
# end_date
# url
# golfnow_facility_id
# GrossRevenue
# NetRevenueToGolfNow
# NetRevenueToCourse
# TransactionCount
# GiftCount

# TotalGrossRevenue – defined as sum of total gross revenue across all transactions for a Golf Course
# NetRevenueToCourse – defined as sum of total net revenue paid to Golf Course
# NetRevenueToGolfNow – defined as sum of total net revenue paid to GolfNow
# TransactionCount – defined as sum of all transactions for a Golf Course
# GiftCount – defined as sum of total gifts purchased across all transactions for a Golf Course