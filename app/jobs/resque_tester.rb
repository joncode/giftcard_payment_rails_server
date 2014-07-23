class ResqueTester

    @queue = :test_mt

    def self.perform data , number=10
        puts "^^^^^^^^^^^ START RESQUE TESTER^^^^^^^^^^^^^^^^^^"
        number = number.to_i
        	puts "===== THIS IS TEST NUMBER #{number} ====="
        puts "^^^^^^^^^^^ END RESQUE TESTER^^^^^^^^^^^^^^^^^^"
    end

end