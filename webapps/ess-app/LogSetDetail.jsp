<%--
Log Set Detail - Sets the logging level either high (true) or low (false).
Copyright (C) 2008 R. James Holton

This program is free software; you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation; either version 2 of the License, or (at your option) 
any later version.  This program is distributed in the hope that it will be 
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
10 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
Public License for more details.

You should have received a copy of the GNU General Public License along with 
this program; if not, write to the Free Software Foundation, Inc., 
675 Mass Ave, Cambridge, MA 02139, USA. 
--%>

<%@ page contentType="text/html" %>

<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />

<% Log.println("[270] LogSetDetail.jsp IP access from " + request.getRemoteAddr()); 
String ownersName = PersFile.getPersNum();  // trying something new.
Log.println("[271] LogSetDetail.jsp URL email: " + request.getParameter("email"));
boolean pFlag = ((ownersName != null) && (!ownersName.equals(""))); 

if (pFlag) {

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Log Object View</title>
</head>
<body>
<big><strong>Setting Log Detail</strong></big><br><br>
<em><strong>Logging detail information: <%= Log.setDetailLog() %> </strong></em>
<% Log.println("[277] LogSetDetail.jsp Detail level is: " + Log.getDetailLog()); %>
<br><br><br>---End---<br>
</body>
</html>

<%
}
%>