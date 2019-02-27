<%--
EODSave.jsp - Runs the EOD jobs to produce various output files
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


<%@ include file="../DBAccessInfo.jsp" %>

<%
Log.println("[000] EODLaunch.jsp start");

String securityContext3 = config.getServletContext().getInitParameter("ESSSecurity"); //JH 9-19-2003
if (securityContext3 == null) securityContext3 = "APPLICATION";

String ownersName = request.getParameter("email");
String password = request.getParameter("password");
if (password == null) password = "";
String CCode = "";
String NeedPassword = "NO";

boolean pFlag = PersFile.setPersInfo(ownersName); 

if (pFlag) {

  session.putValue("loginAttempts", new java.lang.Integer(0));

  String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
  String database = request.getParameter("database");

  boolean errorCondition = false; 

  java.util.StringTokenizer rp = new java.util.StringTokenizer(request.getParameter("voucher"), ";"); 
  java.util.StringTokenizer st = new java.util.StringTokenizer(request.getParameter("status"), ";"); 

 
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

%>
 
<br><br><strong><em>Error - File creation process is already running.</em></strong>
<br><strong><em>Please try to run it later.</em></strong>
<%

} else {
EODThread.setPersFile(PersFile);
EODThread.setVoucherList(rp);
EODThread.setStatusList(st);

Thread threadx = new Thread(EODThread);

threadx.start();

%>
 
<br><br><strong><em>File creation process has been launched.</em></strong>
<br><strong><em>You will be notified by e-mail upon completion.</em></strong>

<%
}
%>

<script langauge="JavaScript">
</script>
</body>
</html>

<% 

Log.println("[000] EODLaunch.jsp finished");

} else { 

   java.lang.Integer xLoginTrys = (java.lang.Integer) session.getValue("loginAttempts");
   java.lang.Integer loginAttempts = new java.lang.Integer(4);
   if (xLoginTrys != null) {
      loginAttempts = xLoginTrys;
   }
   int numTrys;
   numTrys = loginAttempts.intValue() + 1;
   if (numTrys > 3 || securityContext3.equalsIgnoreCase("HOST")) {
     Log.println("[400] EODSave.jsp Invalid password (3X) for " + ownersName); %>
     <%@ include file="../ReloginRedirectMsg.jsp" %>
<% } else {
      session.putValue("loginAttempts", new java.lang.Integer(numTrys));
%>
     <%@ include file="../InvalidPasswordMsg.jsp" %>
<% } 

}
%>
<%@ include file="../UnScramble.jsp" %>
<%@ include file="../StatXlation.jsp" %>
<%@ include file="../DepartRouteRule.jsp" %>




