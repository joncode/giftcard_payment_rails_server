// pos subtle data system
$(function() {
	var sdroot = "https://www.subtledata.com/API/M/1/?Q=";
	var pipe = "%7C";
	var key = "RlgrM1Uw";
	var call = "0000";

	// 		// using .ajax to POST to the providers app route for providers
	// $('#linkDb a').click(function(e) {
	// 	var base = sdroot;
	// 	var url = sdroot + call + pipe + key;
	// 	alert(url);
	// 	var _linkDb = $(this);
	// 	$.ajax({
	// 		type: 'GET',
	// 		url: url,
	// 		success: function(data) {
	// 			$.each(data, function() {
	// 				_linkDb.after('<h2>'+ this + '</h2>');
	// 			});
	// 		}
	// 	});
	// 	e.preventDefault();
	// });

	$('#linkDb a').click(function(e) {
		var base = sdroot;
		var url = sdroot + call + pipe + key;
		//alert(url);
		var _linkDb = $(this);
		$.post(url,
			function('app/providers') {
			alert('Fetched ' + result + ' here!');
		});
		e.preventDefault();
	});

	$('#clear a').click(function() {
		alert('got the click');
		$('#response').empty();
		return false;
	});

});