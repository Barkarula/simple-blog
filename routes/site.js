home = function(req, res) {
	var viewModel = { xxx: 'Home Page'};
	res.render('home', viewModel);
}

about = function(req, res) {
	var viewModel = { yyy: 'About'};
	res.render('about', viewModel);
}

notFound = function(req, res) {
  res.render('404.jade', 
  	{ status: 404, message: 'Page not found' });
}

module.exports = {
	home: home,
	about: about,
	notFound: notFound
};