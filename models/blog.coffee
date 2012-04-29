fs = require 'fs'

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
					data = JSON.parse text
					@nextId = data.nextId
					topics = data.blogs
					callback null, topics
				catch error
					callback error


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


	_updateTopicInListSync: (topics, topic) ->
		for t in topics
			if t.id is topic.id
				t.title = topic.title
				t.content= ""
				t.postedOn = topic.postedOn
				t.url = topic.url 
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


	# saveTopicByUrl: (url, content, callback) => 
	#
	# 	getTopicDetailsCallback = (err, topics) => 
	# 		callback err if err
	#
	# 		topic = @_findTopicInListByUrlSync topics, url 
	# 		if topic is null
	# 			callback "Topic not found #{url}"
	# 		else
	# 			updateTopicContent topic.id, content
	#
	# 	updateTopicContent = (id, content) => 
	# 		filePath = @dataPath + '/blog.' + id + '.html'				
	# 		fs.writeFile filePath, content, 'utf8', (err) -> 
	# 			if err 
	# 				callback "Topic #{url} content could not be saved. Error #{err}"
	# 			else
	# 			callback null, "OK"
	#
	# 	@_getAllTopics(getTopicDetailsCallback)


	saveTopic: (topic, callback) => 

		updateTopic = (err, topics) =>
			callback err if err

			if @_updateTopicInListSync(topics, topic) is false
				callback "Could not find topic #{topic.id}"
				return

			try
				jsonText = JSON.stringify topics, null, "\t"
				jsonText = '{ "nextId": ' + @nextId + ', "blogs":' + jsonText + '}'
				fs.writeFileSync @blogListFilePath, jsonText, 'utf8'		  
				updateTopicContent()
			catch error
				callback error

		updateTopicContent = => 
			filePath = @dataPath + '/blog.' + topic.id + '.html'	
			fs.writeFile filePath, topic.content, 'utf8', (err) -> 
				if err 
					callback "Topic #{topic.id} content could not be saved. Error #{err}"
				else
					callback null, "OK"

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

			try
				# todo: validate topic data
				topic.id = @nextId
				topic.url = topic.title.toLowerCase().replace(/\s/g, "-")
				topics.push topic
				@nextId = @nextId + 1
				jsonText = JSON.stringify topics, null, "\t"
				jsonText = '{ "nextId": ' + @nextId + ', "blogs":' + jsonText + '}'
				fs.writeFileSync @blogListFilePath, jsonText, 'utf8'		  
				updateTopicContent()
			catch error
				callback error

		updateTopicContent = => 
			filePath = @dataPath + '/blog.' + topic.id + '.html'	
			fs.writeFile filePath, topic.content, 'utf8', (err) -> 
				if err 
					callback "Topic #{topic.id} content could not be saved. Error #{err}"
				else
					callback null, topic

		if topic? is false
			callback "No topic was received"
			return

		# if topic.id? is false
		# 	callback "Topic Id is null" 
		# 	return

		@_getAllTopics(addTopic)


exports.BlogModel = BlogModel

