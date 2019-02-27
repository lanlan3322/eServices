
function Save() {
 
  var regexp = /'/g ;
  var processStr = parent.getNameValue(parent.Header, "comment"); 
  processStr = processStr.replace(regexp,"");
  regexp = /\n/g ;
  processStr = processStr.replace(regexp," ");
  regexp = /\r/g ;
  processStr = processStr.replace(regexp,"");  
  if (processStr.length > 60) processStr = processStr.substring(0,60);   //jh 2003-5-2
  parent.setNameValue(parent.Header,"comment", processStr);

  document.forms[formStartNumber].report.value = parent.CreateXML();
  var DateObj = new Date();
  parent.setDBPair(parent.PersDBase,"last_save",DateObj.toString());
  document.forms[formStartNumber].email.value = parent.getNameValue(parent.Header, "email");
  if (document.forms[formStartNumber].email.value == "") {
     document.forms[formStartNumber].email.value = parent.getNameValue(parent.myHeader, "email");
     parent.setNameValue(parent.Header, "email", parent.getNameValue(parent.myHeader, "email"));
  }
  var status = parent.getNameValue(parent.Header,"status");
  if (status == "" || status == "Not Saved") status = "New";
  document.forms[formStartNumber].status.value = status;
  var reference = parent.getNameValue(parent.Header, "reference");
  document.forms[formStartNumber].reference.value = reference;
  if (status == "New") parent.setNameValue(parent.Header,"xref",reference);
  document.forms[formStartNumber].xaction.value = "Save";
  document.forms[formStartNumber].database.value = parent.database;
  document.forms[formStartNumber].ccode.value = parent.CCode;
parent.Log.println("saveXMLFile.js","CCode[1]=" + parent.CCode);  
parent.Log.println("saveXMLFile.js","CCode[2]=" + document.forms[formStartNumber].ccode.value);  
  document.forms[formStartNumber].comment.value = parent.XMLReplace(parent.rtrim(parent.getNameValue(parent.Header,"comment")));

  postSimpleForm(parent.defaultApps + 'ajax/SaveXML.jsp', document.forms[formStartNumber]); 

}

function screenLoad() {
  return true;
}

function screenUnload() {
  return true;
}




