# require 'common_utils'
include CommonUtils

require 'dbcall'
require 'locate'
require 'legacy'
require 'legacy_user'
require 'legacy_gift'
require 'legacy_provider'
require 'cron'
require 'expiration'
require 'boomerang_cron'
require 'legacy_points'
include Legacy
include LegacyUser
include LegacyGift
include Cron
include Dbcall
include LegacyPoints
