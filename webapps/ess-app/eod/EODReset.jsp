<%--
EODSave.jsp - Runs the EOD jobs to produce various output files
Copyright (C) 2004 R. James Holton

Note: Work in progress - This is not functional at this moment 2006-10-24

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
<jsp:useBean id = "DBConn"
     class="ess.AdisoftDbConn"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"  
     scope="application" />

<%@ include file="../DBAccessInfo.jsp" %>
<%
Log.println("[000] EODReset.jsp Access from: " + request.getRemoteAddr());

String database;

if (DBDatabase != null) {
   database = DBDatabase;
} else {
   database = request.getParameter("database");
}

DBConn.setDB(database,DBUser,DBPassword); 
// PersFile.setSQLStrings();

//////


String securityContext3 = config.getServletContext().getInitParameter("ESSSecurity"); //JH 9-19-2003
if (securityContext3 == null) securityContext3 = "APPLICATION";

String ownersName = request.getParameter("email");
String password = request.getParameter("password");
if (password == null) password = "";
String CCode = "";
String NeedPassword = "NO";
Log.println("[000] EODReset.jsp run by: " + ownersName);
boolean pFlag = PersFile.setPersInfo(ownersName); 

if (pFlag) {

  Log.println("[000] EODReset.jsp start");


  session.putValue("loginAttempts", new java.lang.Integer(0));


  boolean errorCondition = false; 

%>
<html>
<body>
<%-- @ include file="parameters.jsp" --%>
<strong><em>End of Day</em></strong><br>

<%

// Call EODSave.java as a separate thread for return performance
ess.EODSave EODThread = new ess.EODSave();

if (EODThread.getAlreadyRunning())
{
Log.println("[400] EODReset.jsp Thread already running");
EODThread.setProcessNotRunning(); 
Log.println("[400] EODReset.jsp Thread reset");

%>

<br><br><strong><em>File creation process has been reset.</em></strong>

<%

} else {

Log.println("[500] EODReset.jsp Thread reset - process not running.");

%>
 
<br><br><strong><em>File creation process was not active.</em></strong>

<%
}
%>

<script langauge="JavaScript">
</script>
</body>
</html>

<% 

Log.println("[000] EODReset.jsp finished");

} else { 

   java.lang.Integer xLoginTrys = (java.lang.Integer) session.getValue("loginAttempts");
   java.lang.Integer loginAttempts = new java.lang.Integer(4);
   if (xLoginTrys != null) {
      loginAttempts = xLoginTrys;
   }
   int numTrys;
   numTrys = loginAttempts.intValue() + 1;
   if (numTrys > 3 || securityContext3.equalsIgnoreCase("HOST")) {
     Log.println("[400] EODReset.jsp Invalid password (3X) for " + ownersName); 
%>
     <%@ include file="../ReloginRedirectMsg.jsp" %>
<% } else {
      session.putValue("loginAttempts", new java.lang.Integer(numTrys));
     Log.println("[400] EODReset.jsp Invalid password message for " + ownersName);
%>
     <%@ include file="../InvalidPasswordMsg.jsp" %>
<% } 

}
%>





