{TopicData}  = require './topicData'
{TestUtil}  = require './testUtil'

d = new TopicData()
errors = []

errors.push "getAll" unless d.getAll().length > 0
errors.push "getRecent" unless d.getRecent().length > 0
errors.push "findMeta valid id" if d.findMeta(2) is null
errors.push "findMeta invalid id" if d.findMeta(9) isnt null

d.loadContent {id: 2}, (err, data) -> 
  errors.push "loadContent valid id (#{err})" if err isnt null

d.loadContent {id: 99}, (err, data) -> 
  errors.push "loadContent invalid id (#{err})" if err is null

newMeta = {
  title: "updated title 2",
  url: "updated-title-2",
  summary: "updated summary 2", 
}

updatedTopic = d.updateMeta 2, newMeta
if updatedTopic is null or updatedTopic.title isnt "updated title 2"
  errors.push "updateMeta valid id" 

updatedTopic = d.updateMeta 9, newMeta
errors.push "updateMeta in valid id" if updatedTopic isnt null

d.updateContent {id: 2}, "new content 2", (err, data) ->
  errors.push "updateContent valid id (#{err})" if err isnt null 

d.updateContent {id: 99}, "new content 99", (err, data) ->
  errors.push "updateContent invalid id" if err is null 

TestUtil.printTestResult "topicDataTest", errors

