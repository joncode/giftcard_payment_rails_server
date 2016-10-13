require 'yaml'
require 'common_utils'
require 'emailer'
require 'active_record_extensions'
# require 'gift_utility'
# require 'production_db_update'
# include ProductionDbUpdate

yaml_data = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'application.yml'))).result)
APP_CONFIG = ENV["RAILS_ENV"] == "development" ? HashWithIndifferentAccess.new(yaml_data)[:development] : HashWithIndifferentAccess.new(yaml_data)[:production]


def thread_on?

    if Rails.env.development?
        false
    else
        true
    end

end

class Object

    def mets
        (self.methods - Object.methods).sort_by { |m| m }
    end

end



class ActiveSupport::TimeWithZone

    def xmlschema(fraction_digits = 0)

        "#{time.strftime("%Y-%m-%dT%H:%M:%S")}#{formatted_offset(true, 'Z')}"
    end

end

def smss
    require 'sms_collector'
    SmsCollector::sms_promo_run
end

def lcon
    load ($:[0] + "/console_libs.rb")
    puts "loading rails console scripts [lcon]"
end

class Array

    def serialize_objs api=nil
        serialize_type = api ? "#{api}_serialize" : "serialize"
        map { |o| o.send serialize_type }
    end

end


if Rails.env.test?
    ActiveRecord::Base.logger = nil #Logger.new(STDOUT)

    require 'auth_response'
    require 'auth_transaction'
end

def log_bars text
    puts "===================================================="
    puts "========== #{text} ==========="
    puts "===================================================="
end





