require 'json'
require 'rest-client'
require './config.rb'
require './jiraGitDemLabels.rb'

#returns an array of labels applied to a pull request
def get_labels (pull_request)
	labels_url = pull_request["issue_url"] + "/labels"
	labels = JSON.parse( RestClient.get( labels_url, {:params => {:access_token => GIT_HUB_TOKEN}, :accept => :json} ) )
	return labels
end

#returns an array of jira issues associated with a pull request
#if there are more jira issues in the pull request title than in the branch, return the issues in the title
def get_jira_issues (code, type)
	if type == "branch"
		jira_issues = code.scan(/(?:|^)([A-Za-z]+-[0-9]+)(?=|$)/)
	elsif type == "pull_request"
		issues_in_branch = code["head"]["ref"].scan(/(?:|^)([A-Za-z]+-[0-9]+)(?=|$)/)
		issues_in_pull_request_title = code["title"].scan(/(?:\s|^)([A-Za-z]+-[0-9]+)(?=\s|$)/)

		if issues_in_branch.length > issues_in_pull_request_title.length
			jira_issues = issues_in_branch
		else
			jira_issues = issues_in_pull_request_title
		end
	end

	return jira_issues
end

#returns message of the latest commit for a pull request
def get_latest_commit_message (pull_request, commits_url)
	url = commits_url.split('{')[0] + '/' + pull_request["head"]["sha"]
	latest_commit_info = JSON.parse(RestClient.get( url, {:params => {:access_token => GIT_HUB_TOKEN}, :accept => :json} ) )
	latest_commit_message = latest_commit_info["commit"]["message"]
	return latest_commit_message
end

#returns jira markdown for the user
#if this is a thrillist user, we assume their email is their jira name
#some user have special treatment because of the way they are setup
def get_user (user_object)
	user_info = JSON.parse(RestClient.get( user_object["url"], {:params => {:access_token => GIT_HUB_TOKEN}, :accept => :json} ) )
	
	#Example: msolomon@thrillist.com
	#user_email_domain = thrillist.com
	#user_email_prefix = msolomon
	if user_info["email"] != nil
		user_email_domain = user_info["email"].split('@')[1]
		user_email_prefix = user_info["email"].split('@')[0]

		#convert prefix to JIRA markdown or a link to github name if email domain is not thrillist
		if user_email_domain == "thrillist.com"
			user = user_email_prefix.insert(0, "[~") + "]"
		end
	else
		user = "["+user_object["login"]+"|"+user_object["html_url"]+"]"
	end

	#overwrite special cases
	case user_object["login"]
	when "kpeltzer"
		user = "[~kpeltzer]"
	when "ken"
		user = "[~kpeltzer]"
	when "gilchenzion"
		user = "[~gchenzion]"
	when "deanmazurek"
		user = "[~dean]"
	when "kwadwo"
		user = "[~kboateng]"
	when "tarasiegel"
		user = "[~tsiegel]"
	when "samiamorwas"
		user = "[~mhaarhaus]"
	when "cahalanej"
		user = "[~jcahalane]"
	when "bdeane"
		user = "[~brian-thrillist]"
	when "jay"
		user = "[~jchinthrajah]"
	when "jay-thrillist"
		user = "[~jchinthrajah]"
	when "patrick"
		user = "[~plange]"
	when "mvujovic-thrillist"
		user = "[~mvujovic]"
	when "mattdoyle"
		user = "[~matt]"
	when "laurenashpole"
		user = "[~lashpole]"
	end

	return user
end

def update_label_jira (jira_issues, current_label, pull_request_labels, user)
	i = 0
	while (i < jira_issues.length) do
		jira_issue = jira_issues[i].join
		#if the user labeled the pull request with QAed and the pull request is already labeled with reviewed, move to deploy ready
		if current_label == "QAed" && jira_issue != nil
			#move to qaed by user
			transition_issue jira_issue, QA_PASSED_ID, user
			#if this ticket is also reviewed, move to deploy ready
			if pull_request_labels.find {|x| x["name"] == "reviewed"} != nil
				transition_issue jira_issue, DEPLOY_READY_ID, user
			end
		elsif current_label == "reviewed" && jira_issue != nil
			#move to reveiwed by user
			transition_issue jira_issue, REVIEW_PASSED_ID, user
			#if this ticket is also QAed, move to deploy ready
			if pull_request_labels.find {|x| x["name"] == "QAed"} != nil
				transition_issue jira_issue, DEPLOY_READY_ID, user
			end
		elsif current_label == "Production verified" && jiraKey != nil
			#move to production verified by user
			transition_issue jira_issue, PRODUCTION_VERIFIED_ID, user
		else
			#dont need to do anything for this label
		end
		i+=1
	end
end

def update_message_jira (jira_issues, pull_request, latest_commit_message, user, is_jitr)
	if is_jitr == true
		qa_transition_id = QA_READY_JITR_ID
	else
		qa_transition_id = QA_READY_ID
	end
	#if someone entered a message in their pull request commit with #comment, it will
	#already show up in Jira so there is no need to post it with this app
	if latest_commit_message.scan(/(?:\s|^)([A-Za-z]+-[0-9]+).+(#comment)(?=\s|$)/).length > 0
		apply_comment = false
	else
		apply_comment = true
	end

	#loop through all of the tickets associated with the pull request
	#update with the comment of latest commit if necessary and then move to QA
	i = 0;
	while (i < jira_issues.length) do
		jira_issue = jira_issues[i].join
		if apply_comment == true
			transition_issue jira_issue, qa_transition_id, user, pull_request, "updated", latest_commit_message
		end
		i+=1
	end

end

#loops through all of the issues given as a parameter and sends them to the transition function
#need to know if a batch of tickets belongs to JITR team because they use different transition IDs
def start_qa (jira_issues, pull_request, user, is_jitr)
	if is_jitr == true
		qa_transition_id = QA_READY_JITR_ID
	else
		qa_transition_id = QA_READY_ID
	end

	i = 0;
	while (i < jira_issues.length) do
		jira_issue = jira_issues[i].join
		transition_issue jira_issue, qa_transition_id, user, pull_request, "opened"
		i+=1
	end
end

def start_progress (jira_issues, branch, user)
	i = 0;
	while (i < jira_issues.length) do
		jira_issue = jira_issues[i].join
		transition_issue jira_issue, START_PROGRESS_ID, user, branch, "created", "jitr"
		i+=1
	end
end

#add branch name or pull request name to jira issues
def update_development_info_jira (jira_issues, name, type)
	if type == "branch"
		field = JIRA_FIELD_BRANCH
	elsif type == "pull_request"
		field = JIRA_FIELD_PULL_REQUEST
	end
	i = 0;
	while (i < jira_issues.length) do
		jira_issue = jira_issues[i].join

		data = {
			"fields" => {
				field => name
			}
		}.to_json

		headers = { 
	        :"Authorization" => "Basic #{JIRA_TOKEN}",
	        :"Content-Type" => "application/json"
	    }

	    url = JIRA_URL + jira_issue
		response = RestClient.put( url, data, headers )

		i+=1
	end

	#"customfield_10000" = branch
	#"customfield_10123" = pull_request
end

# Accepts 1 Jira issue at a time
# Transitions the issue to the transition ID "update_to"
# User is the person who made an action to trigger the transition
# code_info is an optional array about the code that triggered this event (branches/pull requests)
def transition_issue (jira_issue, update_to, user, *code_info)
	url = JIRA_URL + jira_issue + "/transitions"

	case update_to
	when START_PROGRESS_ID
		body = "Progress started when #{user} created branch: #{code_info[0]} in GitHub"
	when QA_READY_ID, QA_READY_JITR_ID
		if code_info[1] == "opened"
			body = "#{user} opened pull request: [#{code_info[0]["title"]}|#{code_info[0]["html_url"]}]. Ready for QA"
		elsif code_info[1] == "updated"
			body = "#{user} updated pull request: [#{code_info[0]["title"]}|#{code_info[0]["html_url"]}] with comment: \n bq. #{code_info[2]}"
		end
	when QA_PASSED_ID
		body = "QA passed by #{user} #{JIRA_QA_IMAGE}"
	when REVIEW_PASSED_ID
		body = "Code review passed by #{user} #{JIRA_REVIEW_IMAGE}"
	when DEPLOY_READY_ID
		body = "Deploy ready"
	end

	data = {
		"update" => {
			"comment" => [
				{
					"add" => {
						"body" => body
					}	
				}
			]
		},
		"transition" => {
			"id" => "#{update_to}"
		}
	}.to_json

	#If this is a JITR ticket that's being transitioned, let's make sure we add PRs and Branch names during transition
	#I would love to find a way to quickly append this JSON to the existing data object to clean this up
	if update_to == START_PROGRESS_ID || update_to == QA_READY_JITR_ID
		#url.concat("?expand=transitions.fields")
		case update_to
		when START_PROGRESS_ID
			field = JIRA_FIELD_BRANCH

			data = {
				"update" => {
					"comment" => [
						{
							"add" => {
								"body" => body
							}	
						}
					],
					field => [
						{
							"set" => "#{code_info[0]}"
						}
					]
				},
				"transition" => {
					"id" => "#{update_to}"
				}
			}.to_json
		when QA_READY_JITR_ID
			field = JIRA_FIELD_PULL_REQUEST

			data = {
				"update" => {
					"comment" => [
						{
							"add" => {
								"body" => body
							}	
						}
					],
					field => [
						{
							"set" => "#{code_info[0]["html_url"]}"
						}
					]
				},
				"transition" => {
					"id" => "#{update_to}"
				}
			}.to_json

		end
		data.to_json
	end

	headers = { 
        :"Authorization" => "Basic #{JIRA_TOKEN}",
        :"Content-Type" => "application/json"
    }
   
	#figure out if this issue is able to be transitioned to where we want it to go
	#if we can transition it, post to JIRA, if we can't then don't send anything
	available_transitions = JSON.parse( RestClient.get( url, headers ) )
	able_to_transition = is_able_to_transition update_to, available_transitions

	if able_to_transition == true
		response = RestClient.post( url, data, headers )
	else
		puts "cannot transition this ticket"
	end

end

#returns true if the ticket's available transitions includes the transition that we want to update to
def is_able_to_transition(update_to, available_transitions)
	able_to_transition = false

	i = 0
	while (i < available_transitions["transitions"].length ) do
		available_transition = available_transitions["transitions"][i]
		if available_transition["id"] == update_to
			able_to_transition = true
			i += available_transitions["transitions"].length
		end 
		i += 1
	end

	return able_to_transition
end