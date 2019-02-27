<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />   
<jsp:useBean id="Address"
     class="ess.Address"
     scope="page" />
<%@  include file="../SystemInfo.jsp" %><%
Address.setConnection(PersFile.getConnection());
Address.setSQLTerminator(PersFile.getSQLTerminator());
String SQLCommand = "UPDATE ADDRESS SET SCAN_MODE = 'Rejected' WHERE ADDRESS = '$address$'";
SQLCommand = SystemDOM.getDOMTableValueFor("receiptmanagement","addressrejected",SQLCommand);
String phoneAddress = request.getParameter("address");

if (SQLCommand != null && !SQLCommand.equals("")) {
   SQLCommand = SysTable.SQLReplace(SQLCommand,"$address$",phoneAddress);

   int xReturn = Address.doSQLExecute(SQLCommand);

   if (xReturn == 1) { 
     Log.println("[249] RejectAddress.jsp address rejected: " + phoneAddress);
     %><%= phoneAddress %> has been rejected and cannot be used.  Contact support if you wish to use this device in the future.<%
   } else {
     Log.println("[549] RejectAddress.jsp error: " + phoneAddress + "[return code: " + Integer.toString(xReturn) + "]");
     %>Error in accepting device - contact support to confirm device.<%
   }
} 
%>