function guideSubmit() {

  if (true){//parent.HeadList.length > 0) {

    var DateObj = new Date();
    parent.setDBPair(parent.PersDBase,"last_save",DateObj.toString());
    var status = parent.getNameValue(parent.Header,"status");
    if (status == "" || status == "Not Saved") status = "New";
    document.forms[formStartNumber].status.value = status;
    var reference = parent.getNameValue(parent.Header, "reference");
    document.forms[formStartNumber].reference.value = reference;
    document.forms[formStartNumber].ccode.value = parent.CCode;
    document.forms[formStartNumber].email.value = parent.getNameValue(parent.Header, "email");
    document.forms[formStartNumber].database.value = parent.database;
    document.forms[formStartNumber].report.value = parent.CreateXML();
    document.forms[formStartNumber].displayText.value = parent.getJSX("submit_screen_msg");
    //document.forms[formStartNumber].submitMethod.value = "submitFromGuideChk_leave.html";
    parent.SetLocal()
    
    postSimpleForm(parent.defaultApps + 'ajax/SubmitwithGuide_leave.jsp', document.forms[formStartNumber]);

  } else {

    alert("You cannot proceed with this option!\n\nThe current report doesn't contain any report purpose.\nIf you have entered data on a form, ensure\nthat you have clicked the grey button.\nOtherwise you will lose your data.");

  }

}

function XSubmit() {
   var x = setTimeout("guideSubmit()",200);
}
function screenLoad() {
  XSubmit();
  return true;
}

function screenUnload() {
  return true;
}

function cancelThisReport() {
  if (confirm(getJSX("JSS_CANCEL"))) {
     cancelThisRequest = "DoNotPost";
     // parent.ReportIsSaved = true;
     // parent.SetReportIsSaved = false;
     screenUnload();
     document.getElementById("main").innerHTML = "<p><h2>" + getJSX("JSS_CANCEL_DONE") + "</h2></p>";
     switchScript("shared/blank.js");
  }
}
