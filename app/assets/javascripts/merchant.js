function getAddItemTemplate() {
	return $('.addItemForm.template').clone().removeClass('template').css({display:'block'});
}

function getAddButton() {
	return $('#add').clone().removeAttr('id').removeClass('template').addClass('menuListAdd').css({display:'block'});
}

function getBackButton() {
	return $('#backButton').clone().removeAttr('id').removeClass('template').addClass('menuListBack').css({display:'block'});
}

function buildHeaderForAddItem(menuSection, items) {
	var sectionHeader = menuSection.closest(".menu_section");
	var sectionTitle = sectionHeader.find('h2').attr('id');
		// add a save button
	var addButton = getAddButton;
	var saveButton = sectionHeader.find('.menuListSave');
	saveButton.replaceWith(addButton);
	sectionHeader.find('.menuListAdd').click(function(e){
			// run function to save item
		var menuForm = menuSection.find('.addItemForm ul');
		var itemName = menuForm.find('.miTitleForm').val();
		var itemDescription = menuForm.find('.miDescriptionForm').val();
		var itemPrice = menuForm.find('.miPriceForm').val();

		$.post('update_item',  
				{section: sectionTitle, 
			 	item_name: itemName,
			 	 description: itemDescription,
			 	  price: itemPrice});
		//e.preventDefault();
		return true;
	});
		// add a back button
	var backButton = getBackButton;
	var editButton = sectionHeader.find('.menuListEdit')
	editButton.replaceWith(backButton);
	sectionHeader.find('.menuListBack').click(function(e){
		//alert('back button');
			// run function to rebuild display section
		displaySection(menuSection, items);
		//displaySectionButtons(sectionHeader, editButton, saveButton, addButton, backButton);
		e.preventDefault();
		return false;
	});
}

// function displaySectionButtons(sectionHeader, editButton, saveButton, addButton, backButton) {
	
// 	alert('in button replace');
// 	addButton.remove();
// 	backButton.replaceWith(editButton);
// 	// sectionHeader.remove(addButton);
// 	// sectionHeader.remove(backButton);
// 	return false;
// }

// function displaySection(menuSection, items) {
// 	//alert('in display section');
// 	menuSection.html(items);
// 	items.fadeToggle(600);
// }

function makeArrayOfItems(menuSection) {
	var itemArray = new Array();
	var menuForm = menuSection.find('.menuItemForm ul');
	console.log(menuForm.length);

	$(menuForm).each(function(index, value) {
		var menuItem = getMenuItemData($(this));
		displayItem(menuItem, 'makeArrayOfItems each');
		itemArray.push(menuItem);
	});
	$.each(itemArray, function () {
		displayItem(this, 'itemArray each');
	});
	return itemArray;	
}

function displayItem(menuItem, fromWhere) {
	//alert(fromWhere + ' -> id = ' + menuItem.id + ', name =' + menuItem.item_name + ', descr = ' + menuItem.description + ', price = ' + menuItem.price);
}

function getAddItemData(menuForm) {

	var itemID =  menuForm.attr('id');
	var itemName = menuForm.find('.miTitleForm').val();
	var itemDescription = menuForm.find('.miDescriptionForm').val();
	var itemPrice = menuForm.find('.miPriceForm').val();
	//alert('id = ' + itemID + ', name =' + itemName + ', descr = ' + itemDescription + ', price = ' + itemPrice);

	var menuItem = {
		id: itemID,
		item_name: itemName,
		description: itemDescription,
		price: itemPrice
	};
	displayItem(menuItem, 'getMenuItemData');
	return menuItem;
}

function getMenuItemData(menuForm) {

	var itemID =  menuForm.attr('id');
	var itemName = menuForm.find('.miTitleForm').val();
	var itemDescription = menuForm.find('.miDescriptionForm').val();
	var itemPrice = menuForm.find('.miPriceForm').val();
	//alert('id = ' + itemID + ', name =' + itemName + ', descr = ' + itemDescription + ', price = ' + itemPrice);

	var menuItem = {
		id: itemID,
		item_name: itemName,
		description: itemDescription,
		price: itemPrice
	};
	displayItem(menuItem, 'getMenuItemData');
	return menuItem;
}

function toggleMenuItemForm(menuSection, editButton) {
	editButton.toggleClass('buttonImageUp');
	editButton.toggleClass('buttonImageDown');	
	menuSection.find(".menuItem").fadeToggle(150);
	menuSection.find('.menuListSave').fadeToggle(150);
	menuSection.find('.menuItemForm').slideToggle(150);

}

function getEmployeeCropper(route) {
	$.get('get_cropper',
		 {image: route});
}


$(function() {

	/////////        ADD ITEM METHODS        //////////////

	$('.addItemJS').click(function() {
		// remove all the section li and divs
		var menuSection = $(this).closest('.menuSectionUL');
		var items = menuSection.find('.menuItemLI');
		
		items.fadeToggle(600);
		var addItemForm = getAddItemTemplate();
		menuSection.html(addItemForm);
		buildHeaderForAddItem(menuSection, items);
		//alert('add item');
		return false;
	});

	/////////        EDIT  ITEM METHODS        //////////////

		// "edit" click function menu builder
	$('.menuListEdit').click(function () {
			//swap out edit button image on click
		var menuSection = $(this).closest(".menu_section");
		toggleMenuItemForm(menuSection, $(this));
		menuSection.find(".addItemLink").toggle();
		return false;
	});
		// "delete" click function menu builder
	$('.menuListDelete').click(function () {
		
		var menuItemID = $(this).closest('ul').attr('id');
		var menuSection = $(this).closest(".menu_section");
		var editButton = menuSection.find('.menuListEdit');
		var itemName = $(this).closest('ul').find('.miTitleForm').val();
		// post route to delete menu record
		var r = confirm('Are you sure? menu Item = ' + itemName);
		if (r) {
			$.post('delete_item',{item_id: menuItemID});
			// remove the divs from the view
			var formForDelete = $(this).closest('.menuItemForm');
			formForDelete.fadeOut(1000, function () {
				formForDelete.closest('.menuItemLI').remove();	
				// if there is no more objects, return to display mode
				if ($('.menuItemLI').length == 0) {
					toggleMenuItemForm(menuSection, editButton);
					menuSection.find(".addItemLink").toggle();
				}			
			});
		};

		return false;
	});

		// "save" click function menu builder
	$('.menuListSave').click(function () {
		var menuSection = $(this).closest(".menu_section");
		menuArray = makeArrayOfItems(menuSection);
		//var num = menuArray.length;
		if (menuArray.length == 1) {
			menuItem = menuArray.shift();
			menuItemJson = JSON.stringify(menuItem);
			$.post('update_item',  
				{item_id: menuItem.id, 
			 	item_name: menuItem.item_name,
			 	 description: menuItem.description,
			 	  price: menuItem.price});
		} else {
			//menuArrayJson = JSON.stringify();
			$.each(menuArray, function() {
				menuItem = this;
				//displayItem(menuItem, 'multiItem post');
				$.post('update_item',  
				{item_id: menuItem.id, 
			 	item_name: menuItem.item_name,
			 	 description: menuItem.description,
			 	  price: menuItem.price});
			});
		}
		var headerButtons = $(this).closest('h2');
		var editButton = headerButtons.find('.menuListEdit');
		toggleMenuItemForm(menuSection, editButton);
		ulID = "#show" + menuItem.id;
		menuSection.find(ulID + " .miTitle").text(menuItem.item_name);
		menuSection.find(ulID + " .miDescription").text(menuItem.description);
		menuSection.find(ulID + " .miPrice").text(menuItem.price);
		return true;
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

	$('#editProfileLink').click(function () {
			//swap out edit button image on click
		$('#editProfileForm').fadeToggle(150);
		// go into the user description with photo and change address data etc
		$('#cropperWrapper').hide();
		return false;
	});

	$('#avatarLink').click(function () {
		// call server with avatar and get photo cropper 
		getEmployeeCropper('photo');
		return false;
	});

	$('#secureImageLink').click(function () {
		// call server with avatar and get photo cropper 
		getEmployeeCropper('secure_image');
		return false;
	});

	$('.option').click(function () {
		$(this).css({color:'#666'});
	});
 
}); // end
