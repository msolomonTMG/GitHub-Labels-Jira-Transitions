# Author: Mike Solomon
# This app uses some terrible programming practices to flip Jira statuses
# based on GitHub labels on corresponding pull requests
# 

require 'sinatra'
require 'json'
require 'rest-client'
require './config.rb'

post '/payload' do
	push = JSON.parse(request.body.read)				#the JSON that GitHub API sends us
	action = push["action"]								#the action that was taken
	actionUser = push["sender"]["login"]				#user who took the action
	pullTitle = push["pull_request"]["title"] 			#the title of the pull request
	branchTitle = push["pull_request"]["head"]["ref"] 	#the title of the branch in the PR

	if action == "labeled"
		currentLabel = push["label"]["name"]					#the name of the label that was just applied
		pullJiraKeys = pullTitle.scan(/(?:\s|^)([A-Za-z]+-[0-9]+)(?=\s|$)/) #all of the jira keys in the PR title. ABCDEFG-1234567.
		branchJiraKeys = branchTitle.scan(/(?:|^)([A-Za-z]+-[0-9]+)(?=|$)/) #all of the jira keys in the branch title. ABCDEFG-1234567.
		issueURL = push["pull_request"]["issue_url"]			#the URL of a pull request's corresponding issue
		issueURLauth = issueURL.insert(8,GIT_HUB_TOKEN+':@') 	#authenticate dat ish
		issueInfo = JSON.parse(RestClient.get(issueURLauth))	#all of the info on the issue/pull request
		issueLabels = issueURLauth+'/labels'					#URL of the labels
		allLabels = JSON.parse(RestClient.get(issueLabels))		#all of the label info for the issue/pull request

		actionUserURL = push["sender"]["url"]
		actionUserURLauth = actionUserURL.insert(8,GIT_HUB_TOKEN+':@')
		actionUserInfo = JSON.parse(RestClient.get(actionUserURLauth))
		actionUserEmail = actionUserInfo["email"]
		
		#if user uses thrillist email, use everything before @ as the jira name
		#if not, use the git hub name and link that
		if actionUserEmail.split('@')[1] == "thrillist.com"
			actionJiraName = actionUserEmail.split('@')[0]
			actionJiraNameComment = actionJiraName.insert(0, "[~") + "]"
		else
			actionUserHTMLURL = push["sender"]["html_url"]
			actionJiraNameComment = "["+actionUser+"|"+actionUserHTMLURL+"]"
		end

		#if there are more Jira keys in the branch name than there are in the pull request,
		#then update the tickets in the branch name
		#else update the tickets in the pull request name
		if branchJiraKeys.length > pullJiraKeys.length
			jiraKeys = branchJiraKeys
		else
			jiraKeys = pullJiraKeys
		end

		#Loop through all of the tickets in the PR title
		#Decide what to do to each ticket depending on what labels the PR has
		i = 0;
		while (i < jiraKeys.length) do
			jiraKey = jiraKeys[i].join

			if currentLabel == "QAed" && jiraKey != nil
				if allLabels.find {|x| x['name'] == 'reviewed'} != nil
					#this issue has been qa'ed and reviewed. we should move it to deploy ready
					puts "\n#{actionUser} labeled pull request: #{pullTitle} with #{currentLabel}."
					#QA'ed command: 
					system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{\"add\": {\"body\": \"QA passed by #{actionJiraNameComment} !http://assets3.thrillist.com/v1/image/1356002|height=120px,width=120px!\"}}]}, \"transition\": {\"id\": \"#{QA_PASSED_ID}\"}}' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/#{jiraKey}/transitions"
					#Deploy Ready command
					system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{\"add\": {\"body\": \"Ready to deploy\"}}]}, \"transition\": {\"id\": \"#{DEPLOY_READY_ID}\"}}\' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/#{jiraKey}/transitions"
				else
					#this issue has not been reviewed yet so we should just say its been QA'ed
					puts "\n#{actionUser} labeled pull request: #{pullTitle} with #{currentLabel}."
					#QA'ed command: 
					system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{\"add\": {\"body\": \"QA passed by #{actionJiraNameComment} !http://assets3.thrillist.com/v1/image/1356002|height=120px,width=120px!\"}}]}, \"transition\": {\"id\": \"#{QA_PASSED_ID}\"}}' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/#{jiraKey}/transitions"
				end
			
			elsif currentLabel == "reviewed" && jiraKey != nil
				if allLabels.find {|x| x['name'] == 'QAed'} != nil
					#this issue has been reviewed and qa'ed. we should move it to deploy ready
					puts "\n#{actionUser} labeled pull request: #{pullTitle} with #{currentLabel}."
					#Reviewed command: 
					system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{\"add\": {\"body\": \"Code review passed by #{actionJiraNameComment} !http://www.devart.com/images/products/logos/large/review-assistant.png!\"}}]}, \"transition\": {\"id\": \"#{REVIEW_PASSED_ID}\"}}' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/#{jiraKey}/transitions"
					#Deploy Ready command: 
					system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{\"add\": {\"body\": \"Ready to deploy\"}}]}, \"transition\": {\"id\": \"#{DEPLOY_READY_ID}\"}}' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/#{jiraKey}/transitions"
				else
					#this issue has not been qa'ed yet so we should just say that its been reviewed
					puts "\n#{actionUser} labeled pull request: #{pullTitle} with #{currentLabel}." 
					#Reviewed command: 
					system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{ \"add\": {\"body\": \"Code review passed by #{actionJiraNameComment} !http://www.devart.com/images/products/logos/large/review-assistant.png!\"} }]}, \"transition\": {\"id\": \"#{REVIEW_PASSED_ID}\"}}' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/#{jiraKey}/transitions"
				end
			else
				puts "\n#{actionUser} labeled pull request: #{pullTitle} with #{currentLabel}." 
				puts "That means nothing to this program.\n"
			end
		
		i+=1
		end
		#end of looping through array of tickets
	else
		puts "#{actionUser} just took action: #{action} on pull request: #{pullTitle} "	
	end
end
