var fs = require("fs");
var model = require("../models/blog");

blog = function(req, res) {
	if (req.params.url == undefined) {

		model.getAllTopics(req, res, function(req, res, data) {
  		res.render('blogs', data);
		});

	} else {

		model.getTopicByUrl(req, res, function(req, res, data) { 
		  if(data.error) {
		  	// TODO: Call a generic utility for this
		  	res.render('404.jade', 
  				{ status: 404, message: data.error });
		  } else { 
		  	res.render('blog', data);
			}
		});

	}	
}

module.exports = {
  blog: blog
};
