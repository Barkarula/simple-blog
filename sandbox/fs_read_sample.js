var fs = require('fs');
var fileName = __dirname + '/test.txt';

// Create the test file (this is sync on purpose)
fs.writeFileSync(fileName, 'five guys named moe', 'utf8');

// Read async
fs.open(fileName, 'r', function(err, fd) {
	var content = new Buffer("123456789", "utf8");
	if(err) {
		console.log("Error opening file: ", err);		
	} else {
		console.log("Open returned fd: ", fd);
		fs.read(fd, content, 0, 9, 0, function(err, bytesRead, buffer) {
			if(err) {
				console.log("Error reading: ", err);
			} else {
				console.log("# of bytes read: ", bytesRead);
				console.log("bytes: ", buffer);
				console.log("string: [" + buffer.toString() + "]");
				fs.close(fd, function() {
					console.log("fd %d has been closed", fd);
				});
			}
		});
	}
});

