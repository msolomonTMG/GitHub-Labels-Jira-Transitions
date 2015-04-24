# Author: Mike Solomon
# This app uses some terrible programming practices to flip Jira statuses
# based on GitHub labels on corresponding pull requests
# 

require 'sinatra'
require 'json'
require 'rest-client'
require './config.rb'
require './process.rb'

set :server, 'webrick'

post '/payload' do
	#the JSON that GitHub webhook sends us
	push = JSON.parse(request.body.read)
	
	#the action that was taken
	action = push["action"]
	#the user who made the action to the pull request
	user = get_user push["sender"]
	#the pull request that was actioned on
	pull_request = push["pull_request"]
	#jira issues associated with the pull request
	jira_issues = get_jira_issues pull_request

	if action == "labeled"
		#array of labels applied to this pull request
		pull_request_labels = get_labels pull_request
		#the label that was just added to this pull request
		current_label = push["label"]["name"]
		#loop through all of the tickets and decide what to do based on the labels of this pull request
		update_label_jira jira_issues, current_label, pull_request_labels, user
	
	elsif action == "synchronize"
		#get latest commit message on pull request
		latest_commit_message = get_latest_commit_message pull_request, push["repository"]["commits_url"]
		#update jira ticket by moving to QA and commenting with the latest commit message
		update_message_jira jira_issues, pull_request, latest_commit_message, user

	elsif action == "opened"
		#move ticket(s) to in QA testing and comment on the ticket(s)
		start_qa jira_issues, pull_request, user
	end
		
		
end
