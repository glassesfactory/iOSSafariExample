class App extends Backbone.Router
	routes: 
		'':'index' 
		'/':'index'
		':id':'show'
	gotFirstRequest:false
	status:'index'
	initialize:(options)->
		_.extend @, options
		# @HOST_NAME = 
		loc = window.location.href
		if loc.match(/https:\/\//i)
			@HOST_NAME = 'https://' + loc.replace(/https:\/\//,'').split('/')[0]
		else
			@HOST_NAME = 'http://' + loc.replace(/http:\/\//,'').split('/')[0]
		
		@clientHeight =  document.documentElement.clientHeight + 15
		$('#wrapper').css
			'height':@clientHeight
			'overflow-y':'hidden'
		$('.panel').css
			'height':@clientHeight
			'overflow-y':'hidden'
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
