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

set :port, 80
set :bind, '0.0.0.0'

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
		if push["repository"]["name"] == "JackThreads"
			jira_issues = get_jira_issues branch, "branch", true
			#update_development_info_jira jira_issues, branch, "branch"
			start_progress jira_issues, user, branch
			#log this event
			log_event push["sender"], "branch created", push, "branch", Time.now
		end
	end
end

post '/jira_webhook' do
	#the JSON that the JIRA webhook sends us
	push 		= JSON.parse(request.body.read)
    epic 		= push["issue"]["fields"]["customfield_10220"]
    transition 	= push["transition"]["transitionId"]
    user 		= "[~#{push['user']['key']}]"

    jira_issues = Array.new
    jira_issues.push(epic)

    if transition.to_s == START_PROGRESS_ID
    	start_progress jira_issues, user
    elsif transition.to_s == QA_READY_ID
    	start_qa_for_epic epic, user
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
	if push["repository"]["name"] == "JackThreads"
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
		if (is_jitr === true)
			#move ticket(s) to in QA testing and comment on the ticket(s)
			start_qa jira_issues, pull_request, user, is_jitr
		else
			start_code_review jira_issues, pull_request, user
		end
	end

	#log this event
	log_event push["sender"], "pull request #{action}", push, "pull_request", Time.now
end
