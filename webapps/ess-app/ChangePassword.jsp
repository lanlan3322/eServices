<%--
ChangePassword.jsp - Changes a users password
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
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="page" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="page" />
<jsp:useBean id = "Sys"
     class="ess.ServerSystemTable"
     scope="page" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Hash"
	class="ess.AdisoftHash"
	scope="session" />  

<%@ include file="DBAccessInfo.jsp" %>

<%
   String email = request.getParameter("email"); 
   String email2 = request.getParameter("email2"); 
   String password = request.getParameter("password");
   String newPwd1 = request.getParameter("newPwd1").trim();
   String newPwd2 = request.getParameter("newPwd2").trim();
   String company = request.getParameter("company"); 
   String database = request.getParameter("database");
   String changeScreen = request.getParameter("changeScreen");
   String loginScreen = request.getParameter("loginScreen");;
   
   PersFile.setDB(DBDatabase,DBUser,DBPassword);  
   PersFile.setSQLTerminator(DBSQLTerminator);
   PersFile.setSQLStrings();
%>
<%@ include file="SystemInfo.jsp" %>
<%
   Sys.setConnection(PersFile.getConnection());
   Sys.setSQLTerminator(DBSQLTerminator);
   Reg.setConnection(PersFile.getConnection());
   Reg.setSQLTerminator(DBSQLTerminator);

   //String usercolumn = SystemDOM.getDOMTableValueFor("passwordchange","updatesql");
   
   String newAsOfDate = Dt.xBaseDate.format(Dt.date);
   String SQLDate;

   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   if (SQLType.equals("MM/DD/YYYY")) { 
     SQLDate = Dt.simpleDate.format(Dt.date);
   } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
     SQLDate = Dt.getOracleDate(Dt.date);
   } else { //generate YYYY-MM-DD
     SQLDate = newAsOfDate;
   } 

   int minimumPwdLength = Sys.getSystemInt("PWD_MINIMUM_LENGTH");
   if (minimumPwdLength == -1) minimumPwdLength = 7;

   String hashType = SystemDOM.getDOMTableValueFor("configuration","hashtype","none");

   boolean foundUser = false;

   int xReturn = -1;


   if (PersFile.active.equals("1")) {
     Log.println("[000] ChangePassword.jsp primary login: " + email);
      foundUser = true;
   }

   if (foundUser) { %>
   <%-- Report.jsp needs to be aware of the PersFile object --%>
<%   if (newPwd1.equals(newPwd2) && newPwd1.length() >= minimumPwdLength) {

       String SQLCommand = SystemDOM.getDOMTableValueFor("passwordchange","updatesql");
       SQLCommand = Reg.SQLReplace(SQLCommand,"$email$",PersFile.getEmailAddress());
       if (hashType.equalsIgnoreCase("md5"))
       {
		SQLCommand = Reg.SQLReplace(SQLCommand,"$password$",Hash.Hash(newPwd1));
       } else {	
       		SQLCommand = Reg.SQLReplace(SQLCommand,"$password$",Reg.repStr(newPwd1.toUpperCase()));
       } 
       SQLCommand = Reg.SQLReplace(SQLCommand,"$date$",SQLDate);

       xReturn = Reg.doSQLExecute(SQLCommand);

       if (xReturn == 1) { 
         Log.println("[240] ChangePassword.jsp succeeded: " + email);
         PersFile.password = newPwd1; 
         PersFile.asofdate = newAsOfDate; %>
         <HTML><BODY>
         <strong><big><em>Your password has been changed. Please keep it secure.</em></big></strong><br><br>
         <a href="javascript: void document.forms[0].submit()">Enter expense system</a>
         <form method="POST" action="<%= loginScreen %>">
         <input type="hidden" name="company" value="<%= company%>">
         <input type="hidden" name="database" value="<%= database%>">
         <input type="hidden" name="email" value="<%= PersFile.getEmailAddress()%>">
         <input type="hidden" name="password" value="<%= newPwd1%>">
         </FORM>
         </BODY></HTML>
<%     } else { %>
         <HTML><BODY>
<%         
         if (xReturn == -1) {   
            Log.println("[500] ChangePassword.jsp update failure (SQL/access error): " + email); 
%>
            Update process failed (access error) - please try again.  If problem persists please contact support.<br><br>

<%       } else if (xReturn > 1) {
            Log.println("[400] ChangePassword.jsp update failure (Multiple records found): " + email);
%>
            Update problem: Multiple user records have been changed.<br><br>

<%       } else { 
            Log.println("[500] ChangePassword.jsp update failure (Bizarre error): " + email);
%>
            Update process failed (bizarre error) - please try again.  If problem persists please contact support.<br><br>
<%       } 
%>
         <a href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/ess/<%= changeScreen %>">Click here to try again</a>
         </BODY></HTML>
<%     }
     } else { %>
<%       Log.println("[400] ChangePassword.jsp mismatch failure: " + email); %>
       <HTML><BODY>
       Incorrect format or new passwords do not match.  Please try to change your password again.<br><br>
       <a href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %><%= changeScreen %>">Click here to try again</a>
       </BODY></HTML>
<%   }
   } else { %>
<%       Log.println("[400] ChangePassword.jsp user not found: " + email); %>
       <HTML><BODY>
       Error accessing user account.  Please try again or contact support.
       </BODY></HTML>
<% } %>
