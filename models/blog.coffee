fs = require 'fs'

class BlogModel

	constructor: (@dataPath) -> 
		@blogListFilePath = "#{dataPath}/blogs.json"


	_getAllTopics: (callback) =>
		console.log "_getAllTopics"

		fs.readFile @blogListFilePath, 'utf8', (err, text) ->
			topics = null
			if err is null
	  		data = JSON.parse text
	  		topics = data.blogs
	  	else 
	  		console.log "Error reading topic list #{err}" 
		  callback topics


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


	# ===================================
	# Public Methods 
	# ===================================

	getAllTopics: (callback) => 
		@_getAllTopics (topics) -> 
			callback topics


	getTopicByUrl: (url, callback) =>
		
		console.log "GetTopicByUrl #{url}"
		topic = null

		getTopicDetailsCallback = (topics) => 
			topic = @_findTopicInListByUrlSync topics, url
			if topic is null
				dataNotFound = { error: "Topic not found" }
				callback dataNotFound 
			else
				filePath = @dataPath + '/blog.' + topic.id + '.html'	
				fs.readFile filePath, 'utf8', (err, text) ->
					if err isnt null
						data = { error: "Topic content not found" }
						console.log "Error: #{err}" 
					else
						data = { 
							title: topic.title,
							content: text,
							postedOn: topic.postedOn,
							url: topic.url
						}
						console.log "Topic ok #{data.title}"
					callback data

		@_getAllTopics(getTopicDetailsCallback) 


	saveTopicByUrl: (url, content, callback) => 
		console.log "saveTopicByUrl #{url}"

		getTopicDetailsCallback = (topics) => 
			topic = @_findTopicInListByUrlSync topics, url 
			if topic is null
				data = { error: "Topic not found" }
				console.log "#{data.error}"
				callback data
			else
				updateTopicContent topic.id, content

		updateTopicContent = (id, content) => 
			filePath = @dataPath + '/blog.' + id + '.html'	

			console.log "Model: rewriting file #{filePath}"
			
			fs.writeFile filePath, content, 'utf8', (err) -> 
				if err isnt null
					data = { error: "Topic content could not be saved" }
					console.log err
				else
					console.log "Model: file was rewritten"
					data = {}
				callback data 

		@_getAllTopics(getTopicDetailsCallback)


exports.BlogModel = BlogModel

