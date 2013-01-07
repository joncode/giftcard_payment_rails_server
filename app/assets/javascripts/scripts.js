$(function() {

	//$('.bodyDiv').css({'background' : 'none'}); //turns off main background picture

	$('.buttonSmallerUp a').hover( function() { //blue hover color
		$('.buttonSmallerUp h5').css('color', '@blue2')
	});

	// hide some edit screens on load (toggle them with edit buttons)
	$('.sigDrinkEditWrapper').toggle();
	$('.sigFoodEditWrapper').toggle();
	$('.beerEditWrapper, .liqEditWrapper, .appEditWrapper, .entreEditWrapper').hide();
	$('.buttonHiderItem, .buttonHiderPrice').hide();

	// Signature Drink "edit" click functions
	$('#editButtonSigDrink a').click(function () {

		//swap out edit button image on click
		$('#editButtonSigDrink').toggleClass('buttonSmallUp')
		$('.sigDrinkMenuBox').fadeToggle(150);
		$('.sigDrinkEditWrapper').slideToggle(150);
		return false;
			//end animation
	});

	// Signature Food "edit" click functions
	$('#editButtonSigFood a').click(function () {

		//swap out edit button image on click
		$('#editButtonSigFood').toggleClass('buttonSmallUp');
		$('.sigFoodMenuBox').fadeToggle(150);
		$('.sigFoodEditWrapper').slideToggle(150)
			return false;
			//end switch up/down images/class switch
	});

	// Wine "edit" click functions
	$('#buttonEditWine a').click(function () {
		//swap out edit button image on click
		$('#buttonEditWine').toggleClass('buttonSmallUp');
		$('.wineEditWrapper, .wineMenuBox, .buttonSaveWine').toggle();
		return false;
			//end switch up/down images/class switch
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
				//alert('found it gift ID = ' + giftID);
			} else {
				// you dont have the gift
				// put up an alert box stating you dont have gift 
				alert('Cannot find that gift ID = ' + giftID);
			};
		};

		return false;
	});
	$('.showAll').click(function () {
		// display all the gift objects
		$('.ordersDisplay').show();
		$('.showAll').hide();
		$('#giftID').val('');
		return false;
	});


// Static Click Item Selector (blue and grey button grids)
	//Animate Up/Down States
	$('a.staticClickOn').click(function () {
		$(this).parent().toggleClass('staticButtonActive');
		$(this).parent().toggleClass('staticButtonOff');
		return false;
	});

	$('a.staticClickOff').click(function () {
		$(this).parent().toggleClass('staticButtonActive');
		$(this).parent().toggleClass('staticButtonOff');
		return false;
	});

}); // end
