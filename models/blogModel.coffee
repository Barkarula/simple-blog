fs = require 'fs'
{BlogTopic}  = require './blogTopic'

class BlogModel

	constructor: (@dataPath, blogList = "blogs.json") -> 
		@blogListFilePath = "#{dataPath}/#{blogList}"
		@nextId = null


	# http://stackoverflow.com/a/7153486/446681
	_isInt: (n) =>
		(typeof(n) is 'number') and (Math.round(n) % 1 == 0)


	_getAllTopicsMetaData: (callback) =>
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
						topic.content = "" # not considered meta-data
						topic.createdOn = new Date(t.createdOn)
						topic.updatedOn = new Date(t.updatedOn)
						topic.postedOn = new Date(t.postedOn)
						topic.url = t.url
						topic.summary = t.summary
						topics.push topic

					topics.sort (x, y) ->
						# by date descending
						return -1 if x.postedOn > y.postedOn
						return 1 if x.postedOn < y.postedOn
						return 0

					callback null, topics
				catch error
					console.log "Error reading all topics #{error}"
					callback error


	_getTopicMetaDataByUrlSync: (topicsMeta, url) ->
		for topic in topicsMeta
			if topic.url is url
				return topic
		return null


	_getTopicMetaDataByIdSync: (topicsMeta, id) ->
		for topic in topicsMeta
			if topic.id is id
				return topic
		return null


	_updateTopicMetaDataByIdSync: (topicsMeta, updatedTopic) ->
		for topic, i in topicsMeta
			if topic.id is updatedTopic.id
				topicsMeta[i].update(updatedTopic, false)
				return true
		return false


	_saveTopicsMetaSync: (topicsMeta) =>
		jsonText = JSON.stringify topicsMeta, null, "\t"
		jsonText = '{ "nextId": ' + @nextId + ', "blogs":' + jsonText + '}'
		fs.writeFileSync @blogListFilePath, jsonText, 'utf8'		  


	# ===================================
	# Public Methods 
	# ===================================

	getAllTopics: (callback) => 
		@_getAllTopicsMetaData (err, topicsMeta) -> 
			callback err, topicsMeta


	getRecentTopics: (callback) => 
		@_getAllTopicsMetaData (err, topicsMeta) -> 
			howMany = 10
			topicsMeta = topicsMeta.slice(0, howMany) if topicsMeta.length > howMany
			callback err, topicsMeta


	getTopicByUrl: (url, callback) =>

		getTopicDetailsCallback = (err, topicsMeta) => 
			callback err if err

			topic = @_getTopicMetaDataByUrlSync topicsMeta, url
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

		@_getAllTopicsMetaData(getTopicDetailsCallback) 


	saveTopic: (topicToSave, callback) => 

		topicAllData = null

		updateTopic = (err, topicsMeta) =>
			callback err if err

			if topicToSave.isValid()
				if @_updateTopicMetaDataByIdSync(topicsMeta, topicToSave)
					@_saveTopicsMetaSync topicsMeta

					# This is needed because the topic that we received (topicToSave)
					# might not have all the fields (e.g. created on, updated on)
					topicAllData = @_getTopicMetaDataByIdSync(topicsMeta, topicToSave.id)
					topicAllData.content = topicToSave.content

					updateTopicContent()
				else
					callback "Could not find topic #{topicToSave.id}"
					return
			else
				callback topicToSave.errors

		updateTopicContent = => 
			filePath = @dataPath + '/blog.' + topicToSave.id + '.html'	
			fs.writeFile filePath, topicToSave.content, 'utf8', (err) -> 
				if err 
					callback "Topic #{topicToSave.id} content could not be saved. Error #{err}"
				else
					callback null, topicAllData

		if topicToSave? is false
			callback "No topic was received"
			return

		if topicToSave.id? is false
			callback "Topic Id is null" 
			return

		if @_isInt(topicToSave.id) is false
			callback "Topic Id is not an integer" 
			return			

		@_getAllTopicsMetaData(updateTopic)


	saveNewTopic: (topicToSave, callback) => 

		newTopic = null

		addTopic = (err, topics) =>
			callback err if err

			newTopic = new BlogTopic()
			newTopic.id = @nextId
			newTopic.createdOn = new Date()
			newTopic.update(topicToSave, true)
			if newTopic.isValid()
				@nextId = @nextId + 1
				topics.push newTopic
				@_saveTopicsMetaSync topics
				updateTopicContent()
			else
				callback newTopic.errors

		updateTopicContent = => 
			filePath = @dataPath + '/blog.' + newTopic.id + '.html'	
			fs.writeFile filePath, topicToSave.content, 'utf8', (err) -> 
				if err 
					callback "Topic #{newTopic.id} content could not be saved. Error #{err}"
				else
					callback null, newTopic

		@_getAllTopicsMetaData(addTopic)


exports.BlogModel = BlogModel

