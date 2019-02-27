<%--
RemoveEmailScan.jsp - updates registers with result of a remove report action
Copyright (C) 2012 R. James Holton

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
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="page" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />           
     

<%@ include file="../../DBAccessInfo.jsp" %>
<%@ include file="../../RemoveInfo.jsp" %>
<%
String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String database = request.getParameter("database");

//PersFile.setDB(database,DBUser,DBPassword);
Reg.setConnection(PersFile.getConnection()); 
Reg.setSQLTerminator(PersFile.getSQLTerminator());
boolean errorCondition = false; 
if (PersFile.isActive()) { %> 
<%@ include file="../../SystemInfo.jsp" %>
<%
   String SQLCommand;
   String owner;
   String reference;
   String pvoucher;

   SQLCommand = "DELETE FROM SCAN ";
   SQLCommand += "WHERE SCAN_REF = '$reference$'" + PersFile.getSQLTerminator();
   String removeSQL = SystemDOM.getDOMTableValueFor("receiptmanagement","removesql",SQLCommand);

   reference = request.getParameter("reference");
   pvoucher = request.getParameter("pvoucher");
   owner = request.getParameter("persnum");
   
   SQLCommand = removeSQL;
   SQLCommand = Reg.SQLReplace(SQLCommand,"$reference$",reference);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$pvoucher$",pvoucher);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",owner);
   if (Reg.doSQLExecute(SQLCommand) > -1) { 
      %>Scan Reference <%= reference %> has been removed<%	
      Log.println("[202] RemoveEmailScan.jsp - scan file reference " + reference + " removed");
   } else {
      %>Scan <%= reference %> -- database problem, scan file not removed<%
      Log.println("[500] RemoveEmailScan.jsp - scan file removal " + reference + " database access error [1]");
      Log.println("[500] RemoveEmailScan.jsp - report removal SQL: " + SQLCommand);
   } 
} else { 
     Log.println("[400] RemoveEmailScan.jsp security object removed for " + PersFile.getName()); %>
     <%@ include file="../ReloginRedirectMsg.jsp" %>
<%
}
%>
<%@ include file="../../StatXlation.jsp" %>


