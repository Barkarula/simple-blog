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
// easily pass stubs/mock objects when unit
// testing this code, right?
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

// getTopicById = function(req, res, next) {

// 	var id = req.params.id; //TODO: Force to number
//   var dataPath = res.app.settings.datapath;
// 	var filePath = dataPath + '/blog.' + id + '.html';
// 	var data;
// 	console.log("Reading file: " + filePath);

// 	fs.readFile(filePath, 'utf8', function(err, text){
// 		if(err != undefined)
// 		{
// 			data = { error: "Topic not found" };
// 			console.log(err);
// 		} else {
//   		data = { 
// 				title: 'blog topic' + req.params.id,
// 				content: text,
// 				postedOn: "April 3rd, 2012"
// 			};
// 		}

// 		next(req, res, data);
// 	});
  
// }

findTopicInListByUrl = function(topics, url) {
	var topic = null;

	for(i=0; i<topics.length; i++) {
		if (topics[i].url == url) {
			console.log("Model: topic found in dictionary")
			topic = { 
				id: topics[i].id,
				title: topics[i].title, 
				content: "", // needs to be read from disk
				postedOn: topics[i].postedOn,
				url: topics[i].url };
			break;
		}
	}

	return topic;	
}

getTopicByUrl = function(req, res, next) {

	var url = req.params.url; 
	var emptyTopic = { id: 0, title: "empty", content: "empty", postedOn: "empty" };

	console.log("URL: " + url);

	getAllTopics(req, res, function(req, res, allTopics) {
		var topic, data, dataPath, filePath;

	 	topic = findTopicInListByUrl(allTopics.blogs, url); // synch operation
		if(topic == null)
		{
			data = { error: "Topic not found" };
			next(req, res, data);
		}
		else {

			// read the content for the specific topic
		  dataPath = res.app.settings.datapath;
			filePath = dataPath + '/blog.' + topic.id + '.html';
			console.log("Reading file: " + filePath);
			
			fs.readFile(filePath, 'utf8', function(err, text){
				if(err != undefined)
				{
					data = { error: "Topic content not found" };
					console.log(err);
				} else {
		  		data = { 
						title: topic.title,
						content: text,
						postedOn: topic.postedOn,
						url: topic.url
					};
				}
				// do whatever we need to do with the topic
				// now that we've got all the data for it
				next(req, res, data);
			});
		}

	});
  
}

saveTopicByUrl = function(req, res, next) {

	var url = req.params.url; 
	console.log("Model: saving URL: " + url);

	getAllTopics(req, res, function(req, res, allTopics) {
		var topic, data, dataPath, filePath;

	 	topic = findTopicInListByUrl(allTopics.blogs, url); // synch operation
		if(topic == null)
		{
			data = { error: "Topic not found" };
			next(req, res, data);
		}
		else {

			// read the content for the specific topic
		  dataPath = res.app.settings.datapath;
			filePath = dataPath + '/blog.' + topic.id + '.html';
			console.log("Model: rewriting file: " + filePath);
			console.log("Model: content: " + req.body.content);
			
			fs.writeFile(filePath, req.body.content, 'utf8', function(err){
				if(err != undefined)
				{
					data = { error: "Topic content could not be saved" };
					console.log(err);
				} else {
					console.log("Model: file was rewritten");
		  		data = { 
						title: topic.title,
						content: req.params.content,
						postedOn: topic.postedOn,
						url: topic.url
					};
				}
				// do whatever we need to do with the topic
				// now that we've got all the data for it
				next(req, res, data);
			});
		}

	});

}

module.exports = {
  getAllTopics: getAllTopics,
  getTopicByUrl: getTopicByUrl,
  saveTopicByUrl: saveTopicByUrl
};
