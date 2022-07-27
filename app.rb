ENV["RACK_ENV"] ||= 'development'
require './dependencies'

Time.zone = ActiveSupport::TimeZone['UTC']
Time.zone_default = ActiveSupport::TimeZone['UTC']
