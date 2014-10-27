#Credentials
GIT_HUB_TOKEN = "bfeb9ffe382b55fd87dd87368feecd3ff74490e0"
JIRA_USER_NAME = "msolomon"
JIRA_PASSWORD = "ynftpo12"

#Jira Transition IDs
QA_PASSED_ID = "91"
REVIEW_PASSED_ID = "101"
DEPLOY_READY_ID = "111"

#Commands
#QA'ed command: 
#system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{\"add\": {\"body\": \"QA passed\"}}]}, \"transition\": {\"id\": \"#{QA_PASSED_ID}\"}}' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/'+jiraKey+'/transitions"

#Deploy Ready command
#system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{\"add\": {\"body\": \"Ready to deploy\"}}]}, \"transition\": {\"id\": \"#{DEPLOY_READY_ID}\"}}\' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/'+jiraKey+'/transitions"

#Reviewed command: 
#system "curl -D- -u #{JIRA_USER_NAME}:#{JIRA_PASSWORD} -X POST --data '{\"update\": {\"comment\": [{\"add\": {\"body\": \"Code review passed\"}}]}, \"transition\": {\"id\": \"#{REVIEW_PASSED_ID}\"}}' -H \"Content-Type: application/json\" https://thrillistmediagroup.atlassian.net/rest/api/latest/issue/'+jiraKey+'/transitions"
			