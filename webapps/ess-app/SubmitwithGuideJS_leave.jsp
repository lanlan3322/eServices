<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />           

var submitSafetyFlag = true;

function reclaimRef() {
  //JH 11-5-2003
  parent.setNameValue(parent.Header, "reference", "<%= request.getParameter("lastReference") %>");
}

function guideSubmit() {
 if (parent.HeadList.length > 0) {
   if (submitSafetyFlag) {
    submitSafetyFlag = false;

    // If not using SubmitFromGuideChk.html need to envoke the below.
    //var subdate = parent.contents.getNameValue(parent.contents.Header, "subdate");
    //if (subdate == "") {
    //   parent.contents.setNameValue(parent.contents.Header,"subdate",parent.contents.setDateStr(0));
    //   parent.contents.setNameValue(parent.contents.Header,"subtime",parent.contents.setTimeStr());
    //}
    
    // postSimpleForm(parent.defaultApps + 'ajax/SubmitDBase.jsp', document.forms[formStartNumber]);
    loadHTMLScreenAJAX("<%= request.getParameter("screen") %>");
   }
 } else {
   alert("<%= Lang.getString("ERROR_REPORT_PURPOSE_ALERT") %>");
 }

}

function screenLoad() {
	parent.PersWindow(parent.defaultApps + "<%= request.getParameter("screen") %>");
  //reclaimRef();
  return true;
}

function screenUnload() {
  return true;
}



   
