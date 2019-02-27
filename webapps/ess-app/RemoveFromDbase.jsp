<%--
RemoveFromDbase.jsp - removes a report from the central database
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
<%
String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String database = request.getParameter("database");

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
// Should we put in a level check here?
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { %> 
<%@ include file="StatusInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<html>
<head>
<link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
</head>
<body>
<%@ include file="StandardTopNR.jsp" %>
<br><br>
<strong><big><em>Reports Removed from Database<br>
<%= Dt.HTTPDate() %>
</em></big></strong><br>
<%
   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);
   byte[] bArray;    //used for encrypted values
   String E;         //     ditto

   String SQLCommand;
   String owner;
   String status;
   String reference;
   String canRemove;
   String report2Remove;
   String report2RemStat;
   String create_date;
   String receipt_amount;
   int voucherNumber = 0;
   boolean successFlag;

   String backcolor = "class=\"offsetColor\"";
   String oldbackcolor = "";
   String newbackcolor; 
   String errorcolor = "bgcolor=\"#FA8072\"";
   
   String[] removeCommands = SystemDOM.getDOMTableArrayFor("removereport","sql");

   SQLCommand = "SELECT ";
   SQLCommand += "NAME, RP_STAT, VOUCHER, CRE_DATE, RE_AMT ";
   SQLCommand += "FROM REPORT ";
   SQLCommand += "WHERE RTRIM(VOUCHER) = '$voucher$' AND RTRIM(RP_STAT) = '$status$'" + PersFile.getSQLTerminator();
   String removeConfirm = SystemDOM.getDOMTableValueFor("removereport","confirm",SQLCommand);
   
   java.util.StringTokenizer rp = new java.util.StringTokenizer(request.getParameter("reference"), ";"); 
   java.util.StringTokenizer st = new java.util.StringTokenizer(request.getParameter("status"), ";"); 
   
   Log.println("[000] RemoveFromDbase.jsp - references: " + request.getParameter("reference"));
   Log.println("[000] RemoveFromDbase.jsp - stati: " + request.getParameter("status"));
   
   String action = request.getParameter("xaction");
   boolean actionFlag;
   if (action.equals("remove")){
      actionFlag = true;
   } else {
      actionFlag = false;
%>    
     <br><strong><em>Invalid action criteria - contact support!</em></strong>
<%   
     Log.println("[500] RemoveFromDbase.jsp - Invalid action by " + ownersName);
   }
%>
   <form>
   <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
   <tr>
   <td width="10%"><u>Voucher</u></td>
   <td width="25%"><u>Owner</u></td>
   <td width="15%"><u>Created</u></td>
   <td width="20%"><u>Status</u></td>
   <td width="25%"><u>Action</u></td>
   </tr>
<%
   while (rp.hasMoreTokens() && actionFlag) {  
     report2Remove = rp.nextToken().trim() ;
     if (report2Remove.equals("X")) report2Remove = "";
     report2RemStat = st.nextToken().trim() ;
     voucherNumber = voucherNumber + 1;
     SQLCommand = removeConfirm;
     SQLCommand = Reg.SQLReplace(SQLCommand,"$voucher$",report2Remove);
     SQLCommand = Reg.SQLReplace(SQLCommand,"$status$",report2RemStat);
%> 
     <tr> 
<%
      if (Reg.setResultSet(SQLCommand)) {
           if (encrypt.equalsIgnoreCase("YES")) {
             bArray = Reg.myResult.getBytes(1);
             E = new String(bArray);
             owner = unScramble(E,encrypt,encryptKey);   
           } else {
             owner = PersFile.getTrim(Reg.myResult.getString(1));
           }
           status = PersFile.getTrim(Reg.myResult.getString(2));
           reference = PersFile.getTrim(Reg.myResult.getString(3));
           create_date = PersFile.getTrim(Reg.myResult.getString(4));
           receipt_amount = PersFile.getTrim(Reg.myResult.getString(5));
           canRemove = StatusDOM.getDOMTableValueWhere("default","translation",report2RemStat,"auditremoveallowed");
           successFlag = true;
           if (canRemove.equalsIgnoreCase("Yes")) { 
             for (int j = 0; j < removeCommands.length; j++) 
             {
                SQLCommand = Reg.SQLReplace(removeCommands[j],"$voucher$",report2Remove);
                if (Reg.doSQLExecute(SQLCommand) < 0) successFlag = false;
             }
            
             if (successFlag)
             {
%>              
                 <td width="10%"  <%=backcolor%>><%= report2Remove %></td>
                 <td width="25%"  <%=backcolor%>><%= owner %></td>
                 <td width="15%"  <%=backcolor%>><%= create_date %></td>
                 <td width="20%"  <%=backcolor%>><%= StatXlation(status, "default",StatusDOM) %></td>
                 <td width="25%"  <%=backcolor%>>Report removed</td>
<%
                 Log.println("[000] RemoveFromDbase.jsp - report " + report2Remove + ",  removed by " + PersFile.getPersNum() );
             } else {
%>              
                 <td width="10%"  <%=errorcolor%>><%= report2Remove %></td>
                 <td width="25%"  <%=errorcolor%>><%= owner %></td>
                 <td width="15%"  <%=errorcolor%>><%= create_date %></td>
                 <td width="20%"  <%=errorcolor%>><%= StatXlation(status, "default",StatusDOM) %></td>
                 <td width="25%"  <%=errorcolor%>>SQL Error - partial removal - investigate</td>
<%
                 Log.println("[500] RemoveFromDbase.jsp - Error removing report " + report2Remove + ",  by " + PersFile.getPersNum() );
             }
           } else { 
%>
             <td width="10%"  <%=errorcolor%>><%= report2Remove %></td>
             <td width="25%"  <%=errorcolor%>><%= owner %></td>
             <td width="15%"  <%=errorcolor%>><%= create_date %></td>
             <td width="20%"  <%=errorcolor%>><%= StatXlation(status, "default",StatusDOM) %></td>
             <td width="25%"  <%=errorcolor%>>Cannot remove report (datbase changed)</td>
<%   
             Log.println("[500] RemoveFromDbase.jsp - report status error " + report2RemStat);
           } 
      } else { 
%>
        <td width="10%"  <%=errorcolor%>><%= report2Remove %></td>
        <td width="25%"  <%=errorcolor%>></td>
        <td width="15%"  <%=errorcolor%>></td>
        <td width="20%"  <%=errorcolor%>></td>
        <td width="25%"  <%=errorcolor%>>Database access problem, report not removed</td>
<%  
        Log.println("[500] RemoveFromDbase.jsp - report removal " + report2Remove + " has a database access error [2]");
      } 
%>
   </tr>
<%
   newbackcolor = backcolor;
   backcolor = oldbackcolor; 
   oldbackcolor = newbackcolor;

   } //while
%>
   </table>
   </form>

<br><br>
<strong><em>End of report</em></strong>
<%@ include file="StandardBottomNR.jsp" %>
</body>
</html>

<% 
} else { 
     Log.println("[400] RemoveFromDbase.jsp timeout: " + ownersName); 
%>
     <%@ include file="ReloginRedirectMsg.jsp" %>
<%
}
%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>

