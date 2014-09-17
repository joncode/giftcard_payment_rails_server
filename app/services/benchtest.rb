require 'benchmark'

class Benchtest

	def self.perform object_or_object_name, method_name, number=nil
		if object_or_object_name.class == String
			o = object_or_object_name.constantize.send(:last)
		else
			o = object_or_object_name
		end
		n = number.present? ? number : 100
		Benchmark.bm do |x|
			x.report { n.times { o.send(method_name) } }
		end	
	end

end
