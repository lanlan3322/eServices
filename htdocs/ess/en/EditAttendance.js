var saveXMLFile = true;
function Save() {
	if (saveXMLFile)
	{
	  document.forms[formStartNumber].email.value = parent.getNameValue(parent.Header, "email");
	  if (document.forms[formStartNumber].email.value == "") {
		 document.forms[formStartNumber].email.value = parent.getNameValue(parent.myHeader, "email");
		 parent.setNameValue(parent.Header, "email", parent.getNameValue(parent.myHeader, "email"));
	  }
	  document.forms[formStartNumber].database.value = parent.database;
	  document.forms[formStartNumber].ccode.value = parent.CCode;
		document.forms[formStartNumber].newLeaveFrom.value = parent.newLeaveFrom;
	  postSimpleForm(parent.defaultApps + 'ajax/AttendanceVO.jsp', document.forms[formStartNumber]); 
	}
}

function screenLoad() {
  Save();
  return true;
}

function screenUnload() {
  return true;
}

