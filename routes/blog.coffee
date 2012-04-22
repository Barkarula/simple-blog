fs = require 'fs'
{BlogModel}  = require '../models/blog'


throwNotFoundException = (res, error) -> 
 	res.render '404.jade', {status: 404, message: error}


blog = (req, res) -> 
	dataPath = res.app.settings.datapath
	url = req.params.url
	model = new BlogModel(dataPath)
	if url is undefined
		model.getAllTopics (topics) -> 
  		res.render 'blogs', {topics: topics}
	else
		model.getTopicByUrl url, (topic) ->  
			if topic.error isnt undefined
				throwNotFoundException res, topic.error
			else
				res.render 'blog', topic

edit = (req, res) -> 
	url = req.params.url
	if url is undefined
		console.log 'Edit without a URL was detected. Redirecting to blog list.'
		res.redirect '/blog'
		return

	dataPath = res.app.settings.datapath
	model = new BlogModel(dataPath)
	model.getTopicByUrl url, (topic) -> 
		if topic.error isnt undefined
			throwNotFoundException res, topic.error
		else 
			res.render 'blogedit', topic


save = (req, res) -> 
	url = req.params.url
	if url is undefined
		console.log 'Save without a URL was detected. Redirecting to blog list.'
		res.redirect '/blog'
		return

	dataPath = res.app.settings.datapath
	model = new BlogModel(dataPath)
	model.saveTopicByUrl url, req.body.content, (data) ->  
	  if data.error isnt undefined
	  	throw "Could not save topic #{url}"
	  else
	  	res.redirect '/blog/'+ url


module.exports = {
  blog: blog,
  edit: edit,
  save: save
}

