<%--
recoverPostK1.jsp - reset prepop items for future reprocessing
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

<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "DB"
     class="ess.AdisoftDbase"
     scope="session" />
<jsp:useBean id = "DOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "Rep2"
     class="ess.Report2Client"
     scope="page" />
<jsp:useBean id = "DD"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<%@ include file="DBAccessInfo.jsp" %>
<% 
String database = request.getParameter("database");

DB.setConnection(PersFile.getConnection());
DB.setSQLTerminator(PersFile.getSQLTerminator()); 

DOM.setConnection(PersFile.getConnection());
DOM.setSQLTerminator(PersFile.getSQLTerminator()); 

String email = request.getParameter("email");
String xref = request.getParameter("xref"); 
String purpose = request.getParameter("purpose");

boolean pFlag = PersFile.setPersInfo(email); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 

%>
<%@ include file="SystemInfo.jsp" %>
<%@ include file="PrepopInfo.jsp" %>
<%

String VendorExpType = "";
String ParamName;
String ParamValue;
String[] ParamArray;
String XMLString = "<register><report>";
String SQLCommand;
boolean update_error = false;

String updateItem = SystemDOM.getDOMTableValueFor("prepopulatedrecovery","updateitem","UPDATE STATEMNT SET VND_STAT = 'XX' WHERE recno() = $recordcursor$" + PersFile.getSQLTerminator());
String selectItem = SystemDOM.getDOMTableValueFor("prepopulatedrecovery","selectitem","SELECT * FROM STATEMNT WHERE recno() = $recordcursor$" + PersFile.getSQLTerminator());

%>  

<%@ page contentType="text/html" %>
<html>
<head>
<title>Charge Recovery II</title>
</head>

<body onLoad="Javascript: void LoadPrePopWizard()">

<strong><big> These charges have been reset: </big></strong><br><br>

<table>
<%
for (java.util.Enumeration e = request.getParameterNames(); e.hasMoreElements();){
   ParamName = (String) e.nextElement(); 
   ParamArray = request.getParameterValues(ParamName); 
   for(int i = 0; i < ParamArray.length; i++) { 
     ParamValue = ParamArray[i];
     if (ParamName.equals("Trx")) {

       java.util.StringTokenizer st = new java.util.StringTokenizer(ParamValue,";");
       StatementLineItem S = new StatementLineItem();
       S.status = st.nextToken();
       S.charge = st.nextToken();
       S.originalCharge = S.charge;
       S.acctno = st.nextToken();
       S.reference = st.nextToken();
       S.amount = st.nextToken();
       S.xref = xref;
       S.purpose = purpose;
       S.recordCursor = st.nextToken();
%>
       <tr>
       <td><%= S.charge %>&nbsp;for&nbsp;</td><td><%= S.amount %></td><td>&nbsp;with&nbsp;reference&nbsp;<%= S.reference %></td>
       </tr>     
<%       
       SQLCommand = DB.SQLReplace(selectItem,"$recordcursor$",S.recordCursor);
       Log.println("[000] recoverPost.jsp:" + SQLCommand);
       DB.setResultSet(SQLCommand);

       SQLCommand = DB.SQLReplace(updateItem,"$recordcursor$",S.recordCursor);
       Log.println("[000] recoverPost.jsp:" + SQLCommand);
//Do we need to check for a zero or not a 1????
       if (DB.doSQLExecute(SQLCommand) == -1) {
         update_error = true; %>
         <br><br>Error update status in statement file - contact technical support<br><br>
<%     }
     }
   }
}

%>
</table>
<br><br><strong><big> End of reset process</big></strong><br><br>

<script language="JavaScript">
function LoadPrePopWizard() {
   // parent.contents.TransWindow(parent.contents.PersGetCreate('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/CreditFeed2j.jsp'));
}
</script>
</body>
</html>

<% } else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } %>


<%!

public String makeCurrency(String f) {
   String s = f + "00";
   int i = s.indexOf(".");
   return s.substring(0, i + 3);     
}

%>

<%@ include file="StatementLineItem.jsp" %>

