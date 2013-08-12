require 'yaml'
require 'common_utils'
require 'dbcall'
# require 'qa_team'

# require 'myActiveRecordExtensions'
# ActiveRecord::Base.send(:include, MyActiveRecordExtensions)

yaml_data = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'application.yml'))).result)
APP_CONFIG = ENV["RAILS_ENV"] == "development" ? HashWithIndifferentAccess.new(yaml_data)[:development] : HashWithIndifferentAccess.new(yaml_data)[:production]


class Array

    def serialize_objs api=nil
        serialize_type = api ? "#{api}_serialize" : "serialize"
        map { |o| o.send serialize_type }
    end

end

