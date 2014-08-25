ActiveRecord::Base.class_eval do

  	define_method(:next) do
		record = self.class.order(created_at: :asc).where("id > ?", id).limit(1).first
		record = self.class.first if record.nil?
		return record
	end

	define_method(:prev) do
		record = self.class.order(created_at: :desc).where("id < ?", id).limit(1).first
		record = self.class.last if record.nil?
		return record
	end

end