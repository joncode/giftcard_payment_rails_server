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

}); // end