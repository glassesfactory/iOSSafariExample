class ContentView extends Backbone.View
	el:'#reverse'
	templates:_.template '<div class="content"><header><h1><%= title %></h1></header><section class="contentBody"><%= content %></section><div class="back"><a href="/"><img src="assets/images/back.png" width="207" height="45"></a></div><footer><img src="assets/images/copyright.png" width="320" height="16"></footer></div>'
	loading:'<div class="preloader"><img src="/assets/images/ajax-loader.gif" width="16" height="16"/></div>'
	events:
		'click .back a':'returnIndex'

	initialize:(options)->
		_.bindAll @
		_.extend @, options

	render:(id)->
		@$el.empty().html @loading
		@model =  new ExpModel()
		@model.url = id
		@model.fetch { success:@contentLoadedHandler }

		return

	returnIndex:(event)->
		event.preventDefault()
		@$el.empty()
		window.App.Main.returnIndex()
		
		return false
	contentLoadedHandler:(data)->
		$('.preloader').delay(400).fadeOut(300, @dispContent)
	dispContent:()->
		@$el.empty().html(@templates(@model.toJSON()))
		return

head.js '/assets/js/ExpModel.js'