# require 'common_utils'
include CommonUtils

require 'dbcall'
require 'qa_team'
require 'locate'
require 'legacy'
require 'cron'
include Legacy
include Cron
include Dbcall

# require 'myActiveRecordExtensions'
# ActiveRecord::Base.send(:include, MyActiveRecordExtensions)