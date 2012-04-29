var fs = require('fs');
var fileName = __dirname + '/test.txt';

// Create the test file (this is sync on purpose)
fs.writeFileSync(fileName, 'initial test text', 'utf8');


console.log("Starting...");

// Read async
fs.open(fileName, 'r', function(err, fd) {
	var content = new Buffer("          ", "utf8");
	if(err)
		console.log("reading/error opening file: ", err);
	else {
		console.log("reading/open returned fd: ", fd);
		//fs.read(fd, buffer, offset, length, position, [callback])
		fs.read(fd, content, 0, 5, 0, function(err, bytesRead, buffer) {
			console.log("reading/done reading, bytes:", bytesRead, " buffer: ", buffer);
			console.log("read: ", buffer.toString());
			fs.close(fd, function() {
				console.log("the fd has been closed: ", fd)
			});

		});
	}
});

// // Ready async
// fs.readFile(fileName, 'utf8', function(err, data) {
// 	var msg = "";
// 	if(err)
// 		console.log("first read returned error: ", err);
// 	else {
// 		if (data === null) 
// 			console.log("first read returned NULL data!");
// 		else if (data === "") 
// 			console.log("first read returned EMPTY data!");
// 		else
// 			console.log("first read returned data: ", data);
// 	}
// });

// Write file async
fs.open(fileName, 'w', function(err, fd){
	var newText = new Buffer("the updated text", "utf8");
	if(err)
		console.log("error opening file for writing: ", err);
	else {
		console.log("open for writing returned fd: ", fd);
		fs.write(fd, newText, 0, newText.length, 0, function(err, written, buffer) {

			if(err)
				console.log("error writing to file: ", err);
			else {
				console.log("# of bytes written: ", written);
				fs.fsync(fd, function(){
					console.log("the fd has been flushed", fd);
					fs.close(fd, function() {
						console.log("the fd has been closed: ", fd)
					});
				});
			}

		});
	}
});

fs.writeFileSync(fileName, "updated text", "utf8");



console.log("Done.");