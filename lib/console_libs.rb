# require 'common_utils'
include CommonUtils

require 'dbcall'
require 'qa_team'
require 'locate'
require 'legacy'
require 'legacy_user'
require 'cron'
require 'gift_console'
include Legacy
include LegacyUser
include Cron
include Dbcall
include GiftConsole

# require 'myActiveRecordExtensions'
# ActiveRecord::Base.send(:include, MyActiveRecordExtensions)