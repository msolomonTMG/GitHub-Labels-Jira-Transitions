get '/logs' do
	@events = Event.all(:order => [:time.desc])
	erb :log
end

def log_event (user, action, code, type, time)
	if type == "pull_request"
		event = Event.create(
			:user_name => user["login"],
			:user_avatar_url => user["avatar_url"],
			:user_url => user["html_url"],
			:action => action,
			:code_title => code["pull_request"]["title"],
			:code_url => code["pull_request"]["html_url"],
			:time => time
		)
	elsif type == "branch"
		code_url_repository = code["repository"]["name"]
		branch_name = code["ref"]
		event = Event.create(
			:user_name => user["login"],
			:user_avatar_url => user["avatar_url"],
			:user_url => user["html_url"],
			:action => action,
			:code_title => branch_name,
			:code_url => "https://github.com/Thrillist/#{code_url_repository}/tree/#{branch_name}",
			:time => time
		)
	end		
end