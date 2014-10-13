require 'sinatra'
require 'json'
require 'rest-client'

post '/payload' do
	push = JSON.parse(request.body.read)					#the JSON that GitHub API sends us
	action = push["action"]									#the action that was taken
	currentLabel = push["label"]["name"]					#the name of the label that was just applied
	pullTitle = push["pull_request"]["title"]				#the title of the pull request
	jiraKey = pullTitle.split.first							#the issueKey for Jira dervived from beginning string of GitHub ticket
	issueURL = push["pull_request"]["issue_url"]			#the URL of a pull request's corresponding issue
		labelsURL = issueURL + '/labels'					#URL to get just the labels of the pull request issue
		allLabels = JSON.parse(RestClient.get(labelsURL))	#parses the labels

	#if someone labels this with QA'ed, we need to transition the ticket based on whether it has been Reviewed or not
	if action == "labeled" && currentLabel == "QAed"
		if allLabels.find {|x| x['name'] == 'reviewed'} != nil
			#this issue has been qa'ed and reviewed. we should move it to QA'ed and then move it to deploy ready
			puts "this issue is good to go"
			#QA'ed command: system 'curl -D- -u msolomon:ynftpo12 -X POST --data \'{"update": {"comment": [{"add": {"body": "QA complete"}}]}, "transition": {"id": "10404"}}\' -H "Content-Type: application/json" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/'+issueKey+'/transitions'
			#Deploy Ready command: system 'curl -D- -u msolomon:ynftpo12 -X POST --data \'{"update": {"comment": [{"add": {"body": "QA complete"}}]}, "transition": {"id": "10407"}}\' -H "Content-Type: application/json" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/'+issueKey+'/transitions'
		else
			#this issue has not been reviewed yet so we should just say its been QA'ed
			puts "this issue needs review"
			#QA'ed command: system 'curl -D- -u msolomon:ynftpo12 -X POST --data \'{"update": {"comment": [{"add": {"body": "QA complete"}}]}, "transition": {"id": "10404"}}\' -H "Content-Type: application/json" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/'+jiraKey+'/transitions'
		end
	#if someone labels this with Reviewed, we need to transition the ticket based on whether it has been QAed or not
	elsif action == "labeled" && currentLabel == "reviewed"
		if allLabels.find {|x| x['name'] == 'QAed'} != nil
			#this issue has been reviewed adnd qa'ed. we should move it to Reviewed and then move it to deploy ready
			puts "this issue is good to go too"
			#Reviewed command: system 'curl -D- -u msolomon:ynftpo12 -X POST --data \'{"update": {"comment": [{"add": {"body": "QA complete"}}]}, "transition": {"id": "10404"}}\' -H "Content-Type: application/json" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/'+issueKey+'/transitions'
			#Deploy Ready command: system 'curl -D- -u msolomon:ynftpo12 -X POST --data \'{"update": {"comment": [{"add": {"body": "QA complete"}}]}, "transition": {"id": "10407"}}\' -H "Content-Type: application/json" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/'+issueKey+'/transitions'
		else
			#this issue has not been qa'ed yet so we should just say that its been reviewed
			puts "this issue needs qa"
			#Reviewed command: system 'curl -D- -u msolomon:ynftpo12 -X POST --data \'{"update": {"comment": [{"add": {"body": "QA complete"}}]}, "transition": {"id": "10404"}}\' -H "Content-Type: application/json" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/'+issueKey+'/transitions'
		end
	end

end