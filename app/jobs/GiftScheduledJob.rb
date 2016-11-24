class GiftScheduledJob

	def self.perform
        puts "------------- GiftScheduledJob CRON -----------------"
        sent_gifts = 0
        Gift.where(status: "schedule").where('scheduled_at < ?', DateTime.now.utc).find_each do |gift|

            begin
                if gift.deliver_now
    	            puts "-------------  Scheduled gift ID = #{gift.id}  -------------"
    	            sent_gifts += 1
    	        else
    	        	puts "500 Internal - Scheduled gift failed #{gift.id} #{gift.errors.messages}"
    	        end
            rescue => e
                puts "500 Internal - Scheduled gift failed #{gift.id} #{e.inspect}"
            end

        end
        puts "------------- #{sent_gifts} Scheduled gifts sent -----------------"
    end

end




# t = DateTime.now.beginning_of_day

# p = Proto.f 5073

# a = [ 5076 , 5073 , 5075, 5094, 5079, 5093, 5078, 5102, 5091, 5074, 5092, 5077, 5068 ]
# ps = Proto.where(id: a)
# ps.each do |p|
# gs = G.w payable_id: p.id, payable_type: p.class.to_s
# gs.each do |g|
# if g.status == 'schedule'
# g.update_column(:scheduled_at , t)
# end
# end
# end
# GiftScheduledJob.perform



# a = [ 5076 , 5073 , 5075, 5094, 5079, 5093, 5078, 5102, 5091, 5074, 5092, 5077, 5068 ]
# ps = Proto.where(id: a)
# ps.each do |p|
# gs = G.w payable_id: p.id, payable_type: p.class.to_s
# gs.each do |g|
# if g.status == 'schedule'
# g.update_column(:expires_at , t)
# end
# end
# end

# ps = Proto.where(id: a)
# ps.each do |p|
# p.update_column :expires_at, t
# end

# p.update_column :expires_in, nil
# p.update_column(:start_in, 0) if (p.start_in.to_i != 0)