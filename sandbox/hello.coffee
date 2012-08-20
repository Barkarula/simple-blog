test = (options) ->
  
  if typeof options is 'object'
    console.log "object"
    console.log options.dataPath ? "N/A"

    if options.createData is true
      console.log "createData"
    else
      console.log "don't create data"

  else 
    throw "Invalid options object received"


test({dataPath: "x", xxcreateData: true})