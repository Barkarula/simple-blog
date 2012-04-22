fs = require 'fs'
model = require '../models/blog'


throwNotFoundException = (res, error) -> 
 	res.render '404.jade', {status: 404, message: error}


renderAllTopics = (req, res) -> 
	model.getAllTopics req, res, (req, res, topics) -> 
  	res.render 'blogs', {topics: topics}


blog = (req, res) -> 
	if req.params.url is undefined
		model.getAllTopics req, (topics) -> 
  		res.render 'blogs', {topics: topics}
	else
		model.getTopicByUrl req, (topic) ->  
			if topic.error isnt undefined
				throwNotFoundException res, topic.error
			else
				res.render 'blog', topic


edit = (req, res) -> 
	if req.params.url is undefined
		console.log 'Edit without a URL was detected. Redirecting to blog list.'
		res.redirect '/blog'
	else
		model.getTopicByUrl req, (topic) -> 
			if topic.error isnt undefined
				throwNotFoundException res, topic.error
			else 
				res.render 'blogedit', topic


save = (req, res) -> 
	if req.params.url is undefined
		console.log 'Save without a URL was detected. Redirecting to blog list.'
		res.redirect '/blog'
	else
		console.log "Saving new content: " + req.body.content
		model.saveTopicByUrl req, res, (data) ->  
		  if data.error isnt undefined
		  	throw "Could not save topic #{req.params.url}"
		  else
		  	res.redirect '/blog/'+ req.params.url


module.exports = {
  blog: blog,
  edit: edit,
  save: save
}

