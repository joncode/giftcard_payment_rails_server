module HexIdMethods
    extend ActiveSupport::Concern

    included do |klass|
		klass.extend         HexIdMethods::ClassMethods
	    klass.send :include, HexIdMethods::InstanceMethods
			#   -------------   HEX ID model callback
        before_save :set_unique_hex_id, on: :create
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

	    def find_with _id
				# integer check for integers or integers as strings
			if _id.match('-')
				_id = paper_to_hex(_id)
			end
			if _id.to_s == _id.to_i.to_s
				find(_id)
			else
				r = find_by(hex_id: _id)
				raise ActiveRecord::RecordNotFound if r.nil?
				r
			end
		end


	#   -------------    Class Utilities


	    def paper_to_hex paper_id
	        hex_id = paper_id[0..6].to_s + paper_id[8..11].to_s
	        hex_id.gsub('-','_').downcase
	    end

	    def hex_to_paper hex_id
	        return '' if hex_id.nil?
	        hx = hex_id.to_s.gsub('_', '-').upcase
	        hx[0..6].to_s + '-' + hx[7..10].to_s
	    end

	end

end