class Event
	include DataMapper::Resource

	property :id, Serial
	property :user_name, String, :length => 100
	property :user_avatar_url, String, :length => 100
	property :user_url, String, :length => 100
	property :action, String, :length => 100
	property :code_title, String, :length => 100
	property :code_url, String, :length => 100
	property :time, Time
	property :success, Boolean

end