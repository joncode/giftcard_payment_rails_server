// pos subtle data system
$(function() {
	var sdroot = "https://www.subtledata.com/API/M/1/?Q=";
	var pipe = "%7C";
	var key = "RlgrM1Uw";
	var call = "0000";

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