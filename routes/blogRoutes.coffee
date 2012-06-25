fs = require 'fs'
{BlogModel}  = require '../models/blogModel'
{BlogTopic}  = require '../models/blogTopic'


renderNotFound = (res, error) -> 
 	res.render '404', {status: 404, message: error}


renderError = (res, error) ->
	res.render '500', {status: 500, message: error}


requestToTopic = (req) ->
	topic = new BlogTopic(req.body.title)
	topic.id = parseInt(req.body.id)
	topic.summary = req.body.summary
	topic.content = req.body.content
	topic.postedOn = new Date(req.body.postedOn + ' ' + req.body.postedAt)
	return topic


view = (req, res) -> 
	console.log "blogRoutes:view"

	dataPath = res.app.settings.datapath
	model = new BlogModel dataPath 
	url = req.params.url

	if url
		model.getTopicByUrl url, (err, topic) ->  
			if err
				renderNotFound res, err
			else
				res.render 'blog', topic
				#res.render 'simple.ejs', { layout: true, name: "hector" }
				# res.render 'simple.html', {name: 'hector'}
				#res.render 'simple.md'
				# res.send '<html><body><b>bold and simple</b></body></html>'
	else
		model.getAllTopics (err, topics) -> 
			if err
				renderError res, err
			else
				res.render 'blogs', {topics: topics}


edit = (req, res) -> 
	console.log "blogRoutes:edit"

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
			#console.log topic
			res.render 'blogedit', topic


save = (req, res) -> 
	console.log "blogRoutes:save"

	url = req.params.url
	if url is undefined
		console.log 'Save without a URL was detected. Redirecting to blog list.'
		res.redirect '/blog'
		return

	dataPath = res.app.settings.datapath
	topic = requestToTopic req
	if topic.id is NaN
  	renderError res, "Could not save topic #{url}. Invalid Id was detected."
  else
		model = new BlogModel dataPath 
		model.saveTopic topic, (err, data) ->  
		  if err
		  	console.log "saveTopic failed. Error: ", err
		  	renderError res, "Could not save topic #{url}. Error #{err}"
		  else
		  	res.redirect '/blog/'+ data.url


newBlog = (req, res) ->
	console.log "blogRoutes:newBlog"
	topic = new BlogTopic("Enter blog title")
	res.render 'blognew', topic


add = (req, res) -> 
	console.log "blogRoutes:add"
	topic = requestToTopic req
	if isNaN topic.id
		dataPath = res.app.settings.datapath
		model = new BlogModel dataPath 
		model.saveNewTopic topic, (err, data) ->
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
  view: view,
  edit: edit,
  save: save,
  newBlog: newBlog,
  add: add
}

