fs = require 'fs'
{TopicModel} = require '../models/topicModel'
{TopicMeta} = require '../models/topicMeta'

# console = {}
# console.log = (x) ->
# console.dir = (x) ->


renderNotFound = (res, error) -> 
	#console.log "renderNotFound #{error}"
	res.render '404', {status: 404, message: error}


renderError = (res, error) ->
	#console.log "renderError #{error}"
	res.render '500', {status: 500, message: error}


viewModelForTopic = (topic, app) ->
	{ 
		topic: topic
		page:
			title: topic?.meta?.title 
			isReadOnly: app.settings.isReadOnly
	}


viewModelForTopics = (topics, title, app) ->
	{
		matrix: topicsToMatrix(topics, 3),
		page:
			title: title 
			isReadOnly: app.settings.isReadOnly
	}


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
	topic = {}
	topic.meta = new TopicMeta()
	topic.meta.id = parseInt(id)
	topic.meta.title = req.body?.title ? ""
	topic.meta.summary = req.body?.summary ? ""
	topic.meta.postedOn = new Date(req.body?.postedOn + ' ' + req.body?.postedAt)
	topic.content = req.body?.content ? ""
	# console.dir topic
	return topic


viewOne = (req, res) -> 

	dataPath = res.app.settings.datapath
	model = new TopicModel dataPath 
	url = req.params.topicUrl
	console.log "blogRoutes:viewOne #{url}"

	if url
		model.getOneByUrl url, (err, topic) ->  
			if err
				renderNotFound res, err
			else
				res.render 'blogOne', viewModelForTopic(topic, req.app)
	else
		# we shouldn't get here
		console.log "viewOne without a URL was detected"
		viewRecent()


viewRecent = (req, res) -> 
	console.log "blogRoutes:viewRecent"

	dataPath = res.app.settings.datapath
	model = new TopicModel dataPath 

	topics = model.getRecent()
	if topics.length is 0
		renderError res, "No topics were found"
	else
		viewModel = viewModelForTopics topics, "Recent Blog Posts", req.app
		res.render 'blogRecent', viewModel


viewAll = (req, res) -> 
	console.log "blogRoutes:viewAll"

	dataPath = res.app.settings.datapath
	model = new TopicModel dataPath 
	topics = model.getAll()

	if topics.length is 0
		renderError res, "No topics were found"
	else
		viewModel = viewModelForTopics topics, "All Blog Posts", req.app
		res.render 'blogAll', viewModel


edit = (req, res) -> 

	url = req.params.topicUrl
	if url is undefined
		console.log 'Edit without a URL was detected. Redirecting to blog list.'
		res.redirect '/blog'
		return
	console.log "blogRoutes:edit #{url}"

	dataPath = res.app.settings.datapath
	model = new TopicModel dataPath 
	model.getOneByUrl url, (err, topic) -> 
		if err 
			renderNotFound res, err
		else 
			res.render 'blogEdit', viewModelForTopic(topic, req.app)


save = (req, res) -> 

	id = req.params.id
	if id is undefined
		console.log 'Save without an Id was detected. Redirecting to blog list.'
		res.redirect '/blog'
		return
	console.log "blogRoutes:save #{id}"

	dataPath = res.app.settings.datapath
	topic = requestToTopic req, id
	if isNaN(topic.meta.id)
		renderError res, "Invalid id #{id} detected on save."
	else
		model = new TopicModel dataPath 
		model.save topic, (err, savedTopic) -> 
			if err
				if typeof(err) is 'string' && err.indexOf("Could not find topic id") is 0
					# this should never happen, but if it does is 
					# either a bug or a hacker
					console.log "WTF? Id not found while saving."
					res.redirect '/blog'
				else if typeof(err) is 'object'
					# err has {meta: X, content: Y, errors: Z}
					console.log "saveTopic failed."
					console.dir err
					res.render 'blogEdit', viewModelForTopic(err, req.app)
				else
					console.log "WTF? Whacky error while saving"
					console.dir err
					res.redirect '/blog'
			else
				console.log "Saved, redirecting to /blog/#{savedTopic.meta.url}"
				res.redirect '/blog/'+ savedTopic.meta.url


editNew = (req, res) ->
	console.log "blogRoutes:editNew"
	dataPath = res.app.settings.datapath
	model = new TopicModel dataPath 
	topic = model.getNew()
	console.dir viewModelForTopic(topic, req.app)
	res.render 'blogEdit', viewModelForTopic(topic, req.app)


saveNew = (req, res) -> 
	console.log "blogRoutes:saveNew"
	id = null
	topic = requestToTopic req, id
	dataPath = res.app.settings.datapath
	model = new TopicModel dataPath 
	model.saveNew topic, (err, savedTopic) ->
		if err
			# err has {meta: X, content: Y, errors: Z}
			console.log "saveNewTopic failed."
			console.dir err
			res.render 'blogEdit', viewModelForTopic(err, req.app)
		else
			console.log "New topic added, redirecting to /blog/#{savedTopic.meta.url}"
			res.redirect '/blog/'+ savedTopic.meta.url


module.exports = {
	viewOne: viewOne,
	viewRecent: viewRecent,
	viewAll: viewAll,
	edit: edit,
	save: save,
	editNew: editNew,
	saveNew: saveNew
}

