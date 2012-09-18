
$(function() {

	$('#giftIndexWrapper').isotope({
	  // options
	  itemSelector : '.item',
	  layoutMode : 'fitRows'
	});

	// cache container
	var $container = $('#containerIsotope');
	// initialize isotope
	$container.isotope({
	  // options...
	});

	$('#filters a').click(function(){
	  var selector = $(this).attr('data-filter');
	  $container.isotope({ filter: selector });
	  return false;
	});	
});

