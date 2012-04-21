var fs = require("fs");
var model = require("../models/blog");

throwNotFoundException = function(res, error) {
 	res.render('404.jade', 
	{ status: 404, message: error });
}

renderAllTopics = function(req, res) {
	model.getAllTopics(req, res, function(req, res, topics) {
  	res.render('blogs', {topics: topics});
	});
}

blog = function(req, res) {

	if (req.params.url == undefined) {
		model.getAllTopics(req, function(topics) {
  		res.render('blogs', {topics: topics});
		});
	} else {
		model.getTopicByUrl(req, function(topic) { 
		  if(topic.error) {
				throwNotFoundException(res,data.error);
		  } else { 
		  	res.render('blog', topic);
			}
		});
	}	
}

edit = function(req, res) {
	if (req.params.url == undefined) {
		console.log('Edit without a URL was detected. Redirecting to blog list.');
		res.redirect('/blog');
	} else {
		model.getTopicByUrl(req, function(topic) { 
		  if(topic.error) {
				throwNotFoundException(res,topic.error);
		  } else { 
		  	res.render('blogedit', topic);
			}
		});
	}	
}

save = function(req, res) {
	if (req.params.url == undefined) {
		console.log('Save without a URL was detected. Redirecting to blog list.');
		res.redirect('/blog');
	} 
	else {
		console.log("Saving new content: " + req.body.content);

		model.saveTopicByUrl(req, res, function(data) { 
		  if(data.error) {
		  	throw "Could not save topic " + req.params.url;
		  } else { 
		  	res.redirect('/blog/'+ req.params.url);
			}
		});
	}
}

module.exports = {
  blog: blog,
  edit: edit,
  save: save
};
