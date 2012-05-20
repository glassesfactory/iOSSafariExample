class MainView extends Backbone.View
	el:'#main'
	useTapHold:true
	holdTimer:null
	isCanFlip:false
	isBeginOpen:false
	isOpened:false
	_currentLeft:0
	_moveX:0
	_tmpX:0

	swipeStart:null
	swipeStop:null
	_swipeDirection:false
	SCROLL_CANCEL_DURATION_THRESHOLD: 1000
	SWIPE_FORCE_OPEN_THRESHOLD: 30
	SWIPE_DISPATCHE_HORIZONTAL_THRESHOLD: 120
	SWIPE_DISPATCHE_VERTICAL_THRESHOLD: 75

	events:
		'click nav li a':'navClickedHandler'
	
	initialize:(options)->
		_.bindAll @
		_.extend @, options
		@win = window
		@container = $('#container')
		@reverse = $('#reverse')

		@container.bind 'touchstart', @touchStart
		if @useTapHold
			@container.bind 'touchhold', @touchHoldHandler
		return true

	navClickedHandler:(event)->
		event.preventDefault()
		@win.App.status = 'reverse'
		id = event.currentTarget.href.replace(@win.App.HOST_NAME, '')
		@showContent(id)
		return false

	showContent:(id)->
		@targetID = id
		@container.css '-webkit-animation-name':'flipToReverse'
		@reverse.css '-webkit-animation-name': 'flipToChange'
		@container.bind 'webkitAnimationEnd', @flipedTimerHandler

	touchStart:(event)->
		data = event.originalEvent
		@swipeStart = {
			time:(new Date()).getTime()
			pos:[data.touches[0].pageX, data.touches[0].pageY]
			origin:$(data.target)
		}

		@_tmpX = data.touches[0].pageX
	
		@container.bind('touchmove', @judgeSwipeStartHandler).one('touchend', @touchEndHandler)
		@holdTimer = setInterval @holdTimerHandler, 550

		if @isOpened
			event.preventDefault()
		

	touchHoldHandler:(event)->
		@container.bind 'touchmove', @touchMoveHandler
		@isCanFlip = true

	judgeSwipeStartHandler:(event)->
		data = event.originalEvent
		@swipeStop = {
			time:(new Date()).getTime()
			pos:[data.touches[0].pageX, data.touches[0].pageY]
		}

		if Math.abs( @swipeStart.pos[0] - @swipeStop.pos[0]) >  @SWIPE_DISPATCHE_HORIZONTAL_THRESHOLD
			event.preventDefault()

		if Math.abs( @_tmpX - @swipeStop.pos[0]) > @SWIPE_FORCE_OPEN_THRESHOLD && Math.abs( @swipeStart.pos[1] - @swipeStop.pos[1] ) < @SWIPE_DISPATCHE_VERTICAL_THRESHOLD && not @isOpened
			event.preventDefault()
			if @swipeStart.pos[0] > @swipeStop.pos[0]
				#ひだりっかわのやつあける
				@_swipeDirection = 'LEFT'
				$('#slideRight').empty()
				$('#slideLeft').empty().html('SLIDE RIGHT')
				@doForceOpenLeftPanel()
			else
				#みぎっかわのやつあける
				@_swipeDirection = 'RIGHT'
				$('#slideLeft').empty()
				$('#slideRight').empty().html('SLIDE LEFT')
				@doForceOpenRightPanel()
			@unbindHandlers()
			return
		@_tmpX = @swipeStop.pos[0]

	touchEndHandler:(event)->
		@isCanFlip = false
		@isBeginOpen = false

		@unbindHandlers()

		@_currentLeft = parseInt(@container.css('left').replace 'px', '')
		#
		if @_currentLeft is NaN
			@_currentLeft = 0
		
		if @isOpened
			@doClose()
		else
			if Math.abs(@_moveX) > 10
				if @_swipeDirection is 'RIGHT'
					if @_currentLeft < 100
						@doClose()
					else
						@container.css '-webkit-animation-name':'SlideLeft'
						@container.bind 'webkitAnimationEnd', @panelOpenedHandler
				else if @_swipeDirection is 'LEFT'
					if @_currentLeft > -100
						@doClose()
					else
						@container.css '-webkit-animation-name':'SlideRight'
						@container.bind 'webkitAnimationEnd', @panelOpenedHandler
		return

	###
	長押し状態中に動かせる
	###
	touchMoveHandler:(event)->
		data = event.originalEvent
		event.preventDefault()
		if @isCanFlip
			@isBeginOpen = true
			@_moveX = data.touches[0].pageX - @swipeStart.pos[0]
			tmpX = @_currentLeft + @_moveX

			if tmpX < 0
				@_swipeDirection = 'LEFT'
				$('#slideRight').empty()
				$('#slideLeft').empty().html('SLIDE RIGHT')
			else
				@_swipeDirection = 'RIGHT'
				$('#slideLeft').empty()
				$('#slideRight').empty().html('SLIDE LEFT')

			if tmpX > 280
				tmpX = 280
			else if tmpX < -280
				tmpX = -280
			@container.css
				left: tmpX
			
		return

	###
	長押し判定
	###
	holdTimerHandler:()->
		clearInterval @holdTimer
		@container.trigger 'touchhold'
		return

	unbindHandlers:()->
		@container.unbind 'touchmove', @touchMoveHandler
		@container.unbind 'touchmove', @judgeSwipeStartHandler
		@container.unbind 'touchend', @touchEndHandler
		@isCanFlip = false


	doForceOpenRightPanel:()->
		@unbindHandlers()
		@container.css '-webkit-animation-name':'SlideLeft'
		@container.bind 'webkitAnimationEnd', @panelOpenedHandler
	
	doForceOpenLeftPanel:()->
		@unbindHandlers()
		@container.css '-webkit-animation-name':'SlideRight'
		@container.bind 'webkitAnimationEnd', @panelOpenedHandler

	doClose:()->
		@container.css '-webkit-animation-name':'SlideReturn'
		@container.bind 'webkitAnimationEnd', @panelClosedHandler

	panelClosedHandler:(event)->
		@unbindHandlers()
		@container.unbind 'webkitAnimationEnd', @panelClosedHandler
		@isOpened = false
		@_setLeftClose()
		$('#slideLeft').empty()
		$('#slideRight').empty()

	panelOpenedHandler:(event)->
		@container.unbind 'webkitAnimationEnd', @panelOpenedHandler
		@unbindHandlers()
		@isOpened = true
		@_setOpenPos()

	returnIndex:()->
		@container.css '-webkit-animation-name':'flipToIndex'
		@reverse.css '-webkit-animation-name': 'flipToBack'
		@container.bind 'webkitAnimationEnd', @flipedBackHandler

	flipedTimerHandler:()->
		@container.unbind 'webkitAnimationEnd', @flipedTimerHandler
		@_setFliped()
		if @win.App.status is 'index'
			@win.App.status = 'reverse'
			@win.App.show(@targetID)
		else
			@win.App.navigate('/'+ @targetID, true)

	flipedBackHandler:()->
		@container.unbind 'webkitAnimationEnd', @flipedBackHandler
		@_setDef()
		@win.App.navigate("", true)

	_setFliped:()->
		@container.css '-webkit-transform':'rotateY(180deg)', '-webkit-animation-name':''
		@reverse.css '-webkit-transform':'rotateY(0deg)', '-webkit-animation-name':''

	_setDef:()->
		@container.css '-webkit-transform':'rotateY(0deg)', '-webkit-animation-name':''
		@reverse.css '-webkit-transform':'rotateY(180deg)', '-webkit-animation-name':''

	_setOpenPos:()->
		pos = if @_swipeDirection is 'LEFT' then -280 else 280
		@_currentLeft = pos
		@container.css 'left': pos, '-webkit-animation-name':''

	_setLeftClose:()->
		@_currentLeft = 0
		@_moveX = 0
		@_tmpX = 0
		@_swipeDirection = 'STOP'
		@container.css 'left':0, '-webkit-animation-name':''