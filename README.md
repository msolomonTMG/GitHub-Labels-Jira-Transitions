GitHub-Labels-Jira-Transitions
==============================

## Transitions
- Open --> In Progress
  - Create a branch whose name contains a JIRA ticket
- In Progress --> In QA
  - Open a pull request with a branch named with a JIRA ticket
- In QA --> Code Reviewed
  - Label the pull request with "Reviewed"
  - This also works for QA Approved --> Code Reviewed
- In QA --> QA Approved
  - Label the pull request with "QAed"
  - This also works for Code Reviewed --> QA Approved
- Code Reviewed / QA Approved --> Deploy Ready
  - Label the pull request with both labels: "QAed" and "Reviewed"
- Deploy Ready --> Resolved
  - Merge the pull request

## Cool Stuff
- In QA --> In Progress --> In QA
  - If you have a pull request for a ticket and testing fails, testers will transition the ticket back to "In Progress"
  - Once a developer updates the branch for that pull request, the ticket will automatically transition back to "In QA" with a comment taken from the commit message
- JITR Tickets have custom fields updated
  - Creating a branch updates the Branch field
  - Opening a pull request updates the Pull Request field
  - This was done for issue searching since the fields created by the plugin cannot be queried

## Other stuff
- Dependencies
  - Sinatra
  - Json
  - Rest-Client
  - Ruby

