var fs = require("fs");
var model = require("../models/blog");

throwNotFoundException = function(res, error) {
 	res.render('404.jade', 
	{ status: 404, message: error });
}

renderAllTopics = function(req, res) {
	model.getAllTopics(req, res, function(req, res, data) {
  	res.render('blogs', data);
	});
}

blog = function(req, res) {

	if (req.params.url == undefined) {
		renderAllTopics(req, res);
	} else {
		model.getTopicByUrl(req, res, function(req, res, data) { 
		  if(data.error) {
				throwNotFoundException(res,data.error);
		  } else { 
		  	res.render('blog', data);
			}
		});
	}	
}

edit = function(req, res) {
	if (req.params.url == undefined) {
		renderAllTopics(req, res);
	} else {
		model.getTopicByUrl(req, res, function(req, res, data) { 
		  if(data.error) {
				throwNotFoundException(res,data.error);
		  } else { 
		  	res.render('blogedit', data);
			}
		});
	}	
}

save = function(req, res) {
	if (req.params.url == undefined) {
		renderAllTopics(req, res);
	} 
	else {
		console.log("Saving new content: " + req.body.content);

		model.saveTopicByUrl(req, res, function(req, res, data) { 
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
