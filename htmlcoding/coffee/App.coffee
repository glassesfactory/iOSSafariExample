class App extends Backbone.Router
	routes: 
		'':'index' 
		'/':'index'
		':id':'show'
	gotFirstRequest:false
	status:'index'
	initialize:(options)->
		_.extend @, options

		@Main = new MainView()
		@Content = new ContentView()

	index:()->
		if @status is 'reverse'
			@Main.returnIndex()
		@status = 'index'
		return
	show:(id)->
		if @status is 'index'
			@Main.showContent(id)
		else
			@Content.render(id)
		return

head.js '/assets/js/views/MainView.js',
		'/assets/js/views/ContentView.js'
