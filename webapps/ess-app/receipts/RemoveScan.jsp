<%--
RemoveSave.jsp - updates registers with result of a remove report action
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
     
<%@ include file="../DBAccessInfo.jsp" %>
<%@ include file="../RemoveInfo.jsp" %>
<%
String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String database = request.getParameter("database");

//PersFile.setDB(database,DBUser,DBPassword);
Reg.setConnection(PersFile.getConnection()); 
Reg.setSQLTerminator(PersFile.getSQLTerminator());
boolean errorCondition = false; 
if (PersFile.isActive()) { %> 
<%@ include file="../SystemInfo.jsp" %>

<html>
<body>
<strong><em>Following is your result:</em></strong><br>
<%
   String SQLCommand;
   String owner;
   String status;
   String reference;
   String newStatusCode;
   String newTranslation;
   String file2Remove;
   String file2RemPvoucher;

   // removeConfirm should give a blank resultSet if we can remove the item
   SQLCommand = "SELECT ";
   SQLCommand += "PERS_NUM, RP_STAT, PVOUCHER ";
   SQLCommand += "FROM REPORT WHERE PVOUCHER = '$pvoucher$' ";
   SQLCommand += "AND RP_STAT <> 'F0' AND RP_STAT < 'G3'" + PersFile.getSQLTerminator();
   String removeConfirm = SystemDOM.getDOMTableValueFor("receiptmanagement","removeconfirm",SQLCommand);

   // removeSQL does the actual deleting
   SQLCommand = "DELETE FROM SCAN ";
   SQLCommand += "WHERE SCAN_REF = '$reference$'" + PersFile.getSQLTerminator();
   String removeSQL = SystemDOM.getDOMTableValueFor("receiptmanagement","removesql",SQLCommand);

   file2Remove = request.getParameter("reference");
   file2RemPvoucher = request.getParameter("pvoucher");
     
   SQLCommand = Reg.SQLReplace(removeConfirm,"$pvoucher$",file2RemPvoucher);
 %>
 [<%= SQLCommand %>][<%=file2RemPvoucher %>][<%=file2Remove %>]<br>
 
 <%    
   if (!Reg.setResultSet(SQLCommand)) {

%>  
         <br> Scan Reference <%=file2Remove %> 
<%          
         SQLCommand = removeSQL;
         SQLCommand = Reg.SQLReplace(SQLCommand,"$reference$",file2Remove);
         SQLCommand = Reg.SQLReplace(SQLCommand,"$pvoucher$",file2RemPvoucher);
            if (Reg.doSQLExecute(SQLCommand) > -1) { 
              Log.println("[202] RemoveSave.jsp - scan file reference " + file2Remove + " removed");
            } else {
             %>   <br> Scan <%=file2Remove %> -- database problem, scan file not removed
             <%
              Log.println("[500] RemoveScan.jsp - scan file removal " + file2Remove + " database access error [1]");
              Log.println("[500] RemoveScan.jsp - report removal SQL: " + SQLCommand);
            } 
   } else { %>
      <br> Scan <%=file2Remove %> -- database access problem, file not removed
  <%  Log.println("[500] RemoveScan.jsp - report removal " + file2Remove + " has a database access error [2]");
      Log.println("[500] RemoveScan.jsp - report removal SQL: " + SQLCommand);
   } 
%>
<br><br><strong><em>End of process</em></strong>
<p align="center"><a href="javascript: void parent.contents.PersWindow('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/Intro.jsp')" tabindex="1"><em><strong>Return to your report list</strong></em></a></p>
<script langauge="JavaScript">
</script>
</body>
</html>

<% 
} else { 
     Log.println("[400] RemoveScan.jsp security object removed for " + PersFile.getName()); %>
     <%@ include file="../ReloginRedirectMsg.jsp" %>
<%
}
%>
<%@ include file="../StatXlation.jsp" %>



