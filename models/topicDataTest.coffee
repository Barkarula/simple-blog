{TopicData}  = require './topicData'
{TestUtil}  = require '../util/testUtil'

test = new TestUtil("topicDataTest")
d = new TopicData()

test.passIf d.getAll().length > 0, "getAll"
test.passIf d.getRecent().length > 0, "getRecent"
test.passIf d.findMeta(2) isnt null, "findMeta valid id"
test.passIf d.findMeta(9) is null, "findMeta invalid id"

test.passIf d.findMetaByUrl('topic-2') isnt null, "findMetaByUrl valid url"
test.passIf d.findMetaByUrl('topic-9') is null, "findMetaByUrl invalid url"

d.loadContent {id: 2}, (err, data) -> 
  test.passIf err is null, "loadContent valid id"

d.loadContent {id: 99}, (err, data) -> 
  test.passIf err isnt null, "loadContent invalid id"

newMeta = {
  title: "updated title 2",
  url: "updated-title-2",
  summary: "updated summary 2", 
}

updatedTopic = d.updateMeta 2, newMeta
test.passIf updatedTopic.title is newMeta.title, "updateMeta valid id" 

updatedTopic = d.updateMeta 9, newMeta
test.passIf updatedTopic is null, "updateMeta invalid id" 

d.updateContent {id: 2}, "new content 2", (err, data) ->
  test.passIf err is null, "updateContent valid id"

d.updateContent {id: 99}, "new content 99", (err, data) ->
  test.passIf err isnt null, "updateContent invalid id" 

newTopic = {
  title: "new title",
  url: "new-title",
  summary: "new summary"
}

d.addNew newTopic, "new content", (err, data)->
  if data.meta.id is 4
    test.passIf d.findMeta(4).title is "new title", "addNew"
  else
    test.fail "addNew (bad id returned)"


