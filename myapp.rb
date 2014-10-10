require 'sinatra'
require 'json'

post '/payload' do
	push = JSON.parse(request.body.read)	#the JSON request that GitHub API sends us
	action = push["action"]					#the action that was taken on the issue
	issueTitle = push["issue"]["title"]		#the title of the issue
	label = push["label"]["name"]			#the label that was given to the issue
	issueKey = issueTitle.split.first		#the issueKey for Jira

	#if someone labels this issue with QA'ed, we need to transition the ticket in Jira accoridngly
	if action == "labeled" && label == "QAed"
		system 'curl -D- -u msolomon:ynftpo12 -X POST --data \'{"update": {"comment": [{"add": {"body": "QA complete"}}]}, "transition": {"id": "21"}}\' -H "Content-Type: application/json" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/'+issueKey+'/transitions'
	#if someone labels this issue with needs QA, we need to transition the ticket in Jira to "in QA"
	elsif action == "labeled" && label == "needs QA"
		puts "#{issueTitle} was #{action} with #{label}"
	end
end
