home = function(req, res) {
	var viewModel = { xxx: 'Home Page'};
	res.render('home', viewModel);
}

about = function(req, res) {
	var viewModel = { yyy: 'About'};
	res.render('about', viewModel);
}

module.exports = {
	home: home,
	about: about
};