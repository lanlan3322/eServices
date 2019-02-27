<%--
PrintReport.jsp - Print report based on the parameters sent in
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

   Log.println("[000] PrintReport.jsp started - " + ownersName);

   ReportDOM.setConnection(PersFile.getConnection());
   ReportDOM.setSQLTerminator(PersFile.getSQLTerminator());

   Enh.setDB(database,DBUser,DBPassword);
   Enh.setSQLTerminator(PersFile.getSQLTerminator()); 

   ESS.setConnection(PersFile.getConnection());
   ESS.setSQLTerminator(PersFile.getSQLTerminator());
   ESS.setUpFiles();

   GL.setConnection(PersFile.getConnection());
   GL.setSQLTerminator(PersFile.getSQLTerminator());
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

<% if (request.getParameter("ReportTitle").equals("Yes")) { %>
     <%=ESS.printTitle("Expense Report") %>
<% } %>
<small>
<% if (request.getParameter("ReportHead").equals("Yes")) { %>
<%=ESS.printHeader() %>
<% } %>
<% if (request.getParameter("ReportTrip").equals("Yes")) { %>
<%=ESS.printTripByDay() %>
<% } %>
<% if (request.getParameter("FleetExpenses").equals("Yes")) { %>
<%=ESS.printFleetItems() %>
<% } %>
<% if (request.getParameter("AdvanceItems").equals("Yes")) { %>
<%=ESS.printAdvanceItems() %>
<% } %>
<% if (request.getParameter("ReportRcpts").equals("Yes")) { %>
<%=ESS.printReceipts() %>
<% } %>
<% if (request.getParameter("ReportSumm").equals("Yes")) { %>
<%=ESS.printExpenseSummary() %>
<% } %>
<% if (request.getParameter("ReportDept").equals("Yes")) { %>
<%=ESS.printDepartSummary() %>
<% } %>
<% if (request.getParameter("ReportGrid").equals("Yes")) { %>
<%=ESS.printExpenseGrid() %>
<% } %>
<% if (request.getParameter("ReportGuide").equals("Yes")) { %>
<p><big>Expense Guidelines</big></p>
<small>
<% if (GL.getStatus().equals("Passed")) { %>
Report has passed the <%= GL.getGuideType()%> guideline check.<br><br>
<% } else { %>    
Report has FAILED the <%= GL.getGuideType()%> guideline check.<br><br> 
<% } %>
<% 
   String XchargeWarning = request.getParameter("CrossChargeWarning");
   if (XchargeWarning == null) XchargeWarning = "Yes";
   if (XchargeWarning.equals("Yes")) { %>
<%=ESS.printCrossChargeWarning() %>
<% } %>
<%= GL.toString() %></small><br>
<% } %>
</small>
<%-- Used either or of the following two --%>
<% if (request.getParameter("MoneyDue").equals("Yes")) { %>
<br>
<%=ESS.printMoneyDue() %>
<% } %>
<% if (request.getParameter("ReportAppr").equals("Yes")) { %>
<small>
<%=ESS.printApproval() %>
</small>
<% } %>
<%@ include file="StandardBottom.jsp" %>

</body>
</html>
<%
} else { 
      Log.println("[000] PrintReport.jsp Relogin request"); %>
 <%@ include file="ReloginRedirectMsg.jsp" %>
<%
}
%>
