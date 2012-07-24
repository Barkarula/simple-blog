fs = require 'fs'
{BlogModel} = require '../models/blogModel'
{BlogTopic} = require '../models/blogTopic'


renderNotFound = (res, error) -> 
	res.render '404', {status: 404, message: error}


renderError = (res, error) ->
	res.render '500', {status: 500, message: error}

topicsToMatrix = (topics, cols) ->
	rows = Math.ceil(topics.length / cols)
	matrix = new Array(rows)
	for r in [0..rows-1]
		matrix[r] = new Array(cols)
		for c in [0..cols-1]
			i = (r * cols) + c
			if i < topics.length
				matrix[r][c] = topics[i]
	matrix

requestToTopic = (req, id) ->
	topic = new BlogTopic(req.body.title)
	topic.id = parseInt(id)
	topic.summary = req.body.summary
	topic.content = req.body.content
	topic.postedOn = new Date(req.body.postedOn + ' ' + req.body.postedAt)
	return topic


viewOne = (req, res) -> 

	dataPath = res.app.settings.datapath
	model = new BlogModel dataPath 
	url = req.params.topicUrl
	console.log "blogRoutes:viewOne #{url}"

	if url
		model.getTopicByUrl url, (err, topic) ->  
			if err
				renderNotFound res, err
			else
				res.render 'blogOne', {
					topic: topic
					page:
						title: topic.title 
						isReadOnly: req.app.settings.isReadOnly
				}
	else
		# we shouldn't get here
		console.log "viewOne without a URL was detected"
		viewRecent()


viewRecent = (req, res) -> 
	console.log "blogRoutes:viewRecent"

	dataPath = res.app.settings.datapath
	model = new BlogModel dataPath 

	model.getRecentTopics (err, topics) -> 
		if err
			renderError res, err
		else
			matrix = topicsToMatrix(topics, 3)
			# console.log "Matrix"
			# console.dir matrix
			# console.log "------"
			res.render 'blogRecent', {
				topics: topics,
				matrix: matrix,
				page:
					title: "Recent Blog Posts" 
					isReadOnly: req.app.settings.isReadOnly
			}

viewAll = (req, res) -> 
	console.log "blogRoutes:viewAll"

	dataPath = res.app.settings.datapath
	model = new BlogModel dataPath 
	url = req.params.topicUrl

	model.getAllTopics (err, topics) -> 
		if err
			renderError res, err
		else
			res.render 'blogAll', {
				topics: topics
				page:
					title: "All Blog Posts" 
					isReadOnly: req.app.settings.isReadOnly
			}

edit = (req, res) -> 

	url = req.params.topicUrl
	if url is undefined
		console.log 'Edit without a URL was detected. Redirecting to blog list.'
		res.redirect '/blog'
		return
	console.log "blogRoutes:edit #{url}"

	dataPath = res.app.settings.datapath
	model = new BlogModel dataPath 
	model.getTopicByUrl url, (err, topic) -> 
		if err 
			renderNotFound res, err
		else 
			#console.log topic
			res.render 'blogEdit', topic


save = (req, res) -> 

	id = req.params.id
	if id is undefined
		console.log 'Save without an Id was detected. Redirecting to blog list.'
		res.redirect '/blog'
		return
	console.log "blogRoutes:save #{id}"

	dataPath = res.app.settings.datapath
	topic = requestToTopic req, id
	if topic.id is NaN
		renderError res, "Could not save topic #{id}. Invalid Id was detected."
	else
		model = new BlogModel dataPath 
		model.saveTopic topic, (err, savedTopic) -> 
			debugger 
			if err
				console.log "saveTopic failed. Error: ", err
				res.render 'blogEdit', topic
			else
				console.log "Saved, redirecting to /blog/#{savedTopic.url}"
				res.redirect '/blog/'+ savedTopic.url


# Edit a new blog
newBlog = (req, res) ->
	console.log "blogRoutes:newBlog"
	topic = new BlogTopic("Enter blog title")
	res.render 'blogEdit', topic


# Save a new blog (add it)
add = (req, res) -> 
	console.log "blogRoutes:add"
	topic = requestToTopic req
	if isNaN topic.id
		dataPath = res.app.settings.datapath
		model = new BlogModel dataPath 
		model.saveNewTopic topic, (err, data) ->
			debugger 
			if err
				console.log "saveNewTopic failed. Error: ", err
				renderError res, "Could not add topic. Error #{err}"
			else
				console.log "New topic added. Topic: ", data.url
				res.redirect '/blog/'+ data.url
	else
		console.log "Unexpected id was found on new topic. Id: ", topic.id
		renderError res, "Could not save new topic."


module.exports = {
	viewOne: viewOne,
	viewRecent: viewRecent,
	viewAll: viewAll,
	edit: edit,
	save: save,
	newBlog: newBlog,
	add: add
}

