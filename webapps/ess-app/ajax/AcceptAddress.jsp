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
String SQLCommand = "UPDATE ADDRESS SET SCAN_MODE = 'Upload' WHERE ADDRESS = '$address$'";
SQLCommand = SystemDOM.getDOMTableValueFor("receiptmanagement","addressconfirmed",SQLCommand);
String phoneAddress = request.getParameter("address");

if (SQLCommand != null && !SQLCommand.equals("")) {
   SQLCommand = SysTable.SQLReplace(SQLCommand,"$address$",phoneAddress);

   int xReturn = Address.doSQLExecute(SQLCommand);

   if (xReturn == 1) { 
     Log.println("[248] AcceptAddress.jsp address confirmed: " + phoneAddress);
     %>You can use <%= phoneAddress %> to send receipt scans.<%
   } else {
     Log.println("[548] AcceptAddress.jsp error: " + phoneAddress + "[return code: " + Integer.toString(xReturn) + "]");
     %>Error in accepting device - contact support to confirm device.<%
   }
} 
%>
