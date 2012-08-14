{TopicData}  = require './topicData'
{TestUtil}  = require '../util/testUtil'

verbose = true
test = new TestUtil("topicDataTest", verbose)

dataPath = __dirname + "/../data"
d = new TopicData(dataPath)

test.passIf d.getAll().length > 0, "getAll"
test.passIf d.getRecent().length > 0, "getRecent"

topic2 = d.findMeta(2) 
test.passIf topic2 isnt null, "findMeta valid id"
test.passIf d.findMeta(-9) is null, "findMeta invalid id"

test.passIf d.findMetaByUrl(topic2.url) isnt null, "findMetaByUrl valid url"
test.passIf d.findMetaByUrl('topic-not-existing') is null, "findMetaByUrl invalid url"

d.loadContent {id: 2}, (err, data) -> 
  test.passIf err is null, "loadContent valid id"

d.loadContent {id: -9}, (err, data) -> 
  test.passIf err isnt null, "loadContent invalid id"

newMeta = {
  title: "updated title 2",
  url: "updated-title-2",
  summary: "updated summary 2", 
}

updatedTopic = d.updateMeta 2, newMeta
test.passIf updatedTopic.title is newMeta.title, "updateMeta valid id" 

updatedTopic = d.updateMeta -9, newMeta
test.passIf updatedTopic is null, "updateMeta invalid id" 

d.updateContent {id: 2}, "new content 2", (err, data) ->
  test.passIf err is null, "updateContent valid id"

# Since topicData does not validate the ID
# the following unit test will actually create
# a text file "blog.-9.html"
# d.updateContent {id: -9}, "new content 99", (err, data) ->
#   test.passIf err isnt null, "updateContent invalid id" 

newTopic = {
  title: 'new title',
  url: 'new-title',
  summary: 'new summary',
  createdOn: new Date(),
  updatedOn: new Date(),
  postedOn: new Date()
}

d.addNew newTopic, "new content", (err, data)->
  if err
    test.fail "addNew (#{err})"
  else
    meta = d.findMeta(data.meta.id)
    if meta is null
      test.fail "addNew (new topic #{data.meta.id} not found)"
    else
      test.passIf meta.title is "new title", "addNew"


