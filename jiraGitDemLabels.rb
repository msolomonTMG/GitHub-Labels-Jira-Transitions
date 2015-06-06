# Author: Mike Solomon
# This app uses some terrible programming practices to flip Jira statuses
# based on GitHub labels on corresponding pull requests
# 

require 'sinatra'
require 'json'
require 'rest-client'
require './config.rb'
require './process.rb'

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
		if push["repository"]["name"] == "JackThreads"
			jira_issues = get_jira_issues branch, "branch"
			#update_development_info_jira jira_issues, branch, "branch"
			start_progress jira_issues, branch, user
		end
	end
end

def handle_pull_request (push)
	puts push["repository"]["name"]
	#the action that was taken
	action = push["action"]
	#the user who made the action to the pull request
	user = get_user push["sender"]
	#the pull request that was actioned on
	pull_request = push["pull_request"]
	#jira issues associated with the pull request
	jira_issues = get_jira_issues pull_request, "pull_request"
	#is this a JITR issue
	if push["repository"]["name"] == "JackThreads"
		is_jitr = true
	else
		is_jitr = false
	end

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
end
