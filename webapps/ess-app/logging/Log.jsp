<%--
Log.jsp - logs a user and will send back a message if there is one
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
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" /> 
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" /> 
<jsp:useBean id = "ShutdownMessage"
     class="ess.MessageBean"
     scope="application" />    
<%

String email = request.getParameter("email"); 

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

<%
Log.println("[229] Log.jsp user is active: " + email + ", session: " + session.getId());
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Log</title>
</head>
<body>
<script>
//user profile is active
<%
String message = ShutdownMessage.getMessage();
if (message != null && !message.equals(""))
{
Log.println("[000] Log.jsp Shutdown Message sent: " + email);
%>
alert("<%= message %>");
<%
}
%>
</script>
</body>
</html>

<%
} else {


Log.println("[400] Log.jsp user profile not active: " + email + ", session: " + session.getId() + ", ccode: " + PersFile.getChallengeCode());
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Log</title>
</head>
<body>
<script>
alert("User is not currently logged into the central server.")
</script>
</body>
</html>
<%
} 
%>