require 'rest-client'
require 'telegram/bot'
require 'yaml'
require 'active_support'
require 'active_support/all'

Dir["#{Dir.pwd}/lib/*.rb"].each { |f| require f }
