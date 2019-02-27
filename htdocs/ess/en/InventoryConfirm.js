var saveXMLFile = true;
function Save() {
	if (saveXMLFile)
	{
		saveXMLFile = false;
		document.forms[2].email.value = parent.getNameValue(parent.Header, "email");
		if (document.forms[2].email.value == "") {
			document.forms[2].email.value = parent.getNameValue(parent.myHeader, "email");
			parent.setNameValue(parent.Header, "email", parent.getNameValue(parent.myHeader, "email"));
		}
		document.forms[2].database.value = parent.database;
		document.forms[2].ccode.value = parent.CCode;
		document.forms[2].reference.value = parent.reference.value;
		document.forms[2].reason.value = parent.report.value;
		document.forms[2].xaction.value = parent.xaction.value;
		//alert(document.forms[2].reason.value);
		postSimpleForm(parent.defaultApps + 'ajax/InventoryConfirm.jsp', document.forms[2]); 
	}
}

function screenLoad() {
  Save();
  return true;
}

function screenUnload() {
  return true;
}

