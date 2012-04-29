// In this example, the first call to readFile gets empty
// content. It seems that the first read is getting mixed
// up with the writeFile because they run in different 
// threads. 
// 
// Node.js hands off the I/O to the operating system and 
// evidently the readFile is not keeping a lock on the file
// and it's getting partial data (no data in our case.)
//
// This question in Stack Overflow has more information on this:
// 	http://stackoverflow.com/questions/10368806/node-js-readfile-woes
//

var fs = require('fs');
var fileName = __dirname + '/test.txt';

// Create the test file (this is sync on purpose)
fs.writeFileSync(fileName, 'initial test text', 'utf8');


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


// Write async
fs.writeFile(fileName, 'updated text', 'utf8', function(err) {
	var msg = "";
	if(err)
		console.log("write finished with error: ", err);
	else
		console.log("write finished OK");
});


// // Read async
// fs.readFile(fileName, 'utf8', function(err, data) {
// 	var msg = "";
// 	if(err)
// 		console.log("second read returned error: ", err);
// 	else
// 		if (data === null) 
// 			console.log("second read returned NULL data!");
// 		else if (data === "") 
// 			console.log("second read returned EMPTY data!");
// 		else
// 			console.log("second read returned data: ", data);
// });


console.log("Done.");