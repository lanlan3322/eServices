var isScreenLoadOK = true;  //JH 2014-10-7 
function screenLoad() {
   if (isScreenLoadOK == true)
   {
	   isScreenLoadOK = false;
	   myESSMenu.setNewReport();
   }
   return true;
}

function screenUnload() {
	parent.myESSMenu.setMenu();    //Temporary - each screen should set its own menu
  isScreenLoadOK = true;
  return isScreenLoadOK;
}

function showDataFields() {
  var reportElement;
  for (var i = 0; i < arguments.length; i++){
     reportElement = document.getElementById(arguments[i]);
     if (reportElement != null) reportElement.style.display="";
  }   
}

function hideDataFields() {
  var reportElement;
  for (var i = 0; i < arguments.length; i++){
     reportElement = document.getElementById(arguments[i]);
     if (reportElement != null) reportElement.style.display="none";  //added by JH Nov-8-2011
  }   
}

function returnItems(id){
	parent.PersWindow(parent.defaultApps + 'ajax/InventoryReturn.jsp?id=' + id);
}

