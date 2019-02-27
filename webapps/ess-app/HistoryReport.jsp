<%--
HistoryReport.jsp - Displays report from central db for investigations
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
<jsp:useBean id = "ESSDisplay"
     class="ess.DB2ESS"
     scope="session" />
<jsp:useBean id = "GL"
     class="ess.Guideline"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
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
   String depart = request.getParameter("depart");

boolean pFlag = PersFile.setPersInfo(reply2); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) {


   Log.println("[000] HistoryReport.jsp - Start - " + reply2); 
   
   // include file="StatusInfo.jsp"  {optional for older classes}

   ESSDisplay.setConnection(PersFile.getConnection());
   ESSDisplay.setSQLTerminator(PersFile.getSQLTerminator());
   ESSDisplay.setUpFiles();
   ESSDisplay.setLanguage(PersFile.getLanguage());
   ESSDisplay.setDateFormat(PersFile.getDateFormat());
   ESSDisplay.setDecimal(PersFile.getDecimal());
   ESSDisplay.setSeparator(PersFile.getSeparator());
   ESSDisplay.setSummaries("audithistory");
   
   GL.setConnection(PersFile.getConnection());
   GL.setSQLTerminator(PersFile.getSQLTerminator());
   GL.setLanguage(PersFile.getLanguage());   //Not active in legacy yet
   GL.setDateFormat(PersFile.getDateFormat());
   GL.setDecimal(PersFile.getDecimal());
   GL.setSeparator(PersFile.getSeparator());
//   GL.setSystemTable(Sys);   {optional for older classes}
   GL.setUpFiles();

   ESSDisplay.reset();
   ESSDisplay.setDenormalizeClient(true);
   ESSDisplay.set(voucher);
   ESSDisplay.setReportReferenceName("Voucher");
   PersFile.setReportViewed(ESSDisplay.getPreviousNumber());
   Log.println("[000] HistoryReport.jsp - Set - " + reply2); 

%>
<html>
<head>
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

<br/>
<% if (depart.equals("PWD")) { %>
<img src="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/ReportTitlePWD.jpg"></img>
<% } else { %>    
<img src="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/ReportTitleELC.jpg"></img>
<% } %> 


<hr/>

<!--
<%@ include file="StandardTop.jsp" %>
<% GL.setReport(voucher);%>
<% Log.println("[000] HistoryReport.jsp - G/L finished - " + reply2); %>
<%=ESSDisplay.printTitle(Lang.getString("databaseCopy")) %>-->
<small>
<%=ESSDisplay.printHeader() %>
<%=ESSDisplay.printTripByDay() %>
<!--
<%=ESSDisplay.printFleetItems() %>
<%=ESSDisplay.printAdvanceItems() %>
<%=ESSDisplay.printReceipts(true) %>
<% ess.DB2ESS ESS = ESSDisplay; %>
<br>-->
<%@ include file = "ScanImageList.jsp" %>
<br>
<!--
<%=ESSDisplay.printExpenseSummary() %>
<%=ESSDisplay.printDepartSummary() %>
<%=ESSDisplay.printExpenseGrid() %>
</small>
<br>
<%=ESSDisplay.printEApproval() %>
<br>
<small>
<%=ESSDisplay.printAuditInfo() %>
</small>

<p>Expense Guidelines</p>
<small>
Important Note: This report is being compared against the currently entered guidelines and not necessarily the guidelines in effect when the report was submitted.<br><br>
<% if (GL.getStatus().equalsIgnoreCase("passed")) { %>
<%= Lang.getStringWithReplace("REPORT_PASSED_GUIDELINE","$guideType$",GL.getGuideType() )%><br><br>
<% } else { %>    
<%= Lang.getStringWithReplace("REPORT_FAILED_GUIDELINE","$guideType$",GL.getGuideType() )%><br><br>
<% } 

String XchargeWarning = request.getParameter("CrossChargeWarning");
if (XchargeWarning == null) XchargeWarning = "Yes";
if (XchargeWarning.equals("Yes")) { %>
   <%=ESSDisplay.printCrossChargeWarning() %>
<% } %>
<%= GL.toString() %></small><br>
<small>
<%=ESS.printFleetEntries() %><br>
</small>
<br>
<%@ include file = "ScanImageDisplay.jsp" %>
-->
<br>
<br>
<br>
<%=ESSDisplay.SignatureBox() %>
<br>

<%@ include file="StandardBottom.jsp" %>

<script language="javascript">
  parent.contents.DirectEdit = false;  
  parent.contents.setDBPair(parent.PersDBase,"last_report", "<%= voucher %>");
</script>

</body>
</html>
<% Log.println("[000] HistoryReport.jsp - End - " + reply2); %>

<% } else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } %>


