<%--
SubmitwithGuide.jsp - runs guidecheck and provides link the SubmitDbase.jsp
Copyright (C) 2004 R. James Holton

This program is free software; you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation; either version 2 of the License, or (at your option) 
any later version.  This program is distributed in the hope that it will be 
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
Public License for more details.

You should have received a copy of the GNU General Public License along with 
this program; if not, write to the Free Software Foundation, Inc., 
675 Mass Ave, Cambridge, MA 02139, USA. 
--%>

<!-- Copyright (c) 2003 Adisoft, Inc., All rights reserved -->
<%@ page contentType="text/html" %>

<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "GL"
     class="ess.Guideline"
     scope="page" />
<jsp:useBean id = "ReportDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "Enh"
     class="ess.Enhancement"
     scope="page" />
<jsp:useBean id = "SaveXML"
     class="ess.ReportContainer"
     scope="page" />
<jsp:useBean id = "SavePers"
     class="ess.SavePersData"
     scope="page" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" /> 

<%@ include file="DBAccessInfo.jsp" %>

<%
String ownersName = request.getParameter("email");

boolean pFlag = PersFile.setPersInfo(ownersName); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
  Log.println("[005] Start SubmitwithGuide: " + ownersName);
%> 
<%@ include file="SystemInfo.jsp" %>
<html>
<head>
<link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
</head>

<% String database = request.getParameter("database");
   String submitMethod = request.getParameter("submitMethod");
//Log.println("[---] submitMethod : " + submitMethod);
   if (submitMethod == null) submitMethod = "SubmitXML.jsp";
   
   ReportDOM.setConnection(PersFile.getConnection());
   ReportDOM.setSQLTerminator(PersFile.getSQLTerminator());
   GL.setConnection(PersFile.getConnection());
   GL.setSQLTerminator(PersFile.getSQLTerminator());
   GL.setLanguage(PersFile.getLanguage());
   GL.setDateFormat(PersFile.getDateFormat());
   GL.setDecimal(PersFile.getDecimal());
   GL.setSeparator(PersFile.getSeparator());
   GL.setUpFiles();
   Enh.setConnection(PersFile.getConnection());
   Enh.setSQLTerminator(PersFile.getSQLTerminator());
   SaveXML.setConnection(PersFile.getConnection());  
   SaveXML.setSQLTerminator(PersFile.getSQLTerminator());
   SaveXML.setOwner(ownersName);
   if (SaveXML.getDOMProcessed()) {
   String reportString = request.getParameter("report");
   SaveXML.setXMLFile(reportString, request.getParameter("reference"));
   ReportDOM.setDOM(reportString);
   ReportDOM.setNormal(); 
   ReportDOM.setPromoteSubElements("expenselist");
   Enh.setExp2Cat(ReportDOM);
   Enh.setTable("CHARGE");
   Enh.setSearch4("charge");
   Enh.setCompliment("reimb");
   Enh.setParentType("charge");
   Enh.setEnhancement("reimb");
   Enh.setGeneric(ReportDOM);
   GL.setReport(ReportDOM.getDOM()); 
   String submissionMsg = SystemDOM.getDOMTableValueFor("messages","submission_link","Submit expense report for approval and payment");
   java.util.Date now = new java.util.Date(); %> 
   
<script language="JavaScript">
var submitSafetyFlag = true;

function reclaimRef() {
  //JH 11-5-2003
  parent.contents.setNameValue(parent.contents.Header, "reference", "<%= SaveXML.getLastReference() %>");
}

function Submit() {
 if (parent.contents.HeadList.length > 0) {
   if (submitSafetyFlag) {
    submitSafetyFlag = false;
    // If not using SubmitFromGuideChk.html need to envoke the below.
    //var subdate = parent.contents.getNameValue(parent.contents.Header, "subdate");
    //if (subdate == "") {
    //   parent.contents.setNameValue(parent.contents.Header,"subdate",parent.contents.setDateStr(0));
    //   parent.contents.setNameValue(parent.contents.Header,"subtime",parent.contents.setTimeStr());
    //}
    document.forms[0].submit();
   }
 } else {
   alert("You cannot proceed with this option!\n\nThe current report doesn't contain any report purpose.\nIf you have entered data on a form, ensure\nthat you have clicked the grey button.\nOtherwise you will lose your data.");
 }

}
</script>
   
<body onLoad="reclaimRef()">
<h1>Report Submission: <%= now%></h1>
<% 
String homeCurrencyCheck = ";" + SystemDOM.getDOMTableValueFor("configuration","currency","US Dollar") + ";Local Currency;";
String reportCurrency = ReportDOM.getDOMTableValueFor("header","currency","US Dollar");
String omitGuideLines = SystemDOM.getDOMTableValueFor("configuration","omitguidelines","No");
if (!omitGuideLines.equalsIgnoreCase("Yes")) {
Log.println("[000] SubmitwithGuide.jsp using guidelines");
if (reportCurrency.equals("") || homeCurrencyCheck.indexOf(reportCurrency) > -1) { 
	 if (GL.getStatus().equalsIgnoreCase("passed")) { %>
	<%= Lang.getStringWithReplace("REPORT_PASSED_GUIDELINE","$guideType$",GL.getGuideType() )%><br><br>
	<% } else { %>    
	<%= Lang.getStringWithReplace("REPORT_FAILED_GUIDELINE","$guideType$",GL.getGuideType() )%><br><br>
	<% } %>
<br>
<%= GL.toString() %><br>
End of guideline check 
<% } //End of currency loop 
 } //End of guide choice loop %>
<%= request.getParameter("displayText") %>

<form method="get" action="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/<%= submitMethod %>"> 

<p><input type="button" value="<%= submissionMsg %>" name="B1"
onClick="Javascript: void Submit()"></p>

</form>

</body>
</html>

<% } else {
     Log.println("[500] SubmitwithGuide.jsp Register access failure for: " + PersFile.getEmailAddress()); 
%>
   <body>
     An error has been detected in accessing your personal report database (xmlr).<br>
     Please attempt to save your report again.  If the problem persists, contact support<br>
     immediately and do not close you browser.
   </body>
   </html>
   
<% }
%>
 
<% } else { %>

   <%@ include file="ReloginRedirectMsg.jsp" %>

<% } %>





