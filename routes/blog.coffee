fs = require 'fs'
{BlogModel}  = require '../models/blog'


renderNotFound = (res, error) -> 
 	res.render '404', {status: 404, message: error}


renderError = (res, error) ->
	res.render '500', {status: 500, message: error}


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
	topic = {
		id: req.body.id
		title: req.body.title
		url: url
		summary: req.body.summary
		content: req.body.content
		postedOn: req.body.date
	}

	model = new BlogModel dataPath 
	# model.saveTopic topic, (err, data) ->  
	#   if err
	#   	renderError res, "Could not save topic #{url}. Error #{err}"
	#   else
	#   	res.redirect '/blog/'+ url
	content = req.body.content
	model.saveTopicByUrl url, content, (err, data) ->  
	  if err
	  	renderError res, "Could not save topic #{url}. Error #{err}"
	  else
	  	res.redirect '/blog/'+ url

module.exports = {
  view: view,
  edit: edit,
  save: save
}

