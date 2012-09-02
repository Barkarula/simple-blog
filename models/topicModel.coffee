{TopicData}  = require './topicData'

class TopicModel
  
  @data = null

  constructor: (dataOptions) ->
    @data = new TopicData(dataOptions)


  _getUrlFromTitle: (title) ->
    url = title.toLowerCase()
    url = url.replace(/\s/g, "-")
    url = url.replace(/\./g, "-")
    url = url.replace(/\//g, "-")
    url = url.replace(/c#/g, "csharp")
    url = url.replace(/#/g, "-")
    url    


  _isValidDate: (date) ->
    return date instanceof Date && isFinite(date)


  _validate: (topic) ->
    valid = true
    errors = {
      emptyTitle: false
      emptySummary: false
      emptyContent: false
    }
    if topic?.meta?.title? is false or topic.meta.title is ""
      valid = false
      errors.emptyTitle = true
    if topic?.meta?.summary? is false or topic.meta.summary is ""
      valid = false
      errors.emptySummary = true
    if topic?.content? is false or topic.content is ""
      valid = false
      errors.emptyContent = true
    return if valid then null else errors


  getAll: (callback) =>
    @data.getAll callback


  getRecent: (callback) =>
    @data.getRecent callback


  getOne: (id, callback) =>
    @data.findMeta id, (err, meta) =>
      if err 
        callback err
      else
        @data.loadContent meta, callback


  getOneByUrl: (url, callback) =>
    @data.findMetaByUrl url, (err, meta) =>
      if err 
        callback err
      else
        @data.loadContent meta, callback


  getNew: =>
    return @data.getNew()


  # topic must be in the form 
  # {meta: {id: i, title: t, summary: s, ...}, content: c}
  # notice that we need an id
  save: (topic, callback) =>

    # Load the topic from the DB
    @data.findMeta topic.meta.id, (err, meta) => 

      if err
        callback err
      else
        # Merge the topic that we received with the one 
        # on the DB
        topic.meta.createdOn = meta.createdOn
        topic.meta.updatedOn = new Date()
        topic.meta.postedOn = if @_isValidDate(topic.meta.postedOn) then topic.meta.postedOn else new Date()
        topic.meta.url = @_getUrlFromTitle(topic.meta.title)

        # Is the topic valid?
        topic.errors = @_validate(topic)
        isTopicValid = topic.errors is null
        if isTopicValid
          # Update the meta data...
          @data.updateMeta topic.meta.id, topic.meta, (err, updatedMeta) =>
            if err
              callback err
            else  
              # ... and the content
              @data.updateContent updatedMeta, topic.content, callback
        else
          # topic has {meta: X, content: Y, errors: Z}
          callback null, topic


  # topic must be in the form 
  # {meta: {title: t, summary: s, ...}, content: c}
  # notice that we don't need an id
  saveNew: (topic, callback) => 
    # Fill in values required for new topics
    topic.meta.createdOn = new Date()
    topic.meta.updatedOn = new Date()
    topic.meta.postedOn = if @_isValidDate(topic.meta.postedOn) then topic.meta.postedOn else new Date()
    topic.meta.url = @_getUrlFromTitle(topic.meta.title)

    # Is the topic valid?
    topic.errors = @_validate(topic)
    isTopicValid = topic.errors is null
    if isTopicValid
      # Add topic to the database (meta+content)
      @data.addNew topic.meta, topic.content, callback
    else
        # topic has {meta: X, content: Y, errors: Z}
      callback null, topic


exports.TopicModel = TopicModel
