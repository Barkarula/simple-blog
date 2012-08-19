{TopicData}  = require './topicData'
{TestUtil}  = require '../util/testUtil'

verbose = true
test = new TestUtil("topicDataTest", verbose)


badPath = __dirname + "/../badpath"
d = new TopicData(badPath)
d.getAll (err, topics) ->
  test.passIf err isnt null, "getAllWithInvalidPath"


dataPath = __dirname + "/../data"
d = new TopicData(dataPath)

d.getAll (err, topics) ->
  test.passIf err is null and topics.length > 0, "getAll"

d.getRecent (err, topics) ->
  test.passIf err is null and topics.length > 0, "getRecent"

d.findMeta 2, (err, topic) ->
  test.passIf topic isnt null, "findMeta valid id"

d.findMeta -9, (err, topic) ->
  test.passIf err isnt null, "findMeta invalid id"

d.getRecent (err, topics) ->
  urlToTest = topics[1].url
  d.findMetaByUrl urlToTest, (err, topic) ->
    test.passIf topic.url is urlToTest, "findMetaByUrl valid url"

d.findMetaByUrl 'topic-not-existing', (err, topic) ->
  test.passIf topic is null, "findMetaByUrl invalid url"

d.loadContent {id: 2}, (err, data) -> 
  test.passIf err is null, "loadContent valid id"

d.loadContent {id: -9}, (err, data) -> 
  test.passIf err isnt null, "loadContent invalid id"

newMeta = {
  title: "updated title 2",
  url: "updated-title-2",
  summary: "updated summary 2", 
}

d.updateMeta 2, newMeta, (err, topic) ->
  test.passIf topic.title is newMeta.title, "updateMeta valid id" 

d.updateMeta -9, newMeta, (err, topic) ->
  test.passIf topic is null, "updateMeta invalid id" 

d.updateContent {id: 2}, "new content 2", (err, data) ->
  test.passIf err is null, "updateContent valid id"

# Since topicData does not validate the ID the
# following unit test will actually create a text
# file "blog.-9.html" so we better don't run it :)
#
# d.updateContent {id: -9}, "new content 99", (err, data) ->
#   test.passIf err isnt null, "updateContent invalid id" 
# ----

newTopic = {
  title: 'new title',
  url: 'new-title',
  summary: 'new summary',
  createdOn: new Date(),
  updatedOn: new Date(),
  postedOn: new Date()
}

d.addNew newTopic, "new content", (err, newTopic)->
  if err
    test.fail "addNew (#{err})"
  else
    d.findMeta newTopic.meta.id, (err, topic) ->
      if err 
        test.fail "addNew (#{err})"
      else
        test.passIf topic.title is "new title", "addNew"


