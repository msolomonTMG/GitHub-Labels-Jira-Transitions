# Author: Mike Solomon
# This app flips Jira statuses based on applying labels to Github pull requests
# 

require 'sinatra'
require 'json'
require 'rest-client'
require 'data_mapper'
require './config.rb'
require './process.rb'

set :server, 'webrick'

#set :port, 80
#set :bind, '0.0.0.0'

#require models
Dir[File.dirname(__FILE__) + '/model/*.rb'].each {|file| require file }

#require controllers
Dir[File.dirname(__FILE__) + '/controller/*.rb'].each {|file| require file }

#load up the database
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/my.db")
DataMapper.auto_upgrade!

post '/payload' do
	#the type of event that happened in GitHub
	event = request.env["HTTP_X_GITHUB_EVENT"]
	#the JSON that GitHub webhook sends us
	push = JSON.parse(request.body.read)
	#if the event was a pull request, handle that differently than actions for branches
	if event == "pull_request"
		handle_pull_request push
	elsif event == "create" && push["ref_type"] == "branch"
		#the branch that was created
		branch = push["ref"]
		#the user who made the action to the pull request
		user = get_user push["sender"]
		#if this is a JITR ticket, update the JIRA issue with the branch name
		if push["repository"]["name"] == "jvaca"
			jira_issues = get_jira_issues branch, "branch", true
			#update_development_info_jira jira_issues, branch, "branch"
			start_progress jira_issues, branch, user
			#log this event
			log_event push["sender"], "branch created", push, "branch", Time.now
		end
	end
end

def handle_pull_request (push)
	#the action that was taken
	action = push["action"]
	#the user who made the action to the pull request
	user = get_user push["sender"]
	#the pull request that was actioned on
	pull_request = push["pull_request"]
	#is this a JITR issue
	if push["repository"]["name"] == "jvaca"
		is_jitr = true
	else
		is_jitr = false
	end
	#jira issues associated with the pull request
	jira_issues = get_jira_issues pull_request, "pull_request", is_jitr

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
		update_message_jira jira_issues, pull_request, latest_commit_message, user, is_jitr

	elsif action == "opened"
		#move ticket(s) to in QA testing and comment on the ticket(s)
		start_qa jira_issues, pull_request, user, is_jitr
	end
	
	#log this event
	log_event push["sender"], "pull reqeuest #{action}", push, "pull_request", Time.now
end
