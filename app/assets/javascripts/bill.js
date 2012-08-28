<div class="wrapper">
	<div class="content">
		<div class="row">
		  <div class="span2">&nbsp;</div>
		  <div class="span7 borderBox">
			<form accept-charset="UTF-8" action="<%= gifts_path %>" class="new_gift" method="post" name="new_gift" id="new_gift">
					<legend class="label">Order Details</legend>
					<div class="row">
						<div class="span3">
						  <label for="receiver" class="label">For:</label>
						  <label><%= list_icon_with_id_for @gift.receiver_id %></label>
						</div>
						<div class="span3">
						  <label name="gift[receiver_name]" class="label" ><%= @gift.receiver_name %></label>
						  <span><%= User.find(@gift.receiver_id).handle %></span>
						</div>
					</div>
					<div class="row">
					  <div class="span3">
  						<label for="provider" class="label">Location:</label>					    
						  <label><%= logo_from_id_for @gift.provider_id %></label>
						</div>
						<div class="span3">
						  <label name="gift[provider_name]" class="label" ><%= @gift.provider_name %></label>
						  <span><%= @gift.provider.full_address %></span>
						</div>
					</div>
					<div class="row">
					  <div class="span3">
  						<label for="item" class="label">Item:</label>
						  <label><%= image_tag get_category_image(@gift), {:class => 'iconListView'} %></label>
						</div>
						<div class="span3">
						  <label name="receiver" class="label" ><%= @gift.item_name %></label>
						  <span>$<%= @gift.price %></span>
						</div>
					</div>
					<div class="row">
					  <div class="span3">
					    <span>Quantity:</span>
              <button class="btn <%= @disabled %>" type="button" id="decreaseQ">-</button>
              <button class="btn" type="button" id="increaseQ">+</button>
						</div>
						<div class="span3">
              <input name="gift[quantity]" class="span1" id="quantityAmount" size="16" type="text" />
						</div>
					</div>
					<div class="row">
					  <div class="span3">
              <span>Local Sales Tax: <%= @provider.sales_tax.to_f %>%</span>
						</div>
						<div class="span3">
              <span id="taxAmount" class="label">Calculating ...</span>
						</div>
					</div>
					<div class="row">
					  <div class="span3">
              <label for="subTotal" class="label">SubTotal:</label>
						</div>
						<div class="span3">
              <label for="subTotalAmount" id="subTotalAmount" class="label">Calculating ...</label>
						</div>
					</div>
					<div class="row">
					  <div class="span3 input-append" data-toggle="buttons-radio">Tip:
                 <button type="button" class="btn tip" id="perItem">$1 per</button>
                 <button type="button" class="btn tip" id="fifteenPrecent">15%</button>
                 <button type="button" class="btn tip" id="twentyPercent">20%</button>
						</div>
						<div class="span3">
              $<input name="gift[tip]" class="span2" id="tip" size="16" type="text" value="Choose Tip Amount"/>
						</div>
					</div>
					<div class="row">
					  <div class="span3">
					    	<label for="total" class="label">Total:</label>
                <span id="total">&nbsp;</span>
						</div>
						<div class="span3">
              <label for="total" class="label" id="totalAmount">$</label>
        			<input class="btn btn-large btn-info disabled" type="submit" name="submit" id="submit" value="Please Leave a Tip"/>
						</div>
					</div>					
			</form>
			</div>
			<div class="span2">&nbsp;</div>
		</div>
	</div>
</div>

<script type="text/javascript">
  // //                              embed data from server              //
  var price = <%= @gift.price.to_i %>;
  var quantity = <%= @gift.quantity  %>;
  var sales_tax = <%= @provider.sales_tax.to_f %>;
  var preTaxTotal = price * quantity;
  var subTotal = calcSubTotal(preTaxTotal, sales_tax);
  
  $(function() {
    
    //                           initialize form                        //
    $('#quantityAmount').val(quantity);
    $(':input#tip').val('Choose Tip Amount');
    calcSubTotal(preTaxTotal, sales_tax);
  
    //                           set event handlers                     //
    $('#increaseQ').click(function() {
      quantity ++;
      changeQuantity(price, quantity, sales_tax, true);
      changeTotalsFromQuantity();
    });
    $('#decreaseQ').click(function() {
      if (!$(this).hasClass('disabled')) {
        quantity --;
        changeQuantity(price, quantity, sales_tax, true);
        changeTotalsFromQuantity();
      }
    });
    $('#perItem, #fifteenPrecent, #twentyPercent').click(function() {
      calcTip($(this).text());
    });
    
    //                           set input field events                      //
    $(':input#quantityAmount').blur(function() {
      var fieldValue = $(this).val();
      if (isNaN(fieldValue)) {
        alert('please supply a number');
        $(this).val(quantity);
      }
      if (fieldValue < 1) {
        alert('please supply a number - 1 or more');
        $(this).val(quantity);
      }
      if (fieldValue >= 1) {
        //round unwanted user entered decimels
        quantity = formatQuantity(fieldValue);
        $(':input#quantityAmount').val(quantity);
        changeQuantity(price, quantity, sales_tax, false);
        changeTotalsFromQuantity();
        //$(':input#tip').focus();        
      }
    });
    
    $(':input#quantityAmount').keyup(function(e) {      
      // Detect Enter
      if(e.which === 13){ 
        $(this).blur();
      }     
    });
    
    $(':input#tip').focus(function() {
      var field = $(this);
      if (field.val()=='Choose Tip Amount') {
        field.val('');
      }
    });
    
    $(':input#tip').blur(function() {
      var fieldValue = $(this).val();
      // if field is not changed should it change the tip buttons?
      if (isNaN(fieldValue)) {
        $(this).val('Choose Tip Amount');
        resetSubmitButton();
        alert('please supply a number');
      }
      if (fieldValue < 1) {
        $(this).val('Choose Tip Amount');
        resetSubmitButton();
        alert('please supply a number - 1 or more');
      }
      if (fieldValue >= 1) {
        // round user entered decimels beyond 2 digits
        formattedFieldValue = formatCurrency(fieldValue);
        $(':input#tip').val(formattedFieldValue);
        calcTotal(parseFloat(formattedFieldValue));
        $(':button').removeClass('active');
      }
    });
    
    $(':input#tip').keyup(function(e) {      
      // Detect Enter
      if(e.which === 13){ 
          $(this).blur(); 
      }     
    }); 
  }); // end document ready function
  
  //                             calculate field values                     //
  function changeTotalsFromQuantity() {
    if ($(':button.active').text()) {
      var button = $(':button.active').text();
      calcTip(button);
    } else {
      if (!isNaN($('#tip').val())) {
        var tipAmount = parseFloat($('#tip').val());
        calcTotal(tipAmount);
      }
    }
  };
  
  function calcTip(button) {
    if (button=='20%') {
      tipAmount = subTotal * 0.20;
    }
    if (button=='15%') {
      tipAmount = subTotal * 0.15;
    }
    if (button=='$1 per') {
      tipText = $('#quantityAmount').val();
      tipAmount = parseFloat(tipText);
    }
    $(':input#tip').val(formatCurrency(tipAmount));
    calcTotal(tipAmount);
  };
  
  function calcTotal(tipAmount) {
    total = subTotal + tipAmount;
    $('label#totalAmount.label').text('$ ' + formatCurrency(total));
    $(':input#submit').val('Click Here to Send Gift');
    $(':input#submit').removeClass('disabled');
  };
  
  function calcSubTotal(preTaxTotal, sales_tax) {
    var taxAmount   = (preTaxTotal * sales_tax)/100;
    $('span#taxAmount.label').text('$ ' + formatCurrency(taxAmount));
    subTotal = preTaxTotal + taxAmount;
    $('label#subTotalAmount.label').text('$ ' + formatCurrency(subTotal));
  };
  
  function changeQuantity(price, quantity, sales_tax, button) {
      var preTaxTotal = price * quantity; 
      // add updated quantity to input field for -/+ buttons
      if (button) {
        $('#quantityAmount').val(quantity);        
      }
      // enable/disable the quantity minus button
      controlDecreaseQ(); 
      // re-run calSubTotal with new preTotal and sales tax
      calcSubTotal(preTaxTotal, sales_tax);     
  };
  
  //                            set button behaviors                     //    
  function controlDecreaseQ() {
      if (quantity == 1) {
        $('#decreaseQ').addClass('disabled');  
      }
      if ((quantity > 1) && $('#decreaseQ').hasClass('disabled')) {
        $('#decreaseQ').removeClass('disabled');  
      }
  };
  
  function resetSubmitButton() {
    $(':input#submit').val('Please Leave a Tip');
    $(':input#submit').addClass('disabled');
    $(':button').removeClass('active');
  };
  
  //                                format numbers                     //
  function formatCurrency(num) {
      num = isNaN(num) || num === '' || num === null ? 0.00 : num;
      return parseFloat(num).toFixed(2);
  }
  
  function formatQuantity(num) {
      num = isNaN(num) || num === '' || num === null ? 0.00 : num;
      return parseFloat(num).toFixed(0);
  }
  
</script>














    

