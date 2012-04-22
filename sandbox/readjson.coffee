fs = require 'fs'
file = __dirname + '/data.json'

text = fs.readFileSync file, 'utf8'
#console.log "TEXT: #{text}"

data = JSON.parse text
console.log "DATA"
console.log data.blogs
