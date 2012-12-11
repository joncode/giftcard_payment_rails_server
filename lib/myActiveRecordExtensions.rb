
module MyActiveRecordExtensions


	def self.included(base)
		base.scope :previous,  lambda { |i| {:conditions => ["#{i.class.table_name}.id < ?", i], :order => "#{i.class.table_name}.id DESC", :limit => 1 }}
		base.scope :next,      lambda { |i| {:conditions => ["#{i.class.table_name}.id > ?", i], :order => "#{i.class.table_name}.id ASC",  :limit => 1 }}
	end

  	def next
  		puts "in next method"
		self.class.where("id > ?", id).limit(1).shift
	end

	def previous
  		puts "in previous method"
		self.class.where("id < ?", id).limit(1).shift
	end
end
