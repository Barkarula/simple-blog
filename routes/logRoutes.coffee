fs = require 'fs'
{Logger} = require '../util/logger'

current = (req, res) ->  

  logFile = Logger.currentLogFile()
  fs.readFile logFile, (err, text) ->
    if err
      html = "<html><body>" 
      html += "<p>Could not read log file <b>#{logFile}</b></p>"
      html += "<p>#{err}</p>"
      html += "</body></html>"
      res.send html, 500
    else
      res.send text, { 'Content-Type': 'text/plain' }, 200

one = (req, res) -> 
  # todo: implement code to view one specific log file

list = (req, res) ->
  # todo: implement code to view a list of log files

module.exports = {
  current: current
}
