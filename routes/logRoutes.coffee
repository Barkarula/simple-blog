fs = require 'fs'
{Logger} = require '../util/logger'


_isValidLogDate = (text) -> 

  # Date must be in format YYYY-MM-DD and only years 20YY are valid.
  regEx = /20\d\d-\d\d-\d\d/
  match = text.match(regEx)
  return false if match is null

  # Date must match input string so that we don't have any extra characters
  # on the string. For example 2012-09-23XX is rejected.
  date = match[0]
  return false if date isnt text

  date = new Date(text)
  if date instanceof Date && isFinite(date)
    return true # yay!

  return false


viewCurrent = (req, res) ->  

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


viewSpecific = (req, res) ->  

  logDate = req.params.logDate
  if _isValidLogDate logDate
    logDate = logDate.replace(/-/g, '_')
    logFile = './logs/' + logDate + '.txt'
    fs.readFile logFile, (err, text) ->
      if err
        Logger.error "logRoutes.viewSpecific: Error reading log file #{logFile}\r\n#{err}"
        html = "<html><body>" 
        html += "<p>Could not read log file <b>#{logFile}</b></p>"
        html += "<p>#{err}</p>"
        html += "</body></html>"
        res.send html, 500
      else
        res.send text, { 'Content-Type': 'text/plain' }, 200
  else
    Logger.error "logRoutes.viewSpecific: Invalid log date received #{logDate}"
    res.redirect '/'


list = (req, res) ->
  # todo: implement code to view a list of log files

module.exports = {
  viewCurrent: viewCurrent
  viewSpecific: viewSpecific
}
