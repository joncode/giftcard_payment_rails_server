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

	define_method(:zz) do
		self.serialize
	end
end


module ActiveRecordExtension

	extend ActiveSupport::Concern

	# add your instance methods here
	# def foo
	#    "foo"
	# end

  	# add your static(class) methods here
  	module ClassMethods

  		def l
  			last
  		end

  		def fi
  			first
  		end

  		def uf obj_id
			unscoped.find obj_id
  		end

	    def f obj_id
	      	find obj_id
	    end

	    def wi args
	    	resp = where("#{args.keys.first} ilike '%#{args.values.first}%'")
	    	if resp.length == 1
	    		resp.first
	    	else
	    		resp
			end
	    end

	    def w args
	    	resp = where(args)
	    	if resp.length == 1
	    		resp.first
	    	else
	    		resp
			end
	    end
  	end
end

ActiveRecord::Base.send(:include, ActiveRecordExtension)
