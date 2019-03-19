

      function Change(num,t,value){
		  //alert(num);
		  //alert(t);
		  //alert(value);
		  var obj = document.getElementById(num);
		  if(obj.value > t){
			  alert("Requested number is not allowed! max --> "+ t);
			  obj.value = t;
		  }else if(obj.value < 0){
			  obj.value = 0;
			  alert("Requested number is not allowed!");
		  }
        if(obj.value != 0)
		{
			document.getElementById(num).style.backgroundColor = "red";
			document.getElementById(num + "select_this_item").checked = true;
			document.getElementById(num + "select_this_item").value = num + "," + obj.value;
		}
		else
		{
			document.getElementById(num).style.backgroundColor = "initial";
			document.getElementById(num + "select_this_item").checked = false;
			document.getElementById(num + "select_this_item").value = "";
		}
      }
	  
      function ChangeReturn(num,t,value){
		  //alert(num);
		  //alert(t);
		  //alert(value);
		  var obj = document.getElementById(num);
		  var limit = t - value;
		  if(obj.value > limit){
			  alert("Requested number is not allowed! max --> "+ limit);
			  obj.value = limit;
		  }else if(obj.value < 0){
			  obj.value = 0;
			  alert("Requested number is not allowed!");
		  }
        if(obj.value != 0)
		{
			document.getElementById(num).style.backgroundColor = "red";
			document.getElementById(num + "select_this_item").checked = true;
			document.getElementById(num + "select_this_item").value = num + "," + obj.value;
		}
		else
		{
			document.getElementById(num).style.backgroundColor = "initial";
			document.getElementById(num + "select_this_item").checked = false;
			document.getElementById(num + "select_this_item").value = "";
		}
      }
	  
      function ChangeStock(num,t,value){
		  //alert(num);
		  //alert(t);
		  //alert(value);
		  var obj = document.getElementById(num);
		  /*if(obj.value > t){
			  alert("Requested number is not allowed! max --> "+ t);
			  obj.value = t;
		  }else */if(obj.value < 0){
			  obj.value = 0;
			  alert("Requested number is not allowed!");
		  }
        if(obj.value != t)
		{
			document.getElementById(num).style.backgroundColor = "red";
			document.getElementById(num + "select_this_item").checked = true;
			document.getElementById(num + "select_this_item").value = num + "," + obj.value;
		}
		else
		{
			document.getElementById(num).style.backgroundColor = "initial";
			document.getElementById(num + "select_this_item").checked = false;
			document.getElementById(num + "select_this_item").value = "";
		}
      }

	  function SetNewValues(stock){
			var delim = "";
			document.forms[2].reference.value = "";
			for (var i = 0; i < document.forms[2].length; i++) {
				 if (document.forms[2].elements[i].id.indexOf("select_this_item") && document.forms[2].elements[i].checked == true) {
				   document.forms[2].reference.value += delim + document.forms[2].elements[i].value;
				   delim = ";";   
				 }
			}
			parent.reference.value = document.forms[2].reference.value;
			parent.report.value = document.forms[2].reason.value;
			parent.xaction.value = "Update";
			if(stock == "0"){
				parent.xaction.value = "Request";
				if (delim == ";") {
					loadHTMLScreenAJAX('InventoryConfirm.html');
					//document.forms[2].submit();

				} else {
					alert("There is no item selected!");
				}
			}
			else{
				var tally = "1";
				if (delim == ";") {
					tally = "0";
				} 
				//parent.xaction.value = document.forms[2].xaction.value;
				parent.report.value = stock + "," + tally + "," + document.forms[2].reason.value + "SC";
				loadHTMLScreenAJAX('InventoryConfirm.html');
			}
		}
	  
	  function Return(stock){
			var delim = "";
			document.forms[2].reference.value = "";
			for (var i = 0; i < document.forms[2].length; i++) {
				 if (document.forms[2].elements[i].id.indexOf("select_this_item") && document.forms[2].elements[i].checked == true) {
				   document.forms[2].reference.value += delim + document.forms[2].elements[i].value;
				   delim = ";";   
				 }
			}
			parent.reference.value = document.forms[2].reference.value;
			parent.report.value = document.forms[2].reason.value;
			parent.xaction.value = "Return";
			parent.report.value = stock + "," + document.forms[2].reason.value;
			loadHTMLScreenAJAX('InventoryConfirm.html');
		}
				
		function SignRequest(id,action){
			parent.reference.value = id;
			parent.xaction.value = action;
			parent.report.value = action;
			//alert(parent.xaction.value);
			loadHTMLScreenAJAX('InventoryConfirm.html');
		}
				
		function RemoveItems(id,action,name,cat,amount){
			parent.reference.value = id;
			parent.xaction.value = action;
			parent.report.value = name + "," + cat + "," + amount;
			//alert(parent.report.value);
			loadHTMLScreenAJAX('InventoryConfirm.html');
		}