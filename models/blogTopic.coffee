class BlogTopic
	constructor: (title = "") ->
		@id = NaN
		@title = title
		@content = ""
		@createdOn = new Date()
		@updatedOn = new Date()
		@postedOn = new Date()
		@url = ""
		@errors = {}

	getUrl: (title) -> 
		cleanTitle = title.toLowerCase()
		cleanTitle = cleanTitle.replace(/\s/g, "-")
		cleanTitle = cleanTitle.replace(/\./g, "-")
		cleanTitle = cleanTitle.replace(/\//g, "-")
		cleanTitle = cleanTitle.replace(/#/g, "-")
		cleanTitle

	isValid: =>
		@errors = {}
		@errors.postedOn = "Invalid (or empty) Posted On date" if isNaN(Date.parse(@postedOn))
		@errors.title = "Title is null or empty" if @title.trim().length is 0 
		@errors.content = "Content is null or empty" if @content.trim().length is 0
		@errors.hasErrors = if @errors.postedOn or @errors.title or @errors.content then true else false
		return !@errors.hasErrors 

	setUrl: =>
		@url = @getUrl(@title)
		return

	update: (newData) =>
		#@id = don't change
		@title = newData.title
		@content = newData.content
		#@createdOn = don't change
		@updatedOn = new Date()
		@postedOn = newData.postedOn
		@url = @getUrl(newData.title)
		return  


exports.BlogTopic = BlogTopic
