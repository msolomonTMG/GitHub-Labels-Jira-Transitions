# Author: Mike Solomon
# This app uses some terrible programming practices to flip Jira statuses
# based on GitHub labels on corresponding pull requests
#

require 'sinatra'
require 'json'
require 'rest-client'
require './config.rb'

post '/payload' do
	push = JSON.parse(request.body.read)						#the JSON that GitHub API sends us
	action = push["action"]										#the action that was taken
	actionUser = push["sender"]["login"]						#user who did the action
	pullTitle = push["pull_request"]["title"]					#the title of the pull request
	
	if action == "labeled"
		currentLabel = push["label"]["name"]					#the name of the label that was just applied
		jiraKey = pullTitle.match(/(?:|^)((FETWO|fetwo|TE|te|SCTWO|sctwo)(\s|-)[0-9]+)(?=\s|$)/)#the issueKey for Jira dervived from a regex
		issueURL = push["pull_request"]["issue_url"]			#the URL of a pull request's corresponding issue3
		issueURLauth = issueURL.insert(8,GIT_HUB_TOKEN+':@') 	#authenticate dat ish
		issueInfo = JSON.parse(RestClient.get(issueURLauth))	#all of the info on the issue/pull request
		issueLabels = issueURLauth+'/labels'					#URL of the labels
		allLabels = JSON.parse(RestClient.get(issueLabels))		#all of the label info for the issue/pull request
		milestone = issueInfo["milestone"]						#milestone that the issue/pull request lives in

		#smartKeys = pullTitle.scan(/(?:\s|^)([A-Z]+-[0-9]+)(?=\s|$)/)
		#Transition Jira tickets based on GitHub labels

		#if someone labels this with QA'ed, we need to transition the ticket based on whether it has been Reviewed or not
		if currentLabel == "QAed" && jiraKey != nil
			if allLabels.find {|x| x['name'] == 'reviewed'} != nil
				#this issue has been qa'ed and reviewed. we should move it to deploy ready
				puts "\n #{actionUser} labeled pull request: #{pullTitle} with #{currentLabel}." 
				puts "Will try to move #{jiraKey} to Deploy Ready if it was named correctly.\n"
				#QA'ed command: 
				system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{\"add\": {\"body\": \"QA passed\"}}]}, \"transition\": {\"id\": \"91\"}}' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/#{jiraKey}/transitions"
				#Deploy Ready command
				system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{\"add\": {\"body\": \"Ready to deploy\"}}]}, \"transition\": {\"id\": \"111\"}}\' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/#{jiraKey}/transitions"
			else
				#this issue has not been reviewed yet so we should just say its been QA'ed
				puts "\n#{actionUser} labeled pull request: #{pullTitle} with #{currentLabel}." 
				puts "Will try to move #{jiraKey} to QA Approved if it was named correctly.\n"
				#QA'ed command: 
				system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{\"add\": {\"body\": \"QA passed\"}}]}, \"transition\": {\"id\": \"91\"}}' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/#{jiraKey}/transitions"
			end
		#if someone labels this with Reviewed, we need to transition the ticket based on whether it has been QAed or not
		elsif currentLabel == "reviewed" && jiraKey != nil
			if allLabels.find {|x| x['name'] == 'QAed'} != nil
				#this issue has been reviewed and qa'ed. we should move it to deploy ready
				puts "\n#{actionUser} labeled pull request: #{pullTitle} with #{currentLabel}." 
				puts "Will try to move #{jiraKey} to Deploy Ready if it was named correctly.\n"
				#Reviewed command: 
				system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{\"add\": {\"body\": \"Code review passed\"}}]}, \"transition\": {\"id\": \"101\"}}' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/#{jiraKey}/transitions"
			
				#Deploy Ready command: 
				system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{\"add\": {\"body\": \"Ready to deploy\"}}]}, \"transition\": {\"id\": \"111\"}}' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/#{jiraKey}/transitions"
			else
				#this issue has not been qa'ed yet so we should just say that its been reviewed
				puts "\n#{actionUser} labeled pull request: #{pullTitle} with #{currentLabel}." 
				puts "Will try to move #{jiraKey} to Code Reviewed if it was named correctly.\n"
				
				#Reviewed command: 
				system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{ \"add\": {\"body\": \"Code review passed\"} }]}, \"transition\": {\"id\": \"101\"}}' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/#{jiraKey}/transitions"
			end
		elsif currentLabel == "QAed" && jiraKey == nil
			if allLabels.find {|x| x['name'] == 'reviewed'} != nil
				#this issue has been qa'ed and reviewed. we should move it to deploy ready
				puts "\n#{actionUser} labeled pull request: #{pullTitle} with #{currentLabel}." 
				puts "But I can't move it to Deploy Ready cuz I don't recognize the Jira Key\n"
			else
				#this issue has not been reviewed yet so we should just say its been QA'ed
				puts "\n#{actionUser} labeled pull request: #{pullTitle} with #{currentLabel}." 
				puts "But I can't move it to Deploy Ready cuz I don't recognize the Jira Key.\n"
			end
		elsif currentLabel == "reviewed" && jiraKey == nil
			if allLabels.find {|x| x['name'] == 'QAed'} != nil
				#this issue has been reviewed and qa'ed. we should move it to deploy ready
				puts "\n#{actionUser} labeled pull request: #{pullTitle} with #{currentLabel}." 
				puts "But I can't move it to deploy ready cuz I don't recognize the Jira Key.\n"
			else
				#this issue has not been qa'ed yet so we should just say that its been reviewed
				puts "\n#{actionUser} labeled pull request: #{pullTitle} with #{currentLabel}." 
				puts "But I can't move it to reviewed cuz I don't recognize the Jira Key.\n"
			end
		else
			puts "\n#{actionUser} labeled pull request: #{pullTitle} with #{currentLabel}." 
			puts "That means nothing to this program.\n"
		end
	else
		puts "#{actionUser} just took action: #{action} on pull request: #{pullTitle} "	
	end
end