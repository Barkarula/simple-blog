var fs = require("fs");

_getAllTopics = function(dataPath, next) {
	var filePath = dataPath + '/blogs.json';
	console.log("ASYNC Reading list of topics: " + filePath);

	fs.readFile(filePath, 'utf8', function(err, text) {
		var data, topics;
		if(err == undefined)
		{
  		data = JSON.parse(text);
  		topics = data.blogs;
  	}
	  next(topics);
	});
}

_findTopicInListByUrlSync = function(topics, url) {
	var topic = null;

	for(i=0; i<topics.length; i++) {
		if (topics[i].url == url) {
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

// ===================================
// Public Methods 
// ===================================

getAllTopics = function(req, callback) {
	_getAllTopics(req.app.settings.datapath, function(topics) {
		callback(topics);
	});
}

getTopicByUrl = function(req, callback) {
	var dataPath = req.app.settings.datapath;
	var url = req.params.url;
	var topic = null;
	console.log("ASYNC getTopicByUrl: " + url);

	getTopicDetailsCallback = function(topics) {
		var filePath, data;
	 	topic = _findTopicInListByUrlSync(topics, url); 
		if (topic == null) {
			data = { error: "Topic not found" };
			callback(data);
		}
		else {
			filePath = dataPath + '/blog.' + topic.id + '.html';			
			fs.readFile(filePath, 'utf8', function(err, text){
				if (err != undefined) {
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
				callback(data);
			});
		}
	}

	_getAllTopics(dataPath, getTopicDetailsCallback);
}







saveTopicByUrl = function(req, res, next) {
	var url = req.params.url; 
	var dataPath = res.app.settings.datapath;
	console.log("Model: saving URL: " + url);

	getTopicDetailsCallback = function(topics) {
		var data;
	 	var topic = _findTopicInListByUrlSync(topics, url); 
		if(topic == null)
		{
			data = { error: "Topic not found" };
			next(req, res, data);
		}
		else {
			updateTopicContent(topic.id, req.body.content);
		}
	}

	updateTopicContent = function(id, newContent) {
		var filePath = dataPath + '/blog.' + id + '.html';
		console.log("Model: rewriting file: " + filePath);
		
		fs.writeFile(filePath, newContent, 'utf8', function(err) {
			if(err != undefined)
			{
				data = { error: "Topic content could not be saved" };
				console.log(err);
			} else {
				console.log("Model: file was rewritten");
				data = {};
			}
			next(data);
		});
	}

	_getAllTopics(dataPath, getTopicDetailsCallback);
}

module.exports = {
  getAllTopics: getAllTopics,
  getTopicByUrl: getTopicByUrl,
  saveTopicByUrl: saveTopicByUrl
};

