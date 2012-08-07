{TopicData}  = require './topicData'

class TopicModel
  
  @data = null

  constructor: (dataPath) ->
    @data = new TopicData(dataPath)


  _getUrlFromTitle: (title) ->
    url = title.toLowerCase()
    url = url.replace(/\s/g, "-")
    url = url.replace(/\./g, "-")
    url = url.replace(/\//g, "-")
    url = url.replace(/c#/g, "csharp")
    url = url.replace(/#/g, "-")
    url    


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


  getAll: ->
    return @data.getAll()


  getRecent: ->
    return @data.getRecent()


  getOne: (id, callback) ->
    meta = @data.findMeta id
    if meta is null
      callback "Invalid ID #{id}"
    else
      @data.loadContent meta, callback


  getOneByUrl: (url, callback) ->
    meta = @data.findMetaByUrl url
    if meta is null
      callback "Invalid Url #{url}"
    else
      @data.loadContent meta, callback


  getNew: ->
    return @data.getNew()


  # topic must be in the form 
  # {meta: {id: i, title: t, summary: s, ...}, content: c}
  # notice that we need an id
  save: (topic, callback) =>

    # Load the topic from the DB
    meta = @data.findMeta topic.meta.id
    if meta is null
      callback "Could not find topic id #{topic.meta.id}" if meta is null
    else
      # Merge the topic that we received with the one 
      # on the DB
      topic.meta.createdOn = meta.createdOn
      topic.meta.updatedOn = new Date()
      topic.meta.url = @_getUrlFromTitle(topic.meta.title)

      # Is the topic valid?
      topic.errors = @_validate(topic)
      isTopicValid = topic.errors is null
      if isTopicValid
        # Update the database (meta+content)
        meta = @data.updateMeta topic.meta.id, topic.meta
        @data.updateContent meta, topic.content, callback
      else
        # topic has {meta: X, content: Y, errors: Z}
        callback topic


  # topic must be in the form 
  # {meta: {title: t, summary: s, ...}, content: c}
  # notice that we don't need an id
  saveNew: (topic, callback) -> 
    # Fill in values required for new topics
    topic.meta.createdOn = new Date()
    topic.meta.updatedOn = new Date()
    topic.meta.url = @_getUrlFromTitle(topic.meta.title)

    # Is the topic valid?
    topic.errors = @_validate(topic)
    isTopicValid = topic.errors is null
    if isTopicValid
      # Add topic to the database (meta+content)
      @data.addNew topic.meta, topic.content, callback
    else
        # topic has {meta: X, content: Y, errors: Z}
      callback topic


exports.TopicModel = TopicModel
