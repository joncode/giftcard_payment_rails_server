$(function() {

	$('.bodyDiv').css({'background' : 'none'}); //turns off main background picture

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

	// Beer "Edit ITEMS" click functions
	$('#editItemsButtonBeer a').click(function () {

		//swap out edit button images and a blocker divs on click
		$('#editItemsButtonBeer').toggleClass('buttonSmallerUp');
		$('#editPricesButtonBeer').addClass('buttonSmallerUp');
		$('#editPricesButtonBeer').toggleClass('buttonDeadOpacity');
		$('.buttonHiderPrice').toggle();

		// Change the 2 edit box states		
		$('.beerEditWrapper, .buttonSaveBeerItem').fadeToggle(100);
		$('.beerMenuBox').fadeToggle(100);
		return false;
			//end switch up/down images/class switch
	});

	// Beer "Edit PRICES" click functions
	$('#editPricesButtonBeer a').click(function () {
		//swap out edit button image on click
		$('#editPricesButtonBeer').toggleClass('buttonSmallerUp');
		$('#editItemsButtonBeer').toggleClass('buttonDeadOpacity');
		$('.buttonHiderItem').toggle();

		// Change the 2 edit box states
		$('.beerPriceLine, .dollarSignSmall, .arrowDown, .priceSingleItem, .buttonSaveBeerPrice').fadeToggle(100);
		return false;
			//end switch up/down images/class switch
	});


	// Liq "Edit ITEMS" click functions
	$('#editItemsButtonLiq a').click(function () {

		//swap out edit button images and a blocker divs on click
		$('#editItemsButtonLiq').toggleClass('buttonSmallerUp');
		$('#editPricesButtonLiq').addClass('buttonSmallerUp');
		$('#editPricesButtonLiq').toggleClass('buttonDeadOpacity');
		$('.buttonHiderPrice').toggle();

		// Change the 2 edit box states		
		$('.liqEditWrapper, .buttonSaveLiqItem').fadeToggle(100);
		$('.liqMenuBox').fadeToggle(100);
		return false;
			//end switch up/down images/class switch
	});

	// Liq "Edit PRICES" click functions
	$('#editPricesButtonLiq a').click(function () {
		//swap out edit button image on click
		$('#editPricesButtonLiq').toggleClass('buttonSmallerUp');
		$('#editItemsButtonLiq').toggleClass('buttonDeadOpacity');
		$('.buttonHiderItem').toggle();

		// Change the 2 edit box states
		$('.liqPriceLine, .dollarSignSmall, .arrowDown, .priceSingleItem, .buttonSaveLiqPrice').fadeToggle(100);
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

		// Cocktail "edit" click functions
	$('#buttonEditCock a').click(function () {
		//swap out edit button image on click
		$('#buttonEditCock').toggleClass('buttonSmallUp');
		$('.cockEditWrapper, .cockMenuBox, .buttonSaveCock, .cockItemList').toggle();
		return false;
			//end switch up/down images/class switch
	});

	// App "edit" click functions
	$('#buttonEditApp a').click(function () {
		//swap out edit button image on click
		$('#buttonEditApp').toggleClass('buttonSmallUp');
		$('.appEditWrapper, .appMenuBox, .buttonSaveApp').toggle();
		return false;
			//end switch up/down images/class switch
	});

	// Entre "edit" click functions
	$('#buttonEditEntre a').click(function () {
		//swap out edit button image on click
		$('#buttonEditEntre').toggleClass('buttonSmallUp');
		$('.entreEditWrapper, .entreMenuBox, .buttonSaveEntre, .entreItemList').toggle();
		return false;
			//end switch up/down images/class switch
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

