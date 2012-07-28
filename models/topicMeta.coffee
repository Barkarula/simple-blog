class TopicMeta
  constructor: ->
    @id = NaN
    @title = ""
    @createdOn = new Date()
    @updatedOn = new Date()
    @postedOn = new Date()
    @url = ""
    @summary = ""

exports.TopicMeta = TopicMeta
