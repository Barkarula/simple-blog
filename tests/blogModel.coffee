assert = require 'assert' 
{BlogModel}  = require '../models/blog'

getAllTopicsOK = ->

	dataPath = __dirname + '/../data' 
	model = new BlogModel dataPath 
	
	model.getAllTopics (err, topics) -> 
		assert err is null, "Error retrieving all topics" 


getAllTopicsError = ->

	dataPath = __dirname + '/../xx-data' 
	model = new BlogModel dataPath 
	
	model.getAllTopics (err, topics) -> 
		assert err isnt null, "Should have gotten an error!" 


getTopicOK = ->

	dataPath = __dirname + '/../data' 
	model = new BlogModel dataPath 
	
	model.getAllTopics (err, topics) -> 
		url = topics[0].url
		model.getTopicByUrl url, (err, topic) ->
			assert err is null, "Error retrieving topic #{url}"


getTopicError = ->

	dataPath = __dirname + '/../data' 
	model = new BlogModel dataPath 
	
	model.getAllTopics (err, topics) -> 
		url = topics[0].url + "-xxx"
		model.getTopicByUrl url, (err, topic) ->
			assert err isnt null, "Should have gotten an error retrieving topic #{url}"

# -----------------
# Execute the tests
# -----------------
getAllTopicsOK()
getAllTopicsError()
getTopicOK()
getTopicError()

