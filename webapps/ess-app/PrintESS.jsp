<%--
PrintESS.jsp - Detailed Report
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
<jsp:useBean id = "ReportDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "Enh"
     class="ess.Enhancement"
     scope="page" />
<jsp:useBean id = "ESS"
     class="ess.XML2ESS"
     scope="page" />
<jsp:useBean id = "GL"
     class="ess.Guideline"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />

<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<% 
   String database = request.getParameter("database");
String CCode = "";
String ownersName = request.getParameter("email");
boolean pFlag = PersFile.setPersInfo(ownersName); 
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
}

if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 

   Log.println("[000] PrintESS.jsp started - " + ownersName);

   ReportDOM.setConnection(PersFile.getConnection());
   ReportDOM.setSQLTerminator(PersFile.getSQLTerminator());

   Enh.setConnection(PersFile.getConnection());
   Enh.setSQLTerminator(PersFile.getSQLTerminator()); 

   ESS.setConnection(PersFile.getConnection());
   ESS.setSQLTerminator(PersFile.getSQLTerminator());
   ESS.setUpFiles();

   GL.setConnection(PersFile.getConnection());
   GL.setSQLTerminator(PersFile.getSQLTerminator());
   //GL.setLanguage(PersFile.getLanguage());    //Not active in legacy yet
   //GL.setDateFormat(PersFile.getDateFormat());
   //GL.setDecimal(PersFile.getDecimal());
   //GL.setSeparator(PersFile.getSeparator());
   GL.setUpFiles();

   ESS.setReference("00000000");

   ReportDOM.setDOM(request.getParameter("report")); 
   ReportDOM.setNormal(); 
   ReportDOM.setPromoteSubElements("expenselist");
   Enh.setExp2Cat(ReportDOM);
   Enh.setTable("CHARGE");
   Enh.setSearch4("charge");
   Enh.setCompliment("reimb");
   Enh.setParentType("charge");
   Enh.setEnhancement("reimb");
   Enh.setGeneric(ReportDOM);
   ESS.set(ReportDOM);
   GL.setCompany(ESS.getCompany());
   GL.setReport(ReportDOM.getDOM());
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Print Expense Report</title>
<link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
<script type="text/javascript">
  if (screen.width < 1024) {
    var link = document.getElementsByTagName( "link" )[ 0 ];
    link.href = "<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense800.css";
  }
</script>
<link rel="stylesheet" media="print" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/print.css" type="text/css">
</head>
<body>
<%@ include file="StandardTop.jsp" %>

<%=ESS.printTitle("Detailed Expense Report") %>
<%=ESS.printHeader() %>
<%=ESS.printTripByDay() %>
<%=ESS.printFleetItems() %>
<%=ESS.printAdvanceItems() %>
<%=ESS.printReceipts() %>
<%=ESS.printExpenseSummary() %>
<%=ESS.printDepartSummary() %>
<%=ESS.printExpenseGrid() %>
<%
String homeCurrencyCheck = ";" + SystemDOM.getDOMTableValueFor("configuration","currency","US Dollar") + ";Local Currency;";
String reportCurrency = ReportDOM.getDOMTableValueFor("header","currency","US Dollar");
if (reportCurrency.equals("") || homeCurrencyCheck.indexOf(reportCurrency) > -1) { 
%>
<p><big>Expense Guidelines</big></p>
<small>
<% if (GL.getStatus().equalsIgnoreCase("passed")) { %>
<%= Lang.getStringWithReplace("REPORT_PASSED_GUIDELINE","$guideType$",GL.getGuideType() )%><br><br>
<% } else { %>    
<%= Lang.getStringWithReplace("REPORT_FAILED_GUIDELINE","$guideType$",GL.getGuideType() )%><br><br>
<% }  %>

<%= GL.toString() %></small><br>
<% } %>
<%=ESS.printApproval() %>

<%@ include file="StandardBottom.jsp" %>

</body>
</html>
<%
Log.println("[000] PrintESS.jsp end - " + ownersName);
} else { 
      Log.println("[000] PrintESS.jsp Relogin request"); %>
 <%@ include file="ReloginRedirectMsg.jsp" %>
<%
}
%>
