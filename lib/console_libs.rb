# require 'common_utils'
include CommonUtils

require 'dbcall'
require 'qa_team'
require 'locate'
require 'legacy'
require 'legacy_user'
require 'cron'
include Legacy
include LegacyUser
include Cron
include Dbcall

# require 'myActiveRecordExtensions'
# ActiveRecord::Base.send(:include, MyActiveRecordExtensions)