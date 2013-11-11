module DataHelper

    def compare_keys(json_hsh, expected_keys)
        if json_hsh.keys.count > expected_keys.count
            over_keys = json_hsh.keys - expected_keys
            puts "Too many keys !!! #{over_keys}"
        elsif json_hsh.keys.count < expected_keys.count
            over_keys = expected_keys - json_hsh.keys
            puts "Missing these keys !!! #{over_keys}"
        end
        json_hsh.keys.count.should == expected_keys.count
        expected_keys.each do |key|
            json_hsh.has_key?(key).should be_true
        end
    end

end


RSpec.configuration.include(DataHelper)