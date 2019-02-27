<%--
DeleteReportItem.jsp - deletes an item from Report and database.  Report is a session object.

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
<jsp:useBean id = "ESS"
     class="ess.DB2Audit"
     scope="session" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<%   String transactionType = request.getParameter("tt");
     String referenceNo = request.getParameter("rr"); 
     String voucherNo = request.getParameter("vv");
     String status = request.getParameter("status"); //not used
     String email = request.getParameter("email"); %> 
<%-- Need to go and put the personnel/security checking here --%>
<%   String CCode = request.getParameter("ccode"); %>
<html>

<body onLoad="DeleteItem()">

<% if (transactionType.equalsIgnoreCase("purpose") && ESS.deletePurpose(referenceNo)) {   
%>
<a href="javascript: void parent.contents.writeDelayMsg('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/AuditReport.jsp?email=<%= PersFile.repStr(email,"'","\\'") %>&rcpt2=<%= ESS.getPrintableEmailAddress() %>&reference=<%= ESS.getPersNum() %>&voucher=<%= ESS.getVoucherNumber() %>&ccode=<%= CCode%>&status=<%= ESS.getReportStatus() %>')"><span class="ExpenseReturnLink">Purpose deletion successful - click here for report</span></a>

<% } else if (transactionType.equalsIgnoreCase("receipt") && ESS.deleteReceipt(referenceNo)) { 
%>
<a href="javascript: void parent.contents.writeDelayMsg('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/AuditReport.jsp?email=<%= PersFile.repStr(email,"'","\\'") %>&rcpt2=<%= ESS.getPrintableEmailAddress() %>&reference=<%= ESS.getPersNum() %>&voucher=<%= ESS.getVoucherNumber() %>&ccode=<%= CCode%>&status=<%= ESS.getReportStatus() %>')"><span class="ExpenseReturnLink">Receipt deletion successful - click here for report</span></a>

<%

  ESS.setReportTotalsForced();             // Maybe we can do this better later on
  if (ESS.setHeaderUpdate()) {
     Log.println("[000] DeleteReportItem.jsp item update succeeded");
  } else {
     Log.println("[500] DeleteReportItem.jsp balance update failed");
  }

} else { %>

Error - try again.  If problem persists, contact support
<%
}
%>
</body>

<script language="javascript">

function DeleteItem() {
   parent.contents.DirectEdit = true;
}

</script>

</html>

