module ActionController
	class Parameters < ActiveSupport::HashWithIndifferentAccess

	private

	def unpermitted_parameters!(params)  
        return unless self.class.action_on_unpermitted_parameters
        
        unpermitted_keys = unpermitted_keys(params)

        if unpermitted_keys.any?  
          case self.class.action_on_unpermitted_parameters  
          when :log
            name = "unpermitted_parameters.action_controller"
            ActiveSupport::Notifications.instrument(name, :keys => unpermitted_keys)
          when :raise  
          	raise JSON::ParserError
          end  
        end  
      end  
	end

end