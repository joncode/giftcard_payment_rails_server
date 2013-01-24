$(function() {

		// "edit" click function
	$('.menuListEdit').click(function () {

		//swap out edit button image on click
		$(this).toggleClass('buttonImageUp');
		$(this).toggleClass('buttonImageDown');
		var menuSection = $(this).closest(".menu_section");
		menuSection.find(".menuItem").fadeToggle(150);
		menuSection.find('.menuListSave').fadeToggle(150);
		menuSection.find('.menuItemForm').slideToggle(150);
		return false;
	});

		// "save" click function
	$('.menuListSave').click(function () {
		return false;
	});

		// Employee 'Add' click functions
	$('#buttonAddEmp a').click(function () {
		//swap out edit button image on click
		$('#buttonAddEmp').toggleClass('buttonLargeUp');
		$('.addDisplay').toggle();
		return false;
			//end switch up/down images/class switch
	});

	// Gift ID search bar methods
	$('#findButton').click(function () {
		
		// get the number from the input field
		var giftID = $('#giftID').val();
		if (giftID) {
					// find the gift object with giftID
			var searchID = "#giftID" + giftID; 
			var giftDiv = $(".ordersDisplay");

			if ($(searchID).data()) {
				// you have the gift
				// find all the gift objects with backgrounds and hide them
				$('.ordersDisplay').hide();
				$(searchID).show();
				$('.showAll').show();
				$('.redeemDisplay').remove();
				//alert('found it gift ID = ' + giftID);
			} else {
				// you dont have the gift
				// put up an alert box stating you dont have gift 
				alert('Cannot find that gift ID = ' + giftID);
			};
		};

		return false;
	});
	
		// display all the gift objects	
	$('.showAll').click(function () {
		$('.ordersDisplay').show();
		$('.showAll').hide();
		$('#giftID').val('');
		$('.redeemDisplay').remove();
		return false;
	});

}); // end