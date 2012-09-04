class Logger

  @_logLevel = 'INFO'


  @_pad: (number, zeroes) ->
    return ('000000' + number).slice(-zeroes)


  @_getTimestamp: ->
    now = new Date()

    day = now.getDay()
    month = now.getMonth()
    date = now.getFullYear() + '-' + @_pad(month, 2) + '-' + @_pad(day, 2) 
    
    hours = now.getHours()
    minutes = now.getMinutes()
    seconds = now.getMinutes()
    milliseconds = now.getMilliseconds()
    time = @_pad(hours, 2) + ':' + @_pad(minutes, 2) + ':' + @_pad(seconds, 2) + '.' + @_pad(milliseconds, 3)

    timestamp = date + ' ' + time
    return timestamp


  @_doLog: (level, text) ->
    console.log "#{@_getTimestamp()} #{level}: #{text}"


  @setLevel: (level) ->
    if level.toUpperCase() in ['INFO', 'WARN', 'ERROR', 'NONE']
      @_logLevel = level.toUpperCase()


  @info: (text) ->
    if @_logLevel is 'INFO'
      @_doLog 'INFO', text


  @warn: (text) ->
    if @_logLevel in ['INFO', 'WARN']
      @_doLog 'WARN', text


  @error: (text) ->
    if @_logLevel in ['INFO', 'WARN', 'ERROR']
      @_doLog 'ERROR', text


  @error: (text, exception = null) ->
    if @_logLevel in ['INFO', 'WARN', 'ERROR']
      text = text + "\r\n#{exception}" if exception?
      @_doLog 'ERROR', "#{text}"


exports.Logger = Logger

