require 'sinatra'
require 'json'
require 'rest-client'
require 'rubygems'
require 'mongo'
require './config.rb'
require './process.rb'

include Mongo

configure do
  conn = Mongo::Connection.new("localhost", 27017)
  set :mongo_connection, conn
  set :mongo_db, conn.db('test')
end

get '/collections/?' do
  content_type :json
  settings.mongo_db.collection_names.to_json
end

helpers do
  # a helper method to turn a string ID
  # representation into a BSON::ObjectId
  def object_id val
    BSON::ObjectId.from_string(val)
  end

  def document_by_id id
    id = object_id(id) if String === id
    settings.mongo_db['test'].
      find_one(:_id => id).to_json
  end
end

# list all documents in the test collection
get '/documents/?' do
  content_type :json
  settings.mongo_db['test'].find.to_a.to_json
end

# find a document by its ID
get '/document/:id/?' do
  content_type :json
  document_by_id(params[:id])
end

# insert a new document from the request parameters,
# then return the full document
post '/new_document/?' do
  content_type :json
  new_id = settings.mongo_db['test'].insert params
  document_by_id(new_id)
end

# update the document specified by :id, setting its
# contents to params, then return the full document
put '/update/:id/?' do
  content_type :json
  id = object_id(params[:id])
  settings.mongo_db['test'].update({:_id => id}, params)
  document_by_id(id)
end

# update the document specified by :id, setting just its
# name attribute to params[:name], then return the full
# document
put '/update_name/:id/?' do
  content_type :json
  id   = object_id(params[:id])
  name = params[:name]
  settings.mongo_db['test'].
    update({:_id => id}, {"$set" => {:name => name}})
  document_by_id(id)
end

# delete the specified document and return success
delete '/remove/:id' do
  content_type :json
  db = settings.mongo_db['test']
  id = object_id(params[:id])
  if db.find_one(id)
    db.remove(:_id => id)
    {:success => true}.to_json
  else
    {:success => false}.to_json
  end
end