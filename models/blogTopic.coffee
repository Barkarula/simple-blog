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
		errors.push "Title is null or empty" if title? and @title.trim() 
		errors.push "Content is null or empty" if content? and @content.trim() 
		return errors

	isValid: =>
		return @getErrors.length is 0

	setUrl: =>
		@url = @getUrl(@title)
		return

exports.BlogTopic = BlogTopic
