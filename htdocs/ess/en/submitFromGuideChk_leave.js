var submitSafetyFlag = true;
function SubmitReport() {
 if (true)//parent.HeadList.length > 0) {
   if (submitSafetyFlag) {
    submitSafetyFlag = false;
    document.forms[formStartNumber].email.value = parent.getNameValue(parent.Header, "email");
    var status = parent.getNameValue(parent.Header,"status");
    if (status == "") status = "New";
    document.forms[formStartNumber].status.value = status;
    var reference = parent.getNameValue(parent.Header, "reference");
    // [Should be reclaimed from previous screen] if (reference == "") reference = <%= SaveXML.getLastReference()%>;
    document.forms[formStartNumber].reference.value = reference;
    if (status == "New") {
       parent.setNameValue(parent.Header,"xref",reference);
       parent.setNameValue(parent.Header,"reference",reference);
    }
    var subdate = parent.getNameValue(parent.Header, "subdate");
    if (subdate == "") {
       parent.setNameValue(parent.Header,"subdate",parent.setDateStr(0));
       parent.setNameValue(parent.Header,"subtime",parent.setTimeStr());
    }
    document.forms[formStartNumber].xaction.value = "Submit";

    parent.setTotalValues();
   
    var DateObj = new Date();
    parent.setDBPair(parent.PersDBase,"last_submit",DateObj.toString());
    document.forms[formStartNumber].database.value = parent.database;
    document.forms[formStartNumber].report.value = parent.CreateXML();
    document.forms[formStartNumber].ccode.value = parent.CCode;
    document.forms[formStartNumber].comment.value = parent.XMLReplace(parent.rtrim(parent.getNameValue(parent.Header,"comment")));
    parent.SetLocal()
    document.forms[formStartNumber].action = parent.defaultApps + "ajax/SubmitDbase_leave.jsp";
    postSimpleForm(parent.defaultApps + 'ajax/SubmitDbase_leave.jsp', document.forms[formStartNumber]);
   }
 } else {
   alert("You cannot proceed with this option!\n\nThe current report doesn't contain any report purpose.\nIf you have entered data on a form, ensure\nthat you have clicked the grey button.\nOtherwise you will lose your data.");
 }
}
function screenLoad() {
  SubmitReport();
  return true;
}

function screenUnload() {
  return true;
}

