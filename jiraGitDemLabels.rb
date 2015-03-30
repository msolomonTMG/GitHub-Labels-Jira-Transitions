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
=begin
	elsif action == "synchronize"
		pullURL = push["pull_request"]["html_url"]			#URL of pull request
		pullTitle = push["pull_request"]["title"] 			#the title of the pull request
		branchTitle = push["pull_request"]["head"]["ref"] 	#the title of the branch in the PR

		pullJiraKeys = pullTitle.scan(/(?:\s|^)([A-Za-z]+-[0-9]+)(?=\s|$)/) #all of the jira keys in the PR title. ABCDEFG-1234567.
		branchJiraKeys = branchTitle.scan(/(?:|^)([A-Za-z]+-[0-9]+)(?=|$)/) #all of the jira keys in the branch title. ABCDEFG-1234567.

		#get the latest commit message on the PR and who made it.
		#then update the corresponding Jira ticket(s) with this comment
		commitsURL = push["pull_request"]["commits_url"]	
		commitsURLauth = commitsURL.insert(8,GIT_HUB_TOKEN+':@')
		commitsInfo = JSON.parse(RestClient.get(commitsURLauth))
		commitComment = commitsInfo[commitsInfo.length-1]["commit"]["message"]
		actionUserEmail = commitsInfo[commitsInfo.length-1]["commit"]["committer"]["email"]
		actionJiraName = commitsInfo[commitsInfo.length-1]["committer"]["login"]
		
		#if user uses thrillist email, use everything before @ as the jira name
		#if not, use the name that github passes us
		if actionUserEmail.split('@')[1] == "thrillist.com"
			actionJiraName = actionUserEmail.split('@')[0]
			actionJiraNameComment = actionJiraName.insert(0, "[~") + "]"
		elsif actionUserEmailDomain != "thrillist.com"
			case actionJiraName
			when "kpeltzer"
				actionJiraNameComment = "[~kpeltzer]"
			when "ken"
				actionJiraNameComment = "[~kpeltzer]"
			when "gilchenzion"
				actionJiraNameComment = "[~gchenzion]"
			when "ecandino"
				actionJiraNameComment = "[~ecandino]"
			when "deanmazurek"
				actionJiraNameComment = "[~dean]"
			when "kwadwo"
				actionJiraNameComment = "[~kboateng]"
			when "tarasiegel"
				actionJiraNameComment = "[~tsiegel]"
			when "samiamorwas"
				actionJiraNameComment = "[~mhaarhaus]"
			when "cahalanej"
				actionJiraNameComment = "[~jcahalane]"
			when "bdean"
				actionJiraNameComment = "[~brian-thrillist]"
			when "jay"
				actionJiraNameComment = "[~jchinthrajah]"
                        when "jay-thrillist"
                                actionJiraNameComment = "[~jchinthrajah]"
                        when "patrick"
                                actionJiraNameComment = "[~plange]"
			else	
				actionJiraNameURL = commitsInfo[commitsInfo.length-1]["committer"]["html_url"]
				actionJiraNameComment = "["+actionJiraName+"|"+actionJiraNameURL+"]"
			end
		end

		#if there are more Jira keys in the branch name than there are in the pull request,
		#then update the tickets in the branch name
		#else update the tickets in the pull request name
		if branchJiraKeys.length > pullJiraKeys.length
			jiraKeys = branchJiraKeys
		else
			jiraKeys = pullJiraKeys
		end

		#if someone entered a message in their pull request commit with #comment, it will
		#already show up in Jira so there is no need to post it with this app
		if commitComment.scan(/(?:\s|^)([A-Za-z]+-[0-9]+).+(#comment)(?=\s|$)/).length > 0
			applyComment = false
		else
			applyComment = true
		end

		#Loop through all of the tickets in the PR title
		#Decide what to do to each ticket depending on what labels the PR has
		i = 0;
		while (i < jiraKeys.length) do
			jiraKey = jiraKeys[i].join
			if applyComment == true
				#system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"body\": \"#{actionJiraNameComment} updated pull request [#{pullTitle}|#{pullURL}] with comment: #{commitComment}\"}' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/#{jiraKey}/comment"
			end
			#system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{\"add\": {\"body\": \"Pull Request updated by #{actionJiraNameComment}\"}}]}, \"transition\": {\"id\": \"21\"}}' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/#{jiraKey}/transitions"
		i+=1
		end
		#end of looping through array of tickets
	else
		puts "#{actionUser} just took action: #{action} on pull request: #{pullTitle} "	
	end

	if DEBUG == "on"
		puts push
	end
end
=end
