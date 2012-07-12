class BlogTopic
	constructor: (title = "") ->
		@id = NaN
		@title = title
		@content = ""
		@createdOn = ""
		@updatedOn = ""
		@postedOn = ""
		@url = ""

	getUrl: (title) -> 
		title.toLowerCase().replace(/\s/g, "-")

	getErrors: =>
		errors = []
		errors.push "Title is null or empty" if @title.trim().length is 0 
		errors.push "Content is null or empty" if @content.trim().length is 0
		return errors

	isValid: =>
		return @getErrors().length is 0

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
