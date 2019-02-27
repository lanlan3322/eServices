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
String ownersName = request.getParameter("email");
boolean pFlag = PersFile.setPersInfo(ownersName); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) {
//if (pFlag) { %> 
<%@ include file="../SystemInfo.jsp" %>


<%-- @ include file="parameters.jsp" --%>
<strong><em><%= Lang.getString("REM_FOLLOW") %></em></strong><br>
<%
   Log.println("[000] RemoveSave.jsp - started");
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

   String referenceParameter = request.getParameter("reference");
   String statusParameter = request.getParameter("status");
   
   Log.println("[000] RemoveSave.jsp reference: " + referenceParameter);
   Log.println("[000] RemoveSave.jsp status: " + statusParameter);
   
   java.util.StringTokenizer rp = new java.util.StringTokenizer(referenceParameter, ";"); 
   java.util.StringTokenizer st = new java.util.StringTokenizer(statusParameter, ";"); 
   
   String action = request.getParameter("action");
   boolean actionFlag;
   if (action.equals("remove")){
      actionFlag = true;
   } else {
      actionFlag = false;
%>    <br><strong><em><%= Lang.getString("REM_BAD_CRITERIA") %></em></strong>
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
           <br> <%= Lang.getString("REM_REPORT") %> <%=report2Remove %> 
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
                 &nbsp;<%= Lang.getDataString(newTranslation) %>
<%
                 Log.println("[202] ajax/RemoveSave.jsp - report " + report2Remove + " removed by " + ownersName + " to " + newStatusCode);
               } else {
                %>   <br> <%= Lang.getString("REM_REPORT") %> <%=report2Remove %> -- <%= Lang.getString("REM_DB_PROBLEM") %> 
                <%
                 Log.println("[500] ajax/RemoveSave.jsp - report removal " + report2Remove + " database access error [1]");
               } 
           } else { %>
             -<br> <%= Lang.getString("") %>Report <%=report2Remove %> -- <%= Lang.getString("REM_XML_PROBLEM") %>
        <%   Log.println("[500] ajax/RemoveSave.jsp - Bad Remove.xml file for " + report2RemStat);
           } %>
   <% } else { %>
         <br> <%= Lang.getString("REM_REPORT") %> <%=report2Remove %> -- <%= Lang.getString("REM_DB_PROBLEM") %>
     <%  Log.println("[500] ajax/RemoveSave.jsp - report removal " + report2Remove + " has a database access error [2]");
      } 
      Log.println("[000] RemoveSave.jsp - while end");
  } %>
<br><br><strong><em><%= Lang.getString("REM_END") %></em></strong>
<span language="Javascript" id="script" file="shared/blank.js" />

<% 
Log.println("[000] RemoveSave.jsp - end");
} else { 
     Log.println("[400] ajax/RemoveSave.jsp security object removed for " + ownersName); %>
     <%@ include file="ReloginRedirectMsg.jsp" %>
<%
}
%>

<%@ include file="../StatXlation.jsp" %>

