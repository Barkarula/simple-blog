var fs = require("fs");

_getAllTopics = function(dataPath) {
	var filePath = dataPath + '/blogs.json';
	console.log("SYNC Reading list of topics: " + filePath);

	var text = fs.readFileSync(filePath, 'utf8');
	var data = JSON.parse(text);
	var topics = data.blogs;
	return topics;
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

getAllTopics = function(req) {
	return _getAllTopics(req.app.settings.datapath);
}












getTopicByUrl = function(req) {
	var dataPath = req.app.settings.datapath;
	var url = req.params.url;
	var topics, topic, data, text, filePath;
	console.log("SYNC getTopicByUrl: " + url);

 	topics = _getAllTopics(req.app.settings.datapath);

	topic = _findTopicInListByUrlSync(topics, url);
	if (topic == null) {
		data = { error: "Topic not found" };
	}
	else {
		filePath = dataPath + '/blog.' + topic.id + '.html';
		text = fs.readFileSync(filePath, 'utf8');
		if (text == null) {
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
	}

	return data;
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

