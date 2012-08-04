blogRoutes = require './blogRoutes'
{TestUtil}  = require '../util/testUtil'

test = new TestUtil("blogRoutesTest", true)


getBasicApp = ->
  app: { settings: { datapath: "", isReadOnly: false } }


getBasicRequest = ->
  return getBasicApp()


getBasicResponse = ->
  return getBasicApp()


viewOneValid = ->
  req = getBasicRequest()
  req.params = { topicUrl: "topic-1" }

  res = getBasicResponse()
  res.render = (page, data) ->
    test.passIf page is "blogOne", "viewOneValid"

  blogRoutes.viewOne req, res


viewOneInvalid = ->
  req = getBasicRequest()
  req.params = { topicUrl: "topic-99" }

  res = getBasicResponse()
  res.render = (page, data) ->
    test.passIf page is "404", "viewOneInvalid"

  blogRoutes.viewOne req, res


viewRecent = ->
  req = getBasicRequest()
  res = getBasicResponse()
  res.render = (page, data) ->
    test.passIf page is "blogRecent", "viewRecent"
    #console.dir data

  blogRoutes.viewRecent req, res


viewAll = ->
  req = getBasicRequest()
  res = getBasicResponse()
  res.render = (page, data) ->
    test.passIf page is "blogAll", "viewAll"
    #console.dir data
    
  blogRoutes.viewAll req, res


editNoUrl = ->
  req = getBasicRequest()
  req.params = {}
  res = getBasicResponse()
  res.redirect = (redirUrl) ->
    test.passIf redirUrl is "/blog", "editNoUrl"
    
  blogRoutes.edit req, res


editBadUrl = ->
  req = getBasicRequest()
  req.params = {topicUrl: "topic-99"}

  res = getBasicResponse()
  res.render = (page, data) ->
    test.passIf page is "404", "editBadUrl"

  blogRoutes.edit req, res


editGoodUrl = ->
  req = getBasicRequest()
  req.params = {topicUrl: "topic-2"}

  res = getBasicResponse()
  res.render = (page, data) ->
    test.passIf page is "blogEdit", "editGoodUrl"

  blogRoutes.edit req, res


saveNoId = ->

  req = getBasicRequest()
  req.params = {}

  res = getBasicResponse()
  res.redirect = (redirUrl) ->
    test.passIf redirUrl is "/blog", "saveNoId"

  blogRoutes.save req, res


saveBadId = ->

  req = getBasicRequest()
  req.params = {id: "ABC"}
  req.body = {title: "t1", summary: "s1", content: "c1"}

  res = getBasicResponse()
  res.render = (page, data) ->
    test.passIf page is "500", "saveBadId"

  blogRoutes.save req, res


saveNonExistingId = ->

  req = getBasicRequest()
  req.params = {id: 99}
  req.body = {title: "t1", summary: "s1", content: "c1"}

  res = getBasicResponse()
  res.redirect = (url) ->
    console.log "redirect"
    test.passIf url is "/blog", "saveNonExistingId"

  blogRoutes.save req, res


saveNoBody = ->

  req = getBasicRequest()
  req.params = {id: 2}

  res = getBasicResponse()
  res.render = (page, data) ->
    test.passIf page is "blogEdit" and data.errors.emptyTitle, "saveNoBody"

  blogRoutes.save req, res


saveIncompleteData = ->

  req = getBasicRequest()
  req.params = {id: 2}
  req.body = {title: "", summary: "s1", content: ""}

  res = getBasicResponse()
  res.render = (page, data) ->
    test.passIf page is "blogEdit" and 
      data.errors.emptyTitle and 
      data.errors.emptyContent, "saveIncompleteBody"

  blogRoutes.save req, res


saveCompleteData = ->

  req = getBasicRequest()
  req.params = {id: 2}
  req.body = {title: "updated title 2", summary: "s1", content: "c2"}

  res = getBasicResponse()
  res.redirect = (url) ->
    test.passIf url is "/blog/updated-title-2", "saveCompleteData"
    console.log url
    
  blogRoutes.save req, res


# ------------------
viewOneValid()
viewOneInvalid()
viewRecent()
viewAll()

editNoUrl()
editBadUrl()
editGoodUrl()

saveNoId()
saveBadId()
saveNonExistingId()
saveNoBody()
saveIncompleteData()
saveCompleteData()

