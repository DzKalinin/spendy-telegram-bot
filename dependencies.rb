require 'rest-client'
require 'telegram/bot'
require 'yaml'

Dir["#{Dir.pwd}/lib/*.rb"].each { |f| require f }
