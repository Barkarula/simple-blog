var fs = require("fs"); 		// file system

// Blog "controller"  
index = function(req, res) {
	var viewModel = { xxx: 'Home Page'};
	res.render('index', viewModel);
}

about = function(req, res) {
	var viewModel = { yyy: 'About'};
	res.render('about', viewModel);
}

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

	// var viewModel = {
	// 	blogs: [ 
	// 		{id: 1, title:"AAA", summary:"aaa"}, 
	// 		{id: 2, title:"BBB", summary:"bbb"}, 
	// 		{id: 3, title:"CCC", summary:"ccc"}]
	// };
 //  res.render('blogs', viewModel);
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
	index: index,
	about: about,
  blog: blog
};
