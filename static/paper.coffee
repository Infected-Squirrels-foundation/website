$(->
	# run code again and agagin
	window.interpret =
		_.debounce ->
				if  $('textarea').val().length % 10 == 0
					$('.stdout').html 'loading...' 
					$.post  '/interpret',
						code:$('textarea').val(),
						(res)-> $('.stdout').html(res)
				else
					$('.stdout').html "wrong input length (need #{10 - $('textarea').val().length % 10} more)"
		, 500

	window.go = ->
		line_width = $('.width_template').width();
		editor_height = $('textarea').height()
		$('textarea').hide()
		$('.buttons').hide()
		$('.stdout').hide()
		val = $('textarea').val()

		$('<div class=\"paper\"></div>')
			.appendTo('.paper_wrap')
			.css('min-height': editor_height)
			.text(val)

		setTimeout(->
			$('.paper').css(width:line_width)
				.afterTrans 500, ->
					val = val.replace(/(\d{2})(\d{3})/g,'$1:$2');
					val = val.replace(/1/g,'●');
					val = val.replace(/0/g,'&nbsp;');
					$('.paper').html(val)
						.css
							background: 'url(/static/paper_fibers.png)'
							'line-height': '.6em'
					$('.paper_wrap').css(top: -($('.paper_wrap').height()+$('.paper_wrap').offset().top*1.1))
						.afterTrans window.save
		, 500)

	window.save = ->
		$.post '/save',
			code:$('textarea').val(),
			(id)-> 
				window.history?.pushState(0, 0, id)
				$("<h1><a href=\"/#{id}\">/#{id}</a></h1>")
					.appendTo('.workspace')
		true
		
	$.fn.afterTrans = (extra_duration, func) ->
		if typeof extra_duration is 'function'
			func = extra_duration 
			extra_duration = 0
		@each ->
			$(@).on 'transitionend webkittransitionend moztransitionend', ->
				setTimeout ->
					func.call(@)
				, extra_duration
)
