# Author: Mike Solomon
# This app makes it easy to deploy branches to staging servers from GitHub
# Leveraging capistrano scripts authored by Ken Peltzer

require 'sinatra'
require 'json'
require 'rest-client'
require './config.rb'

post '/deploy' do
	# We want to be sent a bunch of JSON and then run the cap deploy
	# We will need
	# => The branch name
	# => The staging server to deploy to
	# => The property/company of the branch

	deployDirectory = "deploy/jackthreads"

	Dir.chdir('deployDirectory'){
	  %x[#{cmd}]
	}
end