assert = require 'assert' 
{BlogModel}  = require '../models/blog'
{BlogTopic}  = require '../models/blogTopic'

getAllTopicsOK = ->
	console.log "getAllTopicsOK"
	dataPath = __dirname + '/../data' 
	model = new BlogModel dataPath 
	
	model.getAllTopics (err, topics) -> 
		assert err is null, "Error retrieving all topics. Error: #{err}" 
		console.log "getAllTopicsOK ended"


getAllTopicsError = ->
	console.log "getAllTopicsError"

	dataPath = __dirname + '/../xx-data' 
	model = new BlogModel dataPath 
	
	model.getAllTopics (err, topics) -> 
		assert err isnt null, "Should have gotten an error!" 
		console.log "getAllTopicsError ended"


getTopicOK = ->
	console.log "getTopicOK"

	dataPath = __dirname + '/../data' 
	model = new BlogModel dataPath 
	
	model.getAllTopics (err, topics) -> 
		url = topics[0].url
		model.getTopicByUrl url, (err, topic) ->
			assert err is null, "Error retrieving topic #{url}. Error: #{err}"
			console.log "getTopicOK ended"


getTopicError = ->
	console.log "getTopicError"

	dataPath = __dirname + '/../data' 
	model = new BlogModel dataPath 
	
	model.getAllTopics (err, topics) -> 
		url = topics[0].url + "-xxx"
		model.getTopicByUrl url, (err, topic) ->
			assert err isnt null, "Should have gotten an error retrieving topic #{url}. Error #{err}"
			console.log "getTopicError ended"


saveExistingTopic = -> 
	console.log "saveExistingTopic"

	dataPath = __dirname + '/../data' 
	model = new BlogModel dataPath 
	timeStamp = new Date()
	topic = new BlogTopic("unit test title")
	topic.id = 4
	topic.summary = "unit test summary #{timeStamp}"
	topic.content = "unit test content #{timeStamp}"
	topic.postedOn = timeStamp

	model.saveTopic topic, (err, data) -> 
		assert err is null, "Error saving topic #{topic.url}. Error: #{err}"
		console.log "saveExistingTopic ended"


saveTopicError = -> 

	dataPath = __dirname + '/../data' 
	model = new BlogModel dataPath

	model.saveTopic null, (err, data) -> 
		assert err isnt null, "Should have gotten an error saving a null topic"

	model.saveTopic {}, (err, data) -> 
		assert err isnt null, "Should have gotten an error saving a topic with null id"

	topic = new BlogTopic()
	topic.id = -1
	model.saveTopic topic, (err, data) -> 
		assert err isnt null, "Should have gotten an error saving a non-existing topic id"


saveNewTopic = ->
	console.log "saveNewTopic"

	timeStamp = new Date()
	topic = new BlogTopic("test one two three")
	topic.summary = "new unit test summary #{timeStamp}"
	topic.content = "new unit test content #{timeStamp}"
	topic.postedOn = timeStamp

	dataPath = __dirname + '/../data' 
	model = new BlogModel dataPath 
	model.saveNewTopic topic, (err, data) -> 
		assert err is null, "Error saving new topic #{topic.url}. Error: #{err}"
		console.log "saveNewTopic ended."

# -----------------
# Execute the tests
# -----------------
getAllTopicsOK()
getAllTopicsError()
getTopicOK()
getTopicError()
saveExistingTopic()
saveTopicError()
saveNewTopic()

