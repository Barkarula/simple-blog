{TopicModel}  = require './topicModel'
{TestUtil}  = require './testUtil'

ns = "topicModelTest" 

testGetUrlFromTitle = ->
  m = new TopicModel()
  errors = []

  errors.push "basic test" if m._getUrlFromTitle("hello") isnt "hello"
  errors.push "lowercase test" if m._getUrlFromTitle("hello-World") isnt "hello-world"
  errors.push "dots test" if m._getUrlFromTitle("hello-World.aspx") isnt "hello-world-aspx"
  errors.push "c# test" if m._getUrlFromTitle("hello-c#-World.aspx") isnt "hello-csharp-world-aspx"
  errors.push "pound (#) test" if m._getUrlFromTitle("this is #4") isnt "this-is--4"
  TestUtil.printTestResult "#{ns}.testGetUrlFromTitle", errors


testValidate = ->
  m = new TopicModel()
  errors = []

  goodTopic = {
    meta: {
      id: 1
      title: "hello world title"
      summary: "hello world summary"
    }
    content: "hello world content"
  }
  errors.push "good topic" if m._validate(goodTopic) isnt null

  emptyTopic = {}
  errors.push "empty topic" if m._validate(emptyTopic) is null

  emptyTitleTopic = { meta: { id: 1, summary: "s"}, content: "c" }
  errors.push "empty title" if m._validate(emptyTitleTopic) is null

  TestUtil.printTestResult "#{ns}.testValidate", errors


testGetters = ->
  m = new TopicModel()
  errors = []
  errors.push "getAll" unless m.getAll().length > 0
  errors.push "getRecent" unless m.getRecent().length > 0

  m.getOne 2, (err, data) ->
    if err isnt null 
      errors.push "getOne valid id (#{err})"
    else
      errors.push "getOne valid id (unexpected id returned)" if data.meta.id isnt 2

  m.getOne 99, (err, data) ->
    if err is null 
      errors.push "getOne invalid id"

  TestUtil.printTestResult "#{ns}.testGetters", errors


testSaveGoodTopic = ->
  m = new TopicModel()
  errors = []

  goodTopic = {
    meta: {
      id: 2
      title: "new title 2"
      summary: "new summary 2"
    }
    content: "updated content 2"
  }

  m.save goodTopic, (err, data) ->
    if err isnt null
      if typeof err is 'string'
        errorMsg = err 
      else
        errorMsg = JSON.stringify err, null, "\t"
      errors.push "#{errorMsg}" 
    else
      if data.meta.id isnt 2
        errors.push "Invalid id received after save"
      if data.meta.title isnt "new title 2"
        errors.push "Invalid title after save"
      if data.content isnt "updated content 2"
        errors.push "Invalid content after save"
      if data.meta.updatedOn? is false
        errors.push "Updated on not populated"
  
  TestUtil.printTestResult "#{ns}.testSaveGoodTopic", errors


testSaveBadTopic = ->
  m = new TopicModel()
  errors = []

  notExistingTopic = {meta: {id: 99}}
  m.save notExistingTopic, (err, data) ->
    if err is null
      errors.push "not existing topic"
    if typeof(err) isnt 'string'
      errors.push "unexpected error (#{err})"

  badData = {meta: {id: 2, title: ""}}
  m.save badData, (err, data) ->
    if err is null
      errors.push "not existing topic"
    if typeof(err) isnt 'object'
      errors.push "unexpected error (#{err})"

  TestUtil.printTestResult "#{ns}.testSaveBadTopic", errors

# -------------------
testGetUrlFromTitle()
testValidate()
testGetters()
testSaveGoodTopic()
testSaveBadTopic()










