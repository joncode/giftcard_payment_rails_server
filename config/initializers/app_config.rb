require 'yaml'
require 'common_utils'
require 'emailer'

yaml_data = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'application.yml'))).result)
APP_CONFIG = ENV["RAILS_ENV"] == "development" ? HashWithIndifferentAccess.new(yaml_data)[:development] : HashWithIndifferentAccess.new(yaml_data)[:production]


class Array

    def serialize_objs api=nil
        serialize_type = api ? "#{api}_serialize" : "serialize"
        map { |o| o.send serialize_type }
    end

end

def lcon
    load ($:[0] + "/console_libs.rb")
    puts "loading rails console scripts [lcon]"
end

ActiveRecord::Base.logger = Logger.new(STDOUT)
