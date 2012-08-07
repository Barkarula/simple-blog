fs = require 'fs'
{TopicMeta}  = require './topicMeta'

# This class handles saving and retrieving of topic
# data. Notice that this class does NOT perform any
# validation, it trusts that the caller passes only
# good data. 

class TopicData

  constructor: (@dataPath) ->
    @blogListFilePath = "#{dataPath}/blogs.json"
    @nextId = null
  

  # TODO: _loadAll should be async
  _loadAll: =>
    text = fs.readFileSync @blogListFilePath, 'utf8'
    data = JSON.parse text
    @nextId = data.nextId

    topics = []
    for topic in data.blogs
      meta = new TopicMeta()
      meta.id = topic.id
      meta.title = topic.title
      meta.url = topic.url
      meta.summary = topic.summary
      meta.createdOn = new Date(topic.createdOn)
      meta.updatedOn = new Date(topic.updatedOn)
      meta.postedOn = new Date(topic.postedOn)
      topics.push meta

    # sort by date descending
    topics.sort (x, y) ->
      return -1 if x.postedOn > y.postedOn
      return 1 if x.postedOn < y.postedOn
      return 0

    return topics


  _saveMetaToDisk: (topics) =>
    jsonText = JSON.stringify topics, null, "\t"
    jsonText = '{ "nextId": ' + @nextId + ', "blogs":' + jsonText + '}'
    fs.writeFileSync @blogListFilePath, jsonText, 'utf8'      


  getAll: =>
    return @_loadAll()


  getRecent: =>
    howMany = 10
    topics = @_loadAll()
    if topics.length > howMany
      topics = topics.slice(0, howMany) 
    return topics


  getNew: =>
    meta = new TopicMeta()
    return {meta: meta, content: ""}


  findMeta: (id) =>
    topics = @_loadAll()
    for topic in topics
      if topic.id is id
        return topic
    return null


  findMetaByUrl: (url) =>
    topics = @_loadAll()
    for topic in topics
      if topic.url is url
        return topic
    return null


  loadContent: (meta, callback) => 
    filePath = @dataPath + '/blog.' + meta.id + '.html'  
    fs.readFile filePath, 'utf8', (err, text) ->
      if err 
        callback "Could not retrieve content for id #{meta.id}"
      else
        callback null, {meta: meta, content: text}


  updateMeta: (id, newMeta) =>
    topics = @_loadAll()
    for i in [0..topics.length-1]
      if topics[i].id is id
        # Update the meta data...
        topics[i].title = newMeta.title
        topics[i].url = newMeta.url
        topics[i].summary = newMeta.summary
        topics[i].createdOn = newMeta.createdOn
        topics[i].updatedOn = newMeta.updatedOn
        topics[i].postedOn = newMeta.postedOn
        @_saveMetaToDisk topics
        return topics[i]
    return null


  updateContent: (meta, content, callback) =>
    filePath = @dataPath + '/blog.' + meta.id + '.html'  
    fs.writeFile filePath, content, 'utf8', (err) -> 
      if err 
        callback "Content for topic #{meta.id} could not be saved. Error #{err}"
      else
        callback null, {meta: meta, content: content}


  addNew: (meta, content, callback) =>
    topics = @_loadAll() 
    meta.id = @nextId 
    topics.push meta
    @nextId++
    @_saveMetaToDisk topics
    @updateContent meta, content, callback


exports.TopicData = TopicData
