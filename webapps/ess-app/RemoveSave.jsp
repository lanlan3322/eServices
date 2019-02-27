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
     scope="session" />
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

<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="RemoveInfo.jsp" %>
<%
String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String database = request.getParameter("database");

//PersFile.setDB(database,DBUser,DBPassword);
Reg.setConnection(PersFile.getConnection()); 
Reg.setSQLTerminator(PersFile.getSQLTerminator());
boolean errorCondition = false; 
String ownersName = request.getParameter("email");
boolean pFlag = PersFile.setPersInfo(ownersName); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { %> 
<%@ include file="SystemInfo.jsp" %>

<html>
<body>
<%-- @ include file="parameters.jsp" --%>
<strong><em>Following is your result:</em></strong><br>
<%
   String SQLCommand;
   String owner;
   String status;
   String reference;
   String newStatusCode;
   String newTranslation;
   String report2Remove;
   String report2RemStat;
   int voucherNumber = 0;

   SQLCommand = "SELECT ";
   SQLCommand += "OWNER, STATUS, REFERENCE ";
   SQLCommand += "FROM REGISTER ";
   SQLCommand += "WHERE RTRIM(REFERENCE) = '$reference$' AND RTRIM(STATUS) = '$status$'" + PersFile.getSQLTerminator();
   String removeConfirm = SystemDOM.getDOMTableValueFor("removeregister","confirm",SQLCommand);
   SQLCommand = "UPDATE REGISTER SET ";
   SQLCommand += "STATUS = '$status$' ";
   SQLCommand += "WHERE RTRIM(REFERENCE) = '$reference$'" + PersFile.getSQLTerminator();
   String removeSQL = SystemDOM.getDOMTableValueFor("removeregister","sql",SQLCommand);

   java.util.StringTokenizer rp = new java.util.StringTokenizer(request.getParameter("reference"), ";"); 
   java.util.StringTokenizer st = new java.util.StringTokenizer(request.getParameter("status"), ";"); 
   
   String action = request.getParameter("action");
   boolean actionFlag;
   if (action.equals("remove")){
      actionFlag = true;
   } else {
      actionFlag = false;
%>    <br><strong><em>Invalid action criteria - contact support!</em></strong>
<%   Log.println("[500] RemoveSave.jsp - Invalid action by " + ownersName);
   }
   
   while (rp.hasMoreTokens() && actionFlag) {  
     report2Remove = rp.nextToken().trim() ;
     report2RemStat = st.nextToken().trim() ;
     voucherNumber = voucherNumber + 1;
     SQLCommand = removeConfirm;
     SQLCommand = Reg.SQLReplace(SQLCommand,"$reference$",report2Remove);
     // SQLCommand = Reg.SQLReplace(SQLCommand,"$voucher$",report2Remove);
     SQLCommand = Reg.SQLReplace(SQLCommand,"$status$",report2RemStat);
     SQLCommand = Reg.SQLReplace(SQLCommand,"$owner$",ownersName);
     
     if (Reg.setResultSet(SQLCommand)) {

           owner = Reg.myResult.getString(1);
           status = Reg.myResult.getString(2);
           reference = Reg.myResult.getString(3);
%>  
           <br> Report <%=report2Remove %> 
<%          
           newStatusCode = StatusDOM.getDOMTableValueWhere("status",report2RemStat,"remove");
           Log.println("[000] RemoveSave.jsp 1 - " + report2Remove + " " + status + " " + newStatusCode);
           newTranslation = StatusDOM.getDOMTableValueWhere("status",newStatusCode,"translation");
           Log.println("[000] RemoveSave.jsp 2 - " + report2Remove + " " + newStatusCode + " " + newTranslation);
           SQLCommand = removeSQL;
           SQLCommand = Reg.SQLReplace(SQLCommand,"$reference$",report2Remove);
           SQLCommand = Reg.SQLReplace(SQLCommand,"$status$",newStatusCode);
           SQLCommand = Reg.SQLReplace(SQLCommand,"$owner$",ownersName);
           if (!newStatusCode.equals("")) {
               if (Reg.doSQLExecute(SQLCommand) > -1) { 
%>
                 &nbsp;<%= newTranslation %>
<%
                 Log.println("[202] RemoveSave.jsp - report " + report2Remove + " removed by " + ownersName + " to " + newStatusCode);
               } else {
                %>   <br> Report <%=report2Remove %> -- database problem, report not removed 
                <%
                 Log.println("[500] RemoveSave.jsp - report removal " + report2Remove + " database access error [1]");
               } 
           } else { %>
             -<br> Report <%=report2Remove %> - xml problem, report not removed
        <%   Log.println("[500] RemoveSave.jsp - Bad Remove.xml file for " + report2RemStat);
           } %>
   <% } else { %>
         <br> Report <%=report2Remove %> -- database access problem, report not removed
     <%  Log.println("[500] RemoveSave.jsp - report removal " + report2Remove + " has a database access error [2]");
      } %>
<% } %>
<br><br><strong><em>End of process</em></strong>
<p align="center"><a href="javascript: void parent.contents.PersWindow('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/Intro.jsp')" tabindex="1"><em><strong>Return to your report list</strong></em></a></p>
<script langauge="JavaScript">
</script>
</body>
</html>

<% 
} else { 
     Log.println("[400] RemoveSave.jsp security object removed for " + ownersName); %>
     <%@ include file="ReloginRedirectMsg.jsp" %>
<%
}
%>

<%@ include file="StatXlation.jsp" %>

