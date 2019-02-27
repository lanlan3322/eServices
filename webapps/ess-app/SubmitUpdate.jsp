<%--
SubmitUpdate.jsp - sends updates from the Audit browser to central database
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
     class="ess.DBXML2ESS"
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

   Log.println("[000] SubmitUpdate.jsp run by: " + ownersName);

   String updateStatus = request.getParameter("statusupdate");

   ReportDOM.setConnection(PersFile.getConnection());
   ReportDOM.setSQLTerminator(PersFile.getSQLTerminator());

   //Enh.setDB(database,DBUser,DBPassword);
   Enh.setConnection(PersFile.getConnection());
   Enh.setSQLTerminator(PersFile.getSQLTerminator()); 

   ESS.setConnection(PersFile.getConnection());
   ESS.setSQLTerminator(PersFile.getSQLTerminator());
   ESS.setUpFiles();

   ESS.setReference("00000000");

   String report = request.getParameter("report");
   ReportDOM.setDOM(report); 
   ReportDOM.setDOM(request.getParameter("report")); 
   ReportDOM.setNormal(); 
   ReportDOM.setPromoteSubElements("expenselist");


   Enh.setSearch4("EXPENSE");
   Enh.setCompliment("CATEGORY");
   Enh.setExp2Cat(ReportDOM);

   Enh.setTable("CHARGE");
   Enh.setSearch4("CHARGE");
   Enh.setCompliment("REIMB");
   Enh.setParentType("charge");
   Enh.setEnhancement("reimb");
   Enh.setGeneric(ReportDOM);

   ESS.set(ReportDOM);

   boolean updateSuccessful = ESS.setUpdate();
   if (updateStatus != null) {
      Log.println("[000] SubmitUpdate.jsp status update routine would be here");
   }
%>
<html>
<head>
<link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
</head>
<body>
<%@ include file="StandardTop.jsp" %>
<%=ESS.printTitle("Audit Update Report") %>
<%
if (updateSuccessful) {
%>
<%=ESS.printHeader() %>
<%=ESS.printTripByDay() %>
<%=ESS.printFleetItems() %>
<%=ESS.printAdvanceItems() %>
<%=ESS.printReceipts() %>
<%=ESS.printExpenseSummary() %>
<%=ESS.printDepartSummary() %>
<br>
<%
} else {
%>

<br>
<h2>Update has failed - try again.<br>
If problem persists, contact support.</h2>
<br>
<%
}
%>

<%@ include file="StandardBottom.jsp" %>

</body>
<script>
//replace later on with SetDBGlobal()
     parent.contents.NewReport();
     parent.contents.ProcessHeader(parent.Header); 
     alert("Your report has been saved.  You may now start a new report if you wish.");

</script>
</html>
<%
} else { 
      Log.println("[000] PrintReport.jsp Relogin request"); %>
 <%@ include file="ReloginRedirectMsg.jsp" %>
<%
}
%>
