module HexIdMethods
    extend ActiveSupport::Concern

    included do |klass|
		klass.extend         HexIdMethods::ClassMethods
	    klass.send :include, HexIdMethods::InstanceMethods
			#   -------------   HEX ID model callback
        before_save :set_unique_hex_id
    end

#   -------------

    module InstanceMethods

	    def set_unique_hex_id
	    	if self.hex_id.blank?
		        self.hex_id = UniqueIdMaker.eight_digit_hex(self.class, :hex_id, self.class.const_get(:HEX_ID_PREFIX))
		    end
	    end


	#   -------------  Instance :paper_id


	    def paper_id
	        @paper_id ||= self.class.hex_to_paper(self.hex_id)
	    end

	end

#   -------------  HEX ID / PAPER ID / DB ID Model.find

	module ClassMethods

		def where_with _id
			if _id.to_s == _id.to_i.to_s
				where(id: _id)
			else
				_id = paper_to_hex(_id)
				where(hex_id: _id)
			end
		end

	    def find_with _id
				# integer check for integers or integers as strings
			if _id.to_s == _id.to_i.to_s
				find(_id)
			else
				_id = paper_to_hex(_id)
				r = find_by(hex_id: _id)
				raise ActiveRecord::RecordNotFound if r.nil?
				r
			end
		end


	#   -------------    Class Utilities


	    def paper_to_hex paper_id
	    	return paper_id unless paper_id.try(:match,'-')
	        hex_id = paper_id[0..6].to_s + paper_id[8..11].to_s
	        hex_id.gsub('-','_').downcase
	    end

	    def hex_to_paper hex_id
	    	return hex_id unless hex_id.try(:match,'_')
	        hx = hex_id.to_s.gsub('_', '-').upcase
	        hx[0..6].to_s + '-' + hx[7..10].to_s
	    end

	end

end