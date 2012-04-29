// A variation of file_io_problem.js but in this case 
// writing the update to the text file using the SYNC 
// version to prevent the async read from picking up 
// an empty or partial file. 

var fs = require('fs');
var fileName = __dirname + '/test.txt';

// Create the test file (this is sync on purpose)
fs.writeFileSync(fileName, 'initial test text', 'utf8');
 

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


// Read async
fs.readFile(fileName, 'utf8', function(err, data) {
	var msg = "";
	if(err)
		console.log("second read returned error: ", err);
	else
		if (data === null) 
			console.log("second read returned NULL data!");
		else if (data === "") 
			console.log("second read returned EMPTY data!");
		else
			console.log("second read returned data: ", data);
});

// Write SYNC
fs.writeFileSync(fileName, 'updated text', 'utf8');


// Read async
fs.readFile(fileName, 'utf8', function(err, data) {
	var msg = "";
	if(err)
		console.log("third read returned error: ", err);
	else
		if (data === null) 
			console.log("third read returned NULL data!");
		else if (data === "") 
			console.log("third read returned EMPTY data!");
		else
			console.log("third read returned data: ", data);
});




