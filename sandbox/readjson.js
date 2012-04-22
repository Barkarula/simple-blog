var fs = require('fs');
var file = __dirname + '/data.json';

var text = fs.readFileSync(file, 'utf8');
//console.log("TEXT: " + text);

var data = JSON.parse(text);
console.log("DATA");
console.log(data.blogs)
