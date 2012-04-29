// An unfishined attempt writing to a temp file and then
// renaming to the original file to prevent empty/partial
// readings. 
writeFileSafeSync = function(fileName, content, encoding) {
	var randomExt = Math.random().toString(36).substring(7);
	var tempName = fileName + "." + randomExt;
	fs.writeFileSync(tempName, content, encoding);
	fs.renameSync(tempName, fileName);
}

var fs = require('fs');
var fileName = __dirname + '/test.txt';

// Create the test file (this is sync on purpose)
//writeFileSafeSync(fileName, 'initial test text', 'utf8');
//fs.writeFileSync(fileName, 'initial test text', 'utf8');

console.log("Starting...");

// Read async
fs.readFile(fileName, 'utf8', function(err, data) {
	var msg = "";
	if(err)
		console.log("first read returned error: ", err);
	else {
		if (data === null) 
			console.log("first read returned NULL data!");
		else if (data === "") 
			console.log("first read returned EMPTY data!");
		else
			console.log("first read returned data: ", data);
	}
});

// // Write async
// fs.writeFile(fileName, 'updated text', 'utf8', function(err) {
// 	var msg = "";
// 	if(err)
// 		console.log("write finished with error: ", err);
// 	else
// 		console.log("write finished OK");
// });

fs.writeFileSync(fileName, 'updated text', 'utf8');

console.log("Done.");