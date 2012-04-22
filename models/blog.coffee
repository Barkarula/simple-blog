fs = require 'fs'

_getAllTopics = (dataPath, next) ->
	filePath = "#{dataPath}/blogs.json"
	console.log "ASYNC Reading list of topics: #{filePath}"

	fs.readFile filePath, 'utf8', (err, text) ->
		topics = null
		if err is null
  		data = JSON.parse text
  		#console.log "DATA"
  		#console.log data
  		topics = data.blogs
  	else 
  		console.log "Error reading topic list #{err}" 
	  next topics


_findTopicInListByUrlSync = (topics, url) ->
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

	console.log "Topic in list: #{topic.title}"

	return topic

# ===================================
# Public Methods 
# ===================================

getAllTopics = (req, callback) -> 
	_getAllTopics req.app.settings.datapath, (topics) -> 
		callback topics


getTopicByUrl = (req, callback) ->
	
	dataPath = req.app.settings.datapath
	url = req.params.url
	topic = null
	console.log "ASYNC getTopicByUrl: #{url}"

	getTopicDetailsCallback = (topics) -> 
		console.log "Inside getTopicDetailsCallback"
		topic = _findTopicInListByUrlSync topics, url
		if topic is null
			console.log "topic is null!!??"
			dataNotFound = { error: "Topic not found" }
			callback dataNotFound 
		else
			filePath = "#{dataPath}/blog.#{topic.id}.html"	
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
				console.log "data="
				console.dir data
				callback data

	_getAllTopics(dataPath, getTopicDetailsCallback) 


saveTopicByUrl = (req, res, next) -> 
	url = req.params.url
	dataPath = res.app.settings.datapath
	console.log "Model: saving URL: #{url}"

	getTopicDetailsCallback = (topics) -> 
		topic = _findTopicInListByUrlSync topics, url 
		if topic is null
			data = { error: "Topic not found" }
			console.log "#{data.error}"
			next req, res, data
		else
			updateTopicContent topic.id, req.body.content

	updateTopicContent = (id, newContent) -> 
		filePath = "#{dataPath}/blog.#{id}.html"
		console.log "Model: rewriting file #{filePath}"
		
		fs.writeFile filePath, newContent, 'utf8', (err) -> 
			if err isnt null
				data = { error: "Topic content could not be saved" }
				console.log err
			else
				console.log "Model: file was rewritten"
				data = {}
			next data 

	_getAllTopics(dataPath, getTopicDetailsCallback)


module.exports = {
  getAllTopics: getAllTopics,
  getTopicByUrl: getTopicByUrl,
  saveTopicByUrl: saveTopicByUrl
}

