fs = require 'fs'
{TopicModel} = require '../models/topicModel'

console = {}
console.log = (x) ->
console.dir = (x) ->


renderNotFound = (res, error) -> 
	console.log "renderNotFound #{error}"
	res.render '404', {status: 404, message: error}


renderError = (res, error) ->
	console.log "renderError #{error}"
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
	topic = {
		meta: {
			id: parseInt(id)
			title: req.body?.title ? ""
			summary: req.body?.summary ? ""
			postedOn: new Date(req.body?.postedOn + ' ' + req.body?.postedAt)
		}
		content: req.body?.content ? ""
	}
	return topic


viewOne = (req, res) -> 

	dataOptions = res.app.settings.dataOptions
	model = new TopicModel dataOptions 
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

	dataOptions = res.app.settings.dataOptions
	model = new TopicModel dataOptions 

	model.getRecent (err, topics) -> 
		if err 
			renderError res, "Error getting recent topics"
		else if topics.length is 0
			renderError res, "No topics were found"
		else
			viewModel = viewModelForTopics topics, "Recent Blog Posts", req.app
			res.render 'blogRecent', viewModel


viewAll = (req, res) -> 
	console.log "blogRoutes:viewAll"

	dataOptions = res.app.settings.dataOptions
	model = new TopicModel dataOptions 

	model.getAll (err, topics) -> 
		if err 
			renderError res, "Error getting topics"
		else if topics.length is 0
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

	dataOptions = res.app.settings.dataOptions
	model = new TopicModel dataOptions 

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

	topic = requestToTopic req, id
	if isNaN(topic.meta.id)
		renderError res, "Invalid id #{id} detected on save."
	else
		dataOptions = res.app.settings.dataOptions
		model = new TopicModel dataOptions 
		model.save topic, (err, savedTopic) -> 
			if err
				# Unexpected error, send user to blogs main page
				console.log "Error while saving #{err}"
				res.redirect '/blog'
			else if typeof savedTopic.errors isnt 'undefined'
				# Validation error, send user to edit this topic
				res.render 'blogEdit', viewModelForTopic(savedTopic, req.app)
			else
				console.log "Saved, redirecting to /blog/#{savedTopic.meta.url}"
				res.redirect '/blog/'+ savedTopic.meta.url


editNew = (req, res) ->
	console.log "blogRoutes:editNew"
	dataOptions = res.app.settings.dataOptions
	model = new TopicModel dataOptions 
	topic = model.getNew()
	# console.dir viewModelForTopic(topic, req.app)
	res.render 'blogEdit', viewModelForTopic(topic, req.app)


saveNew = (req, res) -> 
	console.log "blogRoutes:saveNew"
	id = null
	topic = requestToTopic req, id
	dataOptions = res.app.settings.dataOptions
	model = new TopicModel dataOptions 

	model.saveNew topic, (err, savedTopic) ->
		if err
			# Unexpected error, send user to blogs main page
			console.log "Error while saving #{err}"
			res.redirect '/blog'
		else if typeof savedTopic.errors isnt 'undefined'
			# Validation error, send user to edit this topic
			# savedTopic is in the form {meta: X, content: Y, errors: Z}
			res.render 'blogEdit', viewModelForTopic(savedTopic, req.app)
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

