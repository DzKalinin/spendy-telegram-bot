ENV["RACK_ENV"] ||= 'development'
require './dependencies'

Time.zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
Time.zone_default = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
