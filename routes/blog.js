var fs = require("fs");

blog = function(req, res) {
	if (req.params.id == undefined) {
		blogAllTopics(req, res);
	} else {
		blogSingleTopic(req, res);
	}	
}

blogAllTopics = function(req, res) {

  var dataPath = res.app.settings.datapath;
	var filePath = dataPath + '/blogs.json';
	console.log("Reading list of topics: " + filePath);

	fs.readFile(filePath, 'utf8', function(err, text){

		if(err != undefined)
		{
			console.log(err);
		}

  	var viewModel = JSON.parse(text);
	  res.render('blogs', viewModel);
	});

}

blogSingleTopic = function(req, res) {

	var id = req.params.id; //TODO: Force to number
  var dataPath = res.app.settings.datapath;
	var filePath = dataPath + '/blog.' + id + '.html';
	console.log("Reading file: " + filePath);

	fs.readFile(filePath, 'utf8', function(err, text){
		if(err != undefined)
		{
			// TODO: redirect to topic not found
			console.log(err);
			text = "<p>topic not found</p>";
		}
  	var viewModel = { 
			title: 'blog topic' + req.params.id,
			content: text,
			postedOn: "April 3rd, 2012"
		};
	  res.render('blog', viewModel);
	});
  
}

module.exports = {
  blog: blog
};
