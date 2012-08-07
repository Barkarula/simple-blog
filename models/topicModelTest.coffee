{TopicModel}  = require './topicModel'
{TestUtil}  = require '../util/testUtil'

verbose = true
dataPath = __dirname + "/../data"

testGetUrlFromTitle = ->
  m = new TopicModel(dataPath)
  test = new TestUtil("topicModelTest.testGetUrlFromTitle", verbose)

  test.passIf m._getUrlFromTitle("hello") is "hello", "basic test"
  test.passIf m._getUrlFromTitle("hello-World") is "hello-world", "lowercase test"
  test.passIf m._getUrlFromTitle("hello-World.aspx") is "hello-world-aspx", "dots test"
  test.passIf m._getUrlFromTitle("hello-c#-World.aspx") is "hello-csharp-world-aspx", "c# test"
  test.passIf m._getUrlFromTitle("this is #4") is "this-is--4", "pound (#) test"


testValidate = ->
  m = new TopicModel(dataPath)
  test = new TestUtil("topicModelTest.testValidate", verbose)

  goodTopic = {
    meta: {
      id: 1
      title: "hello world title"
      summary: "hello world summary"
    }
    content: "hello world content"
  }

  test.passIf m._validate(goodTopic) is null, "good topic" 

  emptyTopic = {}
  test.passIf m._validate(emptyTopic) isnt null, "empty topic" 

  emptyTitleTopic = { meta: { id: 1, summary: "s"}, content: "c" }
  errors = m._validate(emptyTitleTopic)
  test.passIf errors.emptyTitle is true, "empty title"


testGetters = ->
  m = new TopicModel(dataPath)
  test = new TestUtil("topicModelTest.testGetters", verbose)

  test.passIf m.getAll().length > 0, "getAll"
  test.passIf m.getRecent().length > 0, "getRecent"

  m.getOne 2, (err, data) ->
    test.passIf data.meta.id is 2, "getOne valid id"

  m.getOne 99, (err, data) ->
    test.passIf err isnt null, "getOne invalid id"

  topics = m.getAll()
  m.getOneByUrl topics[0].url, (err, data) ->
    test.passIf data.meta.url is topics[0].url, "getOneByUrl valid id"

  m.getOneByUrl 'topic-99', (err, data) ->
    test.passIf err isnt null, "getOneByUrl invalid id"


testSaveGoodTopic = ->
  m = new TopicModel(dataPath)
  test = new TestUtil("topicModelTest.testSaveGoodTopic", verbose)

  goodTopic = {
    meta: {
      id: 2
      title: "new title 2"
      summary: "new summary 2"
    }
    content: "updated content 2"
  }

  m.save goodTopic, (err, data) ->
    if err
      console.dir err
      test.fail "goodTopic"
    else
      errors = []
      if data.meta.id isnt 2
        errors.push "Invalid id received after save"
      if data.meta.title isnt "new title 2"
        errors.push "Invalid title after save"
      if data.content isnt "updated content 2"
        errors.push "Invalid content after save"
      if data.meta.updatedOn? is false
        errors.push "Updated on not populated"
    
      test.passIf errors.length is 0, "goodTopic"
      if errors.length > 0
        console.dir errors


testSaveBadTopic = ->
  m = new TopicModel(dataPath)
  test = new TestUtil("topicModelTest.testSaveBadTopic", verbose)

  notExistingTopic = {meta: {id: 99}}
  m.save notExistingTopic, (err, data) ->
    test.passIf err isnt null, "not existing topic"

  badData = {meta: {id: 2, title: ""}}
  m.save badData, (err, data) ->
    test.passIf err isnt null, "empty title"


testSaveNewTopic = ->
  m = new TopicModel(dataPath)
  test = new TestUtil("topicModelTest.testSaveNewTopic", verbose)

  newTopic = {
    meta: {
      title: "new test topic",
      summary: "new summary for test topic"
    }
    content: "new content for test topic"
  }

  m.saveNew newTopic, (err, data) ->
    if err
      test.fail "unexpected error #{err}" 
    else 
      m.getOne data.meta.id, (err, data) ->
        if err isnt null
          test.fail "error retrieving new record id: #{data.meta.id} #{err}"
        else
          test.pass "new topic"


# -------------------
testGetUrlFromTitle()
testValidate()
testGetters()
testSaveGoodTopic()
testSaveBadTopic()
testSaveNewTopic()










