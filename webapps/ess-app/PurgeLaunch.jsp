<%--
PurgeLaunch.jsp - Runs the receipt image download in the background
Copyright (C) 2004, 2012 R. James Holton

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
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />

<%
Log.println("[380] PurgeLaunch.jsp Access from: " + request.getRemoteAddr());
%>
<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<%

String securityContext3 = config.getServletContext().getInitParameter("ESSSecurity"); //JH 9-19-2003
if (securityContext3 == null) securityContext3 = "APPLICATION";

String ownersName = request.getParameter("email");
String password = request.getParameter("password");
if (password == null) password = "";
String CCode = "";
String NeedPassword = "NO";

boolean pFlag = PersFile.setPersInfo(ownersName); 

if (pFlag) {

  Log.println("[000] PurgeLaunch.jsp start");


  session.putValue("loginAttempts", new java.lang.Integer(0));


  boolean errorCondition = false; 

 
%>
<html>
<body>
<%-- @ include file="parameters.jsp" --%>
<strong><em>Register Purge Process</em></strong><br>

<%

// Call EODSave.java as a separate thread for return performance
// WorkFlow(int task, String DBUrl, String DBUser, String DBPassword, String DBSQLTerminator)
// task2perfomr 0 = get mail, 1 = process mail, 2 = test message
int task2perform = 0;
ess.RegisterPurge Purge = new ess.RegisterPurge(DBDatabase, DBUser, DBPassword, DBSQLTerminator);

if (Purge.getAlreadyRunning())
{
Log.println("[400] PurgeLaunch.jsp Thread already running error");  //Check about using as a toggle switch
%>
 
<br><br><strong><em>Error - Register purge is already running.</em></strong>

<%

} else {

Thread threadx = new Thread(Purge);

threadx.start();

%>
 
<br><br><strong><em>Register purge has been launched.</em></strong>

<%
}
%>

<script langauge="JavaScript">
</script>
</body>
</html>

<% 

Log.println("[000] PurgeLaunch.jsp finished");

} else { 

   java.lang.Integer xLoginTrys = (java.lang.Integer) session.getValue("loginAttempts");
   java.lang.Integer loginAttempts = new java.lang.Integer(4);
   if (xLoginTrys != null) {
      loginAttempts = xLoginTrys;
   }
   int numTrys;
   numTrys = loginAttempts.intValue() + 1;
   if (numTrys > 3 || securityContext3.equalsIgnoreCase("HOST")) {
     Log.println("[400] PurgeLaunch.jsp Invalid password (3X) for " + ownersName); %>
     <%@ include file="ReloginRedirectMsg.jsp" %>
<% } else {
      session.putValue("loginAttempts", new java.lang.Integer(numTrys));
%>
     <%@ include file="InvalidPasswordMsg.jsp" %>
<% } 

}
%>


