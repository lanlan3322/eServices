<%--
ApproveReport.jsp - displays report along with approval option
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

<%@ page contentType="text/html" %>

<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "ESS"
     class="ess.DB2ESS"
     scope="page" />
<jsp:useBean id = "GL"
     class="ess.Guideline"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Sys"
     class="ess.ServerSystemTable"
     scope="page" />
<!-- check on the scope of the ServerSystemTavle -->
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Currency"
     class="ess.Currency"
     scope="session" />   
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />   
<jsp:useBean id = "Scan"
     class="ess.Scan"
     scope="session" />          

<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<% 
   String database = request.getParameter("database");
   String reference  = request.getParameter("reference");
   String voucher  = request.getParameter("voucher");
   String status = request.getParameter("status");
   String reply2 = request.getParameter("email");
   String rcpt2 = request.getParameter("rcpt2");

boolean pFlag = PersFile.setPersInfo(reply2); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
   Sys.setConnection(PersFile.getConnection()); 
   Sys.setSQLTerminator(PersFile.getSQLTerminator()); //JH 2006-3-1
   String NeedPassword = Sys.getSystemString("pwd_approval","yes");

   Log.println("[000] ApproveReport.jsp - Start - " + reply2); 
   
   ESS.setConnection(PersFile.getConnection());
   ESS.setSQLTerminator(PersFile.getSQLTerminator());
   ESS.setUpFiles();
   ESS.setLanguage(PersFile.getLanguage());
   ESS.setSummaries("legacyapprove");
   
   if (!Currency.isAlreadyLoaded()) {
     Currency.setConnection(PersFile.getConnection());
     Currency.setSQLTerminator(PersFile.getSQLTerminator()); 
     Currency.setSQLStrings();
   }

   GL.setConnection(PersFile.getConnection());
   GL.setSQLTerminator(PersFile.getSQLTerminator());
   //GL.setLanguage(PersFile.getLanguage());   //Not active in legacy yet
   //GL.setDateFormat(PersFile.getDateFormat());
   //GL.setDecimal(PersFile.getDecimal());
   //GL.setSeparator(PersFile.getSeparator());
   GL.setSystemTable(Sys); // JH 2006-03-01
   GL.setUpFiles();

   Log.println("[000] ApproveReport.jsp - Connect - " + reply2); 

   ESS.set(voucher);
   ESS.setReportReferenceName("Voucher");
   PersFile.setReportViewed(ESS.getPreviousNumber());
   
   GL.setCompany(ESS.getCompany());

   Log.println("[000] ApproveReport.jsp - Set - " + reply2); 

%>
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">

<script type="text/javascript">
  if (screen.width < 1024) {
    var link = document.getElementsByTagName( "link" )[ 0 ];
    link.href = "<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense800.css";
  }
</script>
<link rel="stylesheet" media="print" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/print.css" type="text/css">
</head>
<body onLoad="initForm()">

<%@ include file="StandardTop.jsp" %>

<% //if (request.getParameter("ReportTitle").equals("Yes")) { %>
<%=ESS.printTitle("Approval Copy") %>
<% //} %>

<small>

<%= ESS.printHeader() %>
<% Log.println("[000] ApproveReport.jsp - DB2 - " + reply2); 
String homeCurrencyCheck = ";" + SystemDOM.getDOMTableValueFor("configuration","currency","US Dollar") + ";Local Currency;";
String reportCurrency = ESS.getCurrency();
if (reportCurrency.equals("") || homeCurrencyCheck.indexOf(reportCurrency) > -1) { 
   GL.setReport(voucher);
   Log.println("[000] ApproveReport.jsp - DB2Guide - " + reply2); 
%>
<p><big>Expense Guidelines</big></p>
<small>
<% if (GL.getStatus().equalsIgnoreCase("passed")) { %>
<%= Lang.getStringWithReplace("REPORT_PASSED_GUIDELINE","$guideType$",GL.getGuideType() )%><br><br>
<% } else { %>    
<%= Lang.getStringWithReplace("REPORT_FAILED_GUIDELINE","$guideType$",GL.getGuideType() )%><br><br>
<% } 
   } %>

<%= ESS.printCrossChargeWarning() %>
<%
if (reportCurrency.equals("") || homeCurrencyCheck.indexOf(reportCurrency) > -1) { 
   Log.println("[000] ApproveReport.jsp - Guide - " + reply2); %>
<%= GL.toString() %></small><br>
<% } %>


<%=ESS.printTripByDay() %>

<%=ESS.printFleetItems() %>
<%=ESS.printAdvanceItems() %>

<%=ESS.printExpenseSummary() %>
<%=ESS.printReceipts() %>
<%@ include file="ScanImageList.jsp" %>

<%=ESS.printExpenseGrid() %>

</small>

<br>
<%=ESS.printConversion() %>
<%=ESS.printEApproval() %>

<table border="0" cellpadding="2" cellspacing="0" width="90%" class="offsetColor" style="border: 1px solid"><tr>
<tr><td width="100%">
<form name="Signoff" method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ApproveSave.jsp">
  <input type="hidden" name="email" value>
  <input type="hidden" name="company" value>
  <input type="hidden" name="ccode" value>
  <input type="hidden" name="database" value>
  <input type="hidden" name="voucher" value>
  <input type="hidden" name="reference" value>
  <input type="hidden" name="status" value>
  <input type="hidden" name="action" value>
  <input type="hidden" name="rcpt2" value>
  <input type="hidden" name="reply2" value>
<% if (NeedPassword.equalsIgnoreCase("NO"))
   {
%> 
  <input type="hidden" name="password" value="">
<% }
%>

  <table border="0" cellpadding="0" cellspacing="0" width="100%" height="38">
   <tr>
     <td width="40%" align="right"><strong>Action:&nbsp;</strong></td>
     <td width="60%" align="left"><input type="radio" value="result" checked name="actiontype"><em>
     <strong><%= Lang.getString("acceptReport") %></strong></em></td>
   </tr>
   <tr>
     <td width="40%" align="right"><strong></strong></td>
     <td width="60%" align="left"><input type="radio" name="actiontype" value="reject"><em>
     <strong><%= Lang.getString("rejectReport") %></strong></em></td>
   </tr>
   <tr>
     <td width="40%" align="right"><strong><%= Lang.getLabel("message") %>&nbsp;</strong></td>
     <td width="60%" align="left" valign="top"><textarea rows="2" name="msgdata" cols="29"></textarea></td>
   </tr>
   <tr>
     <td width="40%" align="right"><strong><%= Lang.getLabel("approvedBy") %>&nbsp;</strong></td>
     <td width="60%" align="left"><input type="text" name="name" size="20" readOnly=Yes></td>
   </tr>
<% if (!NeedPassword.equalsIgnoreCase("NO"))
   {
%> 
   <tr>
     <td width="40%" align="right"><strong><%= Lang.getLabel("password") %>&nbsp;</strong></td>
     <td width="60%" align="left"><input type="password" name="password" size="13"></td>
   </tr>
<% }
%>
   </table>
   <table border="0" cellpadding="0" cellspacing="0" width="100%" height="38">
   <tr>
   <td width="100%" align="center">
     <input type="button" value="<%= Lang.getString("PROCESS_REPORT") %>" name="B2" onClick="Javascript: void Approve()">
   </td>
   </tr> 
   </table>
</form>
</td></tr>
</table>

<br>
<small>
<%=ESS.printAuditInfo() %>
<%=ESS.printDepartSummary() %>
</small>
<br>

<%@ include file = "ScanImageDisplay.jsp" %>

<%@ include file="StandardBottom.jsp" %>

<script language="Javascript">

function initForm() {
  document.forms[0].name.value = parent.contents.getDBValue(parent.Header,"name");
  document.forms[0].reference.value = "<%= reference %>";
  document.forms[0].voucher.value = "<%= voucher %>";
  document.forms[0].email.value = parent.contents.getDBValue(parent.Header,"email");
  document.forms[0].company.value = parent.company;
  document.forms[0].ccode.value = parent.CCode;
  document.forms[0].database.value = parent.database;
  document.forms[0].status.value = "<%= status %>";
  document.forms[0].action.value = "result";
  document.forms[0].actiontype[0].checked = true;
  document.forms[0].rcpt2.value = "<%= rcpt2 %>";
  document.forms[0].reply2.value = "<%= reply2 %>";

//figure something out for reject
}
var submitSafetyFlag = true;
function Approve(){
  if (submitSafetyFlag) {
    var xfound = false;
    with (document.forms[0]) {
      for (var i = 0; i < actiontype.length; i++) {
        if (actiontype[i].checked == true) {
          action.value = actiontype[i].value;
          xfound = true;
        }
      }

      if (!xfound) {
        alert("action has not been checked!");
      } else if (action.value == "reject") {
        if (msgdata.value.length < 1) {
           alert("Must include message to reject report.");
           msgdata.focus();
        } else {
           if (confirm("Proceed to reject this report?")) {
             submit();
             submitSafetyFlag = false;
           }
        }
      } else if (action.value == "result") {
       <% if (NeedPassword.equalsIgnoreCase("NO")){
       %>
          if (confirm("'OK' to approve selected report. 'Cancel' to abort approval.")) {
       <% }
       %>
           submit();
           submitSafetyFlag = false;
       <% if (NeedPassword.equalsIgnoreCase("NO")){
       %>
          }
       <% }
       %>


      } else {
        alert("action not spcified - contact support!");
      }
    }
    return;
  }
}

</script>
</body>
</html>
<% Log.println("[000] ApproveReport.jsp - End - " + reply2); %>

<% } else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } %>
