fs = require 'fs'
{BlogTopic}  = require './blogTopic'

class BlogModel

	constructor: (@dataPath, blogList = "blogs.json") -> 
		@blogListFilePath = "#{dataPath}/#{blogList}"
		@nextId = null


	_getAllTopics: (callback) =>
		fs.readFile @blogListFilePath, 'utf8', (err, text) =>
			if err 
				callback "Error reading topic list #{err}" 
			else
				try
					topics = []
					data = JSON.parse text
					@nextId = data.nextId

					for t in data.blogs
						topic = new BlogTopic(t.title)
						topic.id = t.id
						topic.content = t.content
						topic.createdOn = new Date(t.createdOn)
						topic.updatedOn = new Date(t.updatedOn)
						topic.postedOn = new Date(t.postedOn)
						topic.url = t.url
						topics.push topic

					topics.sort (x, y) ->
						# by date descending
						return -1 if x.postedOn > y.postedOn
						return 1 if x.postedOn < y.postedOn
						return 0

					callback null, topics
				catch error
					callback error


	_findTopicInListByUrlSync: (topics, url) ->
		for topic in topics
			if topic.url is url
				return topic

		# Possible simplification
		# return topic for topic in topics when topic.url is url

		return null


	_findTopicInListByIdSync: (topics, id) ->
		for topic in topics
			if topic.id is id
				return topic
		return null


	_updateTopicInListSync: (topics, updatedTopic) ->
		for topic, i in topics
			#console.log topic.id, updatedTopic.id
			if topic.id is updatedTopic.id
				#console.log "found at position: ", i
				topics[i].update(updatedTopic)
				return true
		return false


	# ===================================
	# Public Methods 
	# ===================================

	getAllTopics: (callback) => 
		@_getAllTopics (err, topics) -> 
			callback err, topics


	getTopicByUrl: (url, callback) =>

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


	saveTopic: (topic, callback) => 

		updateTopic = (err, topics) =>
			callback err if err

			if topic.isValid()
				if @_updateTopicInListSync(topics, topic)
					# console.log "Topic to save"
					# console.dir topic
					topic = @_findTopicInListByIdSync(topics, topic.id)
					jsonText = JSON.stringify topics, null, "\t"
					jsonText = '{ "nextId": ' + @nextId + ', "blogs":' + jsonText + '}'
					fs.writeFileSync @blogListFilePath, jsonText, 'utf8'		  
					updateTopicContent()
				else
					callback "Could not find topic #{topic.id}"
					return
			else
				callback topic.getErrors().join('-')

		updateTopicContent = => 
			filePath = @dataPath + '/blog.' + topic.id + '.html'	
			fs.writeFile filePath, topic.content, 'utf8', (err) -> 
				if err 
					callback "Topic #{topic.id} content could not be saved. Error #{err}"
				else
					# console.log "Topic saved"
					# console.dir topic
					callback null, topic

		if topic? is false
			callback "No topic was received"
			return

		if topic.id? is false
			callback "Topic Id is null" 
			return

		@_getAllTopics(updateTopic)


	saveNewTopic: (topic, callback) => 

			addTopic = (err, topics) =>
				callback err if err

				topic.id = @nextId
				topic.setUrl()
				topic.createdOn = new Date()
				if topic.isValid()
					topics.push topic
					@nextId = @nextId + 1
					jsonText = JSON.stringify topics, null, "\t"
					jsonText = '{ "nextId": ' + @nextId + ', "blogs":' + jsonText + '}'
					fs.writeFileSync @blogListFilePath, jsonText, 'utf8'		  
					updateTopicContent()
				else
					callback topic.getErrors().join('-')

			updateTopicContent = => 
				filePath = @dataPath + '/blog.' + topic.id + '.html'	
				fs.writeFile filePath, topic.content, 'utf8', (err) -> 
					if err 
						callback "Topic #{topic.id} content could not be saved. Error #{err}"
					else
						callback null, topic

			@_getAllTopics(addTopic)


exports.BlogModel = BlogModel

