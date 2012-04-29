fs = require 'fs'
{BlogModel}  = require '../models/blog'


renderNotFound = (res, error) -> 
 	res.render '404', {status: 404, message: error}


renderError = (res, error) ->
	res.render '500', {status: 500, message: error}

requestToTopic = (req, url) ->
	topic = {
		id: parseInt(req.body.id)
		title: req.body.title
		url: url # todo: this value should be recalculated internally, right?
		summary: req.body.summary
		content: req.body.content
		postedOn: req.body.date
	}

view = (req, res) -> 

	dataPath = res.app.settings.datapath
	model = new BlogModel dataPath 
	url = req.params.url

	if url
		model.getTopicByUrl url, (err, topic) ->  
			if err
				renderNotFound res, err
			else
				res.render 'blog', topic
	else
		model.getAllTopics (err, topics) -> 
			if err
				renderError res, err
			else
				res.render 'blogs', {topics: topics}


edit = (req, res) -> 

	url = req.params.url
	if url is undefined
		console.log 'Edit without a URL was detected. Redirecting to blog list.'
		res.redirect '/blog'
		return

	dataPath = res.app.settings.datapath
	model = new BlogModel dataPath 
	model.getTopicByUrl url, (err, topic) -> 
		if err 
			renderNotFound res, err
		else 
			console.log topic
			res.render 'blogedit', topic


save = (req, res) -> 

	url = req.params.url
	if url is undefined
		console.log 'Save without a URL was detected. Redirecting to blog list.'
		res.redirect '/blog'
		return

	dataPath = res.app.settings.datapath
	topic = requestToTopic req, url
	if topic.id is NaN
  	renderError res, "Could not save topic #{url}. Invalid Id was detected."
  else
		model = new BlogModel dataPath 
		model.saveTopic topic, (err, data) ->  
		  if err
		  	console.log "saveTopic failed. Error: ", err
		  	renderError res, "Could not save topic #{url}. Error #{err}"
		  else
		  	res.redirect '/blog/'+ url


newBlog = (req, res) ->
	topic = {
		title: "Enter blog title"
		url: ""
		summary: ""
		content: ""
		postedOn: ""
	}
	res.render 'blognew', topic


add = (req, res) -> 

	topic = requestToTopic req, ""
	if isNaN topic.id
		dataPath = res.app.settings.datapath
		model = new BlogModel dataPath 
		model.saveNewTopic topic, (err, data) ->
			if err
				console.log "saveNewTopic failed. Error: ", err
				renderError res, "Could not add topic. Error #{err}"
			else
				console.log "New topic added. Topic: ", data
				res.redirect '/blog/'+ data.url
	else
		console.log "Unexpected id was found on new topic. Id: ", topic.id
		renderError res, "Could not save new topic."


module.exports = {
  view: view,
  edit: edit,
  save: save,
  newBlog: newBlog,
  add: add
}

