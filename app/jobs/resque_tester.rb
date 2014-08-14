require 'resque/plugins/resque_heroku_autoscaler'

class ResqueTester
    #extend Resque::Plugins::HerokuAutoscaler

    @queue = :test

    def self.perform data , number=10
        puts "^^^^^^^^^^^ START RESQUE TESTER^^^^^^^^^^^^^^^^^^"
        number = number.to_i
        	puts "===== THIS IS TEST NUMBER #{number} ====="
        	puts "\n\n Here is the data \n #{data.inspect}\n"
        puts "^^^^^^^^^^^ END RESQUE TESTER^^^^^^^^^^^^^^^^^^"
    end

end