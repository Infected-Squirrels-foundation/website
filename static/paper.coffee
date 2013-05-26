$(->
	window.bcpl = window.bcpl or {}
	# run code again and agagin
	window.bcpl.interpret =
		_.debounce ->
				if  $('#teletype').val().length % 10 == 0
					$('.stdout').html 'loading...' 
					$.post  '/interpret',
						code:$('#teletype').val(),
						(res)-> $('.stdout').html(res)
				else
					$('.stdout').html "wrong input length (need #{10 - $('#teletype').val().length % 10} more)"
		, 100

	window.bcpl.go = ->
		line_width = $('.width_template').width();
		editor_height = $('#teletype').height()
		$('#teletype').hide()
		$('.buttons').hide()
		$('.stdout').hide()
		$('#teletype').hide()
		$('.highlight').hide()
		val = $('.highlight').html()

		$('<div class=\"paper\"></div>')
			.appendTo('.paper_wrap')
			.css('min-height': editor_height)
			.html(val)

		setTimeout(->
			$('.paper').css(width:line_width)
				.afterTrans 500, ->
					val = $('#teletype').val()
					val = val.replace(/(\d{2})(\d{3})/g,'$1:$2');
					val = val.replace(/1/g,'●');
					val = val.replace(/0/g,'&nbsp;');
					$('.paper').html(val)
						.css
							background: 'url(/static/paper_fibers.png)'
							'line-height': '.6em'
					$('.paper_wrap').css(top: -($('.paper_wrap').height()+$('.paper_wrap').offset().top*1.1))
						.afterTrans -> 
							$('.paper').text('●:●●●●●:●●●●●:● ● ●: ● ● :● ●')
							$('.paper_wrap').css(top:0)
									.afterTrans ->
										$('.paper').css(width: 900).afterTrans ->
											$('.paper_wrap').hide()
											$('.workspace').css('text-align', 'center')
											window.bcpl.save()
		, 500)

	window.bcpl.save = ->
		$.post '/save',
			code:$('#teletype').val(),
			(id)-> 
				window.history?.pushState(0, 0, id)
				$("<h1><a href=\"/#{id}\">#{window.location.href}</a></h1>")
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



	# code highlighting
	real_editor = $('#teletype')
	$('.highlight').width(real_editor.width())
	$('.highlight').height(real_editor.height())
	$('#teletype').on 'keyup', ->
		$('.highlight').html($(@).val())
	
	window.bcpl.highlight_1 = ->
		$('.highight_btn').attr('onClick', 'bcpl.highlight_2()')
		$('.highight_btn').text('more colors')
		$('.highlight').css(color: 'black')
		$('#teletype').css(color: 'transparent')

		hl = -> 
			val = $('#teletype').val()
			val = val.replace(/(\d{5})(\d{1,5})/g,'<span style="font-weight:bold">$1</span><span style="font-weight:bold;color: grey;" class="operand">$2</span>')
			$('.highlight').html(val)
		hl()
		$('#teletype').on 'keyup', ->
			hl()

	window.bcpl.highlight_2 = ->
		$('.highight_btn').text('that\'s enought')
		$('.highight_btn').attr('disabled', 'disabled')

		$('.highlight').css('font-weight': 'bold')
		$('#teletype').css(color: 'transparent')
		hl = -> 
			val = $('#teletype').val()
			val = _.map val, (s)->
				"<span style=\"color:hsl(#{Math.random()*180},80%,40%);font-weight:bold\" class=\"operand\">#{s}</span>"
			$('.highlight').html(val)
		hl()
		$('#teletype').on 'keyup', ->
			hl()
)
