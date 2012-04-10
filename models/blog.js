var fs = require("fs");

// I don't quite like the fact that the model
// is aware of the request and response objects
// but we'll deal with that later.
//
// Hum...it also depends on the app object. 
// Does not smell good.
// 
// Since JavaScript is not statically typed
// this might not be a big deal, we could 
// easily pass stubs/mock objects, right?
//

getAllTopics = function(req, res, next) {

  var dataPath = res.app.settings.datapath;
	var filePath = dataPath + '/blogs.json';
	console.log("Reading list of topics: " + filePath);

	fs.readFile(filePath, 'utf8', function(err, text){
		var data = {};
		if(err != undefined)
		{
			console.log(err);
		}
		else
		{
  		data = JSON.parse(text);
  	}
	  next(req, res, data);
	});

}

getTopicById = function(req, res, next) {

	var id = req.params.id; //TODO: Force to number
  var dataPath = res.app.settings.datapath;
	var filePath = dataPath + '/blog.' + id + '.html';
	var data;
	console.log("Reading file: " + filePath);

	fs.readFile(filePath, 'utf8', function(err, text){
		if(err != undefined)
		{
			data = { error: "Topic not found" };
			console.log(err);
		} else {
  		data = { 
				title: 'blog topic' + req.params.id,
				content: text,
				postedOn: "April 3rd, 2012"
			};
		}

		next(req, res, data);
	});
  
}

module.exports = {
  getAllTopics: getAllTopics,
  getTopicById: getTopicById
};
