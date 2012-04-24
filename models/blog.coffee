fs = require 'fs'

class BlogModel

	constructor: (@dataPath) -> 
		@blogListFilePath = "#{dataPath}/blogs.json"


	_getAllTopics: (callback) =>
		fs.readFile @blogListFilePath, 'utf8', (err, text) ->
			if err 
				console.trace "_getAllTopics error"
				console.log "_getAllTopics error #{err}"
				callback "Error reading topic list #{err}" 
			else
				data = JSON.parse text
				topics = data.blogs
				callback null, topics


	_findTopicInListByUrlSync: (topics, url) ->
		topic = null

		for t in topics
			if t.url is url
				topic = { 
					id: t.id,
					title: t.title, 
					content: "", # needs to be read from disk
					postedOn: t.postedOn,
					url: t.url 
				}
				break

		return topic


	_findTopicInListByIdSync: (topics, id) ->
		topic = null

		for t in topics
			if t.id is id
				topic = { 
					id: t.id,
					title: t.title, 
					content: "", # needs to be read from disk
					postedOn: t.postedOn,
					url: t.url 
				}
				break

		return topic


	# ===================================
	# Public Methods 
	# ===================================

	getAllTopics: (callback) => 
		#console.log "getAllTopics"
		@_getAllTopics (err, topics) -> 
			callback err, topics


	getTopicByUrl: (url, callback) =>
		#console.log "getTopicByUrl #{url}"

		getTopicDetailsCallback = (err, topics) => 
			callback err if err

			topic = @_findTopicInListByUrlSync topics, url
			if topic is null
				callback "Topic #{url} not found" 
			else
				filePath = @dataPath + '/blog.' + topic.id + '.html'	
				fs.readFile filePath, 'utf8', (err, text) ->
					if err 
						callback "Could not retrieve content for topic #{url} (#{err})"
					else
						topic.content = text
						callback null, topic

		@_getAllTopics(getTopicDetailsCallback) 


	saveTopicByUrl: (url, content, callback) => 
		console.log "saveTopicByUrl #{url}"

		getTopicDetailsCallback = (err, topics) => 
			callback err if err

			topic = @_findTopicInListByUrlSync topics, url 
			if topic is null
				callback "Topic not found #{url}"
			else
				updateTopicContent topic.id, content

		updateTopicContent = (id, content) => 
			filePath = @dataPath + '/blog.' + id + '.html'				
			fs.writeFile filePath, content, 'utf8', (err) -> 
				if err 
					callback "Topic #{url} content could not be saved. Error #{err}"
				else
				callback null, "OK"

		@_getAllTopics(getTopicDetailsCallback)


	saveTopic: (topic, callback) => 
		console.log "dataPath", @dataPath
		console.log "blogList", @blogListFilePath 
		console.log "saveTopic #{topic.id}"
		callback "Topic Id is null", null if topic.id is null

		getTopicDetailsCallback = (err, topics) => 
			callback err if err

			topicMeta = @_findTopicInListByIdSync topics, topic.id 
			if topicMeta is null
				callback "Topic not found, id=#{topic.id}"
			else
				updateTopic topicMeta

		updateTopic = (topicMeta) =>
			updateTopicMetaData topicMeta, (err, data) ->
				if err
					console.log "update topic error. Bailing out. Error: #{err}"
					callback err
				else
					updateTopicContent topic.id, topic.content 

		updateTopicMetaData = (topicMeta) =>
			console.log "TODO: update topic metadata"
			err = null
			if err
				callback err
			else
				updateTopicContent topicMeta.id, topic.content 

		updateTopicContent = (id, content) => 
			console.log "Updating topic content #{content}..."
			filePath = @dataPath + '/blog.' + id + '.html'				
			fs.writeFile filePath, content, 'utf8', (err) -> 
				if err 
					callback "Topic #{url} content could not be saved. Error #{err}"
				else
					callback null, "OK"


		@_getAllTopics(getTopicDetailsCallback)


exports.BlogModel = BlogModel

