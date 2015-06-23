require_relative 'vars'
require 'mandrill'

MANDRILL_CLIENT = Mandrill::API.new(MANDRILL_APIKEY)
