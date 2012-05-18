head.ready ()->
		window.App = new App()
		Backbone.history.start({pushState:true})
		setTimeout(scrollTo, 100, 0, 1)
		return

head.js '/assets/js/libs/jquery.js',
		"/assets/js/libs/underscore.js",
		"/assets/js/libs/backbone.js",
		"/assets/js/App.js"