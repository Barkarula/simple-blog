{TopicMeta}  = require './topicMeta'

class TopicData

  @topics = null
  @contents = null

  constructor: ->
    @topics = []
    @contents = []
  

  _loadAll: =>
    if @topics.length is 0
      for i in [1..3]
        t = new TopicMeta()
        t.id = i
        t.title = "topic #{i}"
        t.url = "topic-#{i}"
        t.summary = "topic #{i} summary"
        t.createdOn = new Date("Jan #{i}, 2012")
        t.updatedOn = new Date("Feb #{i}, 2012")
        t.postedOn = new Date("March #{i}, 2012")
        @topics.push t
        @contents.push "content for topic #{i}"
    @topics


  getAll: =>
    return @_loadAll()


  getRecent: =>
    return @_loadAll().slice(0,2)


  findMeta: (id) =>
    topics = @_loadAll()
    for t in topics
      if t.id is id
        return t
    return null


  loadContent: (meta, callback) => 
    content = @contents[meta.id-1]
    if content
      callback null, {meta: meta, content: content}
    else 
      callback "Invalid ID #{meta.id}"


  updateMeta: (id, newMeta) =>
    t = @findMeta(id)
    return null if t is null 
    t.title = newMeta.title
    t.url = newMeta.url
    t.summary = newMeta.summary
    t.createdOn = newMeta.createdOn
    t.updatedOn = newMeta.updatedOn
    t.postedOn = newMeta.postedOn
    return t


  updateContent: (meta, content, callback) =>
    if meta.id? and meta.id in [1..3]
      @contents[meta.id] = content
      callback null, {meta: meta, content: content}
    else
      callback "Invalid id #{meta.id}"

exports.TopicData = TopicData
