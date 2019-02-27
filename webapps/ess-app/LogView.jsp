<%--
Log Object View - Shows who's on the ESS system, etc.
Copyright (C) 2006 R. James Holton

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

<% Log.println("[270] LogView.jsp URL IP access from " + request.getRemoteAddr()); 
String ownersName = PersFile.getPersNum();  // trying something new.
Log.println("[271] LogView.jsp URL email: " + request.getParameter("email"));
Log.println("[272] LogView.jsp personnel table email: " + PersFile.getEmailAddress());
Log.println("[273] LogView.jsp personnel table pers number: " + ownersName);
boolean pFlag = ((ownersName != null) && (!ownersName.equals(""))); 

if (pFlag) {

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Log Object View</title>
</head>
<body>
<big><strong>Application Usage Report</strong></big><br><br>
<em><strong>List of current users:</strong></em>
<br><br>
<table>
<tr><td><u>Email</u></td><td><u>Session</u></td><td><u>IP Address</u></td><td><u>Name</u></td></tr>
<%
java.util.ArrayList x = Log.getUserList();
String[] y;

for (int i = 0; i < x.size(); i++)
{
   y = (String[]) x.get(i);
%>   
<tr><td><%= y[0] %></td><td><%= y[1] %></td><td><%= y[2] %></td><td><%= y[3] %></td></tr>
<%
Log.println("[000] LogView.jsp current User: " + y[0] + ", " + y[1] + ", " + y[2] + ", " + y[3]);
}
%>
</table>
<br><br><em><strong>List of reports possibly in use by auditors:</strong></em>
<br><br>
<table>
<tr><td><u>Reference</u></td><td><u>Session</u></td><td><u>Name</u></td></tr>
<%
x = Log.getReportList();

for (int i = 0; i < x.size(); i++)
{
   y = (String[]) x.get(i);
%>   
<tr><td><%= y[0] %></td><td><%= y[1] %></td><td><%= y[2] %></td></tr>
<%
Log.println("[000] LogView.jsp reports possibly in use: " + y[0] + ", " + y[1] + ", " + y[2]);
}
%>
</table>
<br><br>---End of Lists---<br>
</body>
</html>

<%
}
%>