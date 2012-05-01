home = (req, res) ->  
	viewModel = { xxx: 'Home Page'}
	res.render 'home', viewModel

about = (req, res) -> 
	viewModel = { yyy: 'About'}
	res.render 'about', viewModel

notFound = (req, res) ->
  res.render '404.jade', { status: 404, message: 'Page not found' }

module.exports = {
	home: home,
	about: about,
	notFound: notFound
}
