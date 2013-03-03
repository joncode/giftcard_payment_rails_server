$(function() {

	$('#biographies a').click(function(e) {
		$('#biography').html('<h2>loading…</h2>');
		var _bio = $(this);
		setTimeout(function() {
			var url = "/merchants/49/" + _bio.attr('href');
			// $('#biography').load(url + ' #description');

			var params = _bio.attr('id');
			$('#biography').load(url + ' #description' , params, function() {
				$('#biographies a').css({color:'rgba(0,134,174,1)'});
				_bio.css({color:'rgba(179,201,231,1)'});
			});

		}, 1000);
		//alert('working');
		e.preventDefault();
	});

	$('#biography').on('mouseover',function() {
		$('#description').css('background-color','blue');

	});
	$('#biography').off('mouseover','#description');
	
		// using .getJSON to get the Providers from app route
	// $('#linkDb a').click(function(e) {
	// 	var base = "http://localhost:3000/"
	// 	var url = "app/get_providers";
	// 	var _linkDb = $(this);
	// 	$.getJSON(base + url, function(data) {
	// 		$.each(data, function() {
	// 			_linkDb.hide().after('<h2>'+ this.provider_id + ' '  + this.name + '</h2>');
	// 		});
	// 	});
	// 	e.preventDefault();
	// });


		// using .ajax to POST to the providers app route for providers
	$('#linkDb a').click(function(e) {
		var base = "http://drinkboard.herokuapp.com/"
		var url = "app/providers";
		var _linkDb = $(this);
		$.ajax({
			type: 'POST',
			url: base + url,
			data: { 'token' : "hakdkfalsdf"},
			success: function(data) {
				$.each(data, function() {
					_linkDb.hide().after('<h2>'+ this.provider_id + ' '  + this.name + '</h2>');
				});
			}
		});
		e.preventDefault();
	});
});
