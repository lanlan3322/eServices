<%--
ResetPassword.jsp - resets a password for the event that the user forgot it
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
     scope="page" />
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="session" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Sys"
     class="ess.ServerSystemTable"
     scope="session" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />

<%@ include file="DBAccessInfo.jsp" %>
<%
   String email = request.getParameter("email"); 
   String password = request.getParameter("password");
   String resetUser = request.getParameter("resetUser");
   String resetPassword = request.getParameter("resetPassword");
   String company = request.getParameter("company"); 
   String database = request.getParameter("database");
   if (DBDatabase != null) {
       database = DBDatabase;
   } else {
       database = request.getParameter("database");
   }

   if (DBDriver != null && !DBDriver.equals("")) {
       PersFile.setDBDriver(DBDriver);
   }
   PersFile.setDB(database,DBUser,DBPassword);
   PersFile.setSQLTerminator(DBSQLTerminator);
   PersFile.setSQLStrings();
%>
<%@ include file="SystemAndSecurityInfo.jsp" %>
<%
   Sys.setConnection(PersFile.getConnection());
   Sys.setSQLTerminator(DBSQLTerminator);
   Reg.setConnection(PersFile.getConnection());
   Reg.setSQLTerminator(DBSQLTerminator);

   int minimumPwdLength = Sys.getSystemInt("PWD_MINIMUM_LENGTH");
   if (minimumPwdLength == -1) minimumPwdLength = 7;

   boolean foundUser = false;

   int xReturn = -1;

   if (PersFile.setPersInfo(email)) {
     Log.println("[000] ResetPassword.jsp primary login: " + email);
      foundUser = true;
   } else {
     Log.println("[000] ResetPassword.jsp personnel record not found: " + email);
   }

   boolean securityOfficer = true;
   if (SecurityDOM.getDOMTableValueWhere("resetpasswords","email",PersFile.getTrim(email),"email") == "") {
     securityOfficer = false;
     Log.println("[000] ResetPassword.jsp unauthorized to reset passwords: " + email);
   } 

   if (foundUser && securityOfficer && PersFile.validPassword(password.toUpperCase())) { %>
   <%-- Report.jsp needs to be aware of the PersFile object --%>
<%   if (resetPassword.length() >= minimumPwdLength) {

       String SQLCommand = SystemDOM.getDOMTableValueFor("passwordchange","resetsql");
       SQLCommand = Reg.SQLReplace(SQLCommand,"$email$",Reg.repStr(resetUser.toUpperCase()));
       SQLCommand = Reg.SQLReplace(SQLCommand,"$password$",resetPassword.toUpperCase());
       String SQLBlankDate = SystemDOM.getDOMTableValueFor("sql","blankdate");
       SQLCommand = Reg.SQLReplace(SQLCommand,"$date$",SQLBlankDate);  // used to force psw change
// Need to check for blanks before executing the SQL statement
       xReturn = Reg.doSQLExecute(SQLCommand);

       if (xReturn == 1) { 
         Log.println("[240] ResetPassword.jsp succeeded: " + resetUser);

%>
         <HTML><BODY>
         <strong><big><em>Password for <%= resetUser%> has been reset.</em></big></strong><br><br>
<%
// Consider putting in an email send process
%>
         </BODY></HTML>
<%     } else { %>
         <HTML><BODY>
<%         
         if (xReturn == -1) {   
            Log.println("[500] ResetPassword.jsp update failure (SQL/access error): " + resetUser); 
%>
            Update process failed (access error) - please try again.  If problem persists please contact support.<br><br>
<%       } else if (xReturn > 1) {
            Log.println("[400] ResetPassword.jsp update failure (Multiple records found): " + email);
%>
            Update problem: Multiple user records have been changed.<br><br>
<%       } else { 
            Log.println("[500] ResetPassword.jsp update failure (Bizarre error): " + email);
%>
            Update process failed (bizarre error) - please try again.  If problem persists please contact support.<br><br>
<%       } 
%>
         <a href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/ess/pwdReset.html">Click here to try again</a>
         </BODY></HTML>
<%     }
     } else { %>
<%       Log.println("[400] ResetPassword.jsp account not updated: " + resetUser); %>
       <HTML><BODY>
       Cannot update user's password.  Please verify <%= resetUser %> is correct and try again.<br><br>
       <br><br>If problem continues, contact support.<br><br>
       <a href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/ess/pwdReset.html">Click here to try again</a>
       </BODY></HTML>
<%   }
   } else { %>
<%   Log.println("[400] ResetPassword.jsp user cannot perform reset: " + email); 
     Log.println("[420] ResetPassword.jsp File email: " + PersFile.email);
     Log.println("[420] ResetPassword.jsp File name: " + PersFile.name);
     Log.println("[420] ResetPassword.jsp File level: " + PersFile.level);
     Log.println("[420] ResetPassword.jsp File active: " + PersFile.active);
%>
     <HTML><BODY>
     Error accessing user <%= email %> account in <%= database %>.
     Have you entered your correct email and password? <br><br>
     <a href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/ess/pwdReset.html">Click here to try again</a>
     </BODY></HTML>
<% } %>
