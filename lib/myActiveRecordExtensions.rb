
module MyActiveRecordExtensions

	# def self.included(base)
	# 	base.scope :previous,  lambda { |i| {:conditions => ["#{i.class.table_name}.id < ?", i], :order => "#{i.class.table_name}.id DESC", :limit => 1 }}
	# 	base.scope :next,      lambda { |i| {:conditions => ["#{i.class.table_name}.id > ?", i], :order => "#{i.class.table_name}.id ASC",  :limit => 1 }}
	# end

 #  	def next
	# 	record = self.class.where("id > ?", id).limit(1).shift
	# 	record = self.class.first if record.nil?
	# 	return record
	# end

	# def previous
	# 	record = self.class.previous(self).shift
	# 	record = self.class.last if record.nil?
	# 	return record
	# end

end
