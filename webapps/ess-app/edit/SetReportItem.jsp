<%--
GetReportItem.jsp - downloads a since transaction to the browser.  Report is a session object.

Copyright (C) 2005 R. James Holton

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
     class="ess.DB2Audit"
     scope="session" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />

<%@ include file="../DBAccessInfo.jsp" %>
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

   Log.println("[000] SetReportItem.jsp run by: " + ownersName);

   ReportDOM.setConnection(PersFile.getConnection());
   ReportDOM.setSQLTerminator(PersFile.getSQLTerminator());

   Enh.setConnection(PersFile.getConnection());
   Enh.setSQLTerminator(PersFile.getSQLTerminator()); 

   ESS.setReference("00000000");
   ESS.setDateFormat(PersFile.getDateFormat());  //JH 2011-04-20
   
   String report = request.getParameter("report");
   Log.println("[000] SetReportItem.jsp Report Paramenter: " + report);
   ESS.setDenormalizeClient(true);

   ReportDOM.setDOM(report); 
   boolean previousAllowEmptyText = ReportDOM.getAllowEmptyText();
   ReportDOM.setAllowEmptyText(true);
   ReportDOM.setNormal(); 
   ReportDOM.setAllowEmptyText(previousAllowEmptyText);
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

   ESS.set(ReportDOM);  //Later can tweek this for the type of update
   ESS.setHeaderWithStatus(); //Adds the report status to items that can be updated.
   boolean updateSuccessful = false;

   if (!PersFile.getPersNum().equals(ESS.getPersNum()))
   {
      updateSuccessful = ESS.setUpdate();
      if (updateSuccessful) {            
         ESS.setReportTotalsForced();             // Maybe we can do this better later on
         if (ESS.setHeaderUpdate()) {
            Log.println("[000] SetReportItem.jsp item update succeeded");
         } else {
            Log.println("[500] SetReportItem.jsp balance update failed");
            updateSuccessful = false;
         }
      } else {
         Log.println("[500] SetReportItem.jsp item update failed!");
      }
   } else {
      Log.println("[520] SetReportItem.jsp item update failed - auditor attempted to audit own report!");
   }


%>
<html>
<head>
<link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
</head>
<script language="JavaScript">
function SetDelay() {
<%
   if (updateSuccessful) {
%>
       setTimeout("GoToReport()", 2000);
<%
   } else {
%>
      //No timer set as an error occurred
<%
   }
%>

}
function GoToReport() {
    parent.main.location = "<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/AuditReport.jsp?email=<%= PersFile.repStr(ownersName,"'","\\'") %>&rcpt2=<%= ESS.getPrintableEmailAddress() %>&reference=<%= ESS.getPersNum() %>&voucher=<%= ESS.getVoucherNumber() %>&ccode=<%= CCode%>&status=<%= ESS.getReportStatus() %>&database=<%= database%>#receiptsSection";
}
</script>
<body onLoad="SetDelay()">
<%
if (updateSuccessful) {
%>


<a href="javascript: void parent.contents.writeDelayMsg('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/AuditReport.jsp?email=<%= PersFile.repStr(ownersName,"'","\\'") %>&rcpt2=<%= ESS.getPrintableEmailAddress() %>&reference=<%= ESS.getPersNum() %>&voucher=<%= ESS.getVoucherNumber() %>&ccode=<%= CCode%>&status=<%= ESS.getReportStatus() %>&database=<%= database%>#receiptsSection')"><span class="ExpenseReturnLink">Update successful - click here for report</span></a>


<%
   //Later, take this out
   //ESS.setDenormalizeClient(false);
   //Log.println("[---] SetReportItem.jsp Success Dump:\n" + ESS.toString());
   //ESS.setDenormalizeClient(true);
} else {
%>

<br>
<h2>Update has failed - try again.<br>
If problem persists, contact support.</h2>
<br>
<%
   ESS.setDenormalizeClient(false);
   Log.println("[500] SetReportItem.jsp Error Dump:\n" + ESS.toString());
   ESS.setDenormalizeClient(true);
}
%>

</body>

</html>
<%
} else { 
      Log.println("[000] SetReportItem Relogin request"); %>
 <%@ include file="../ReloginRedirectMsg.jsp" %>
<%
}
%>
