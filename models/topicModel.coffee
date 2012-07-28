{TopicData}  = require './topicData'

class TopicModel

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
    data = new TopicData()
    return data.getAll()


  getRecent: ->
    data = new TopicData()
    return data.getRecent()


  getOne: (id, callback) ->
    data = new TopicData()
    meta = data.findMeta id
    if meta is null
      callback "Invalid ID #{id}"
    else
      data.loadContent meta, callback


  save: (topic, callback) ->
    data = new TopicData()

    # Load the topic from the DB
    meta = data.findMeta topic.meta.id
    if meta is null
      callback "could not find topic id #{topic.meta.id}" if meta is null
    else
      # Merge the topic that we received with the one 
      # on the DB
      topic.meta.createdOn = meta.createdOn
      topic.meta.updatedOn = new Date()
      topic.meta.url = @_getUrlFromTitle(meta.title)

      # Is the topic valid?
      topic.errors = @_validate(topic)
      isTopicValid = topic.errors is null
      if isTopicValid
        # Update the database (meta+content)
        meta = data.updateMeta topic.meta.id, topic.meta
        data.updateContent meta, topic.content, callback
      else
        # should this be callback {meta: X, content: Y, errors: Z}
        callback topic.errors

exports.TopicModel = TopicModel
