require 'sinatra'
require 'json'

post '/payload' do
	push = JSON.parse(request.body.read)	#the JSON request that GitHub API sends us
	action = push["action"]					#the action that was taken on the issue
	issueTitle = push["issue"]["title"]		#the title of the issue
	issueLabel = push["label"]["name"]		#the name of the label that was just applied
	issueLabels = push["issue"]["labels"]	#array of all labels on the issue
	issueKey = issueTitle.split.first		#the issueKey for Jira dervived from beginning string of GitHub ticket


	#if someone labels this issue with QA'ed, we need to transition the ticket in Jira accoridngly
	if action == "labeled" && issueLabel == "QAed"
		#if we Qa'ed the ticket but it still needs review, move issue to QA Approved
		if issueLabels.find {|x| x['name'] == 'needs review'} != nil
			puts "this issue was qa'ed but it still needs review"
			system 'curl -D- -u msolomon:ynftpo12 -X POST --data \'{"update": {"comment": [{"add": {"body": "QA complete"}}]}, "transition": {"id": "10404"}}\' -H "Content-Type: application/json" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/'+issueKey+'/transitions'
		#if we Qa'ed the ticket and it has been reviewed, move issue to QA approved and then move it to Deploy Ready
		elsif issueLabels.find {|x| x['name'] == 'reviewed'} != nil
			system 'curl -D- -u msolomon:ynftpo12 -X POST --data \'{"update": {"comment": [{"add": {"body": "QA complete"}}]}, "transition": {"id": "10404"}}\' -H "Content-Type: application/json" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/'+issueKey+'/transitions'
			#system 'curl -D- -u msolomon:ynftpo12 -X POST --data \'{"update": {"comment": [{"add": {"body": "QA complete"}}]}, "transition": {"id": "10407"}}\' -H "Content-Type: application/json" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/'+issueKey+'/transitions'
		end
	#if someone labels this issue with reviewed, we need to transition the ticket in Jira accordingly
	elsif action == "labeled" && issueLabel == "reviewed"
		#if we reviewed the code but it still needs qa, move issue to Code Reviewed
		if issueLabels.find {|x| x['name'] == 'needs qa'} != nil
			puts "this issue was reviewed but this still needs qa"
			#need the transition key for moving to QA
			#system 'curl -D- -u msolomon:ynftpo12 -X POST --data \'{"update": {"comment": [{"add": {"body": "Code Review Passed"}}]}, "transition": {"id": "101"}}\' -H "Content-Type: application/json" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/'+issueKey+'/transitions'
		#if we reviewed the code and it has been QAed, move issue to Code Reviewed and then move it to Deploy Ready
		elsif issueLabels.find {|x| x['name'] == 'QAed'} != nil
			#need the transition key for moving to Code Reviewed and Deploy Ready
			#system 'curl -D- -u msolomon:ynftpo12 -X POST --data \'{"update": {"comment": [{"add": {"body": "Code Review Passed"}}]}, "transition": {"id": "101"}}\' -H "Content-Type: application/json" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/'+issueKey+'/transitions'				
		end
	end
end