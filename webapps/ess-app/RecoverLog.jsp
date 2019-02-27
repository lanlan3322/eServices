<%--
RecoverLog.jsp - writes report to log in the event it has not been saved on browser shutdown
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
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<%@ include file="DBAccessInfo.jsp" %>
<% 
   String xDOM = request.getParameter("report");
   Log.println("[290] RecoverLog.jsp report safe-stored: " + xDOM);
   Log.println("[291] RecoverLog.jsp report session ID: "  + session.getId());
   Log.println("[292] RecoverLog.jsp report user name: " +  PersFile.name);
   Log.println("[293] RecoverLog.jsp report user email: " +  PersFile.getEmailAddress());
 
%>
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Invalid Exit Detected</title>
</head>

<body>

<p align="center"><em><strong><big>Warning - You may lose your expense report data!</big></strong></em></p>

<ul>
  <li><strong>You have exited the expense system without using the &quot;Logout&quot; option.
    &nbsp; In the future use the &quot;Logout&quot; option.</strong></li>
  <li><strong>The system has detected that you did not save your latest report changes or
    additions.&nbsp; If you need to recover this information, continue following the steps on
    this screen.&nbsp; Otherwise, you may close this browser window.</strong></li>
  <li><strong>To recovery any information that you didn't save, enter the expense application
    and access the &quot;Need Help?...&quot; screen.&nbsp; This link is in the upper right-hand
    corner of the browser screen.</strong></li>
  <li><strong>Click on the link marked &quot;Recovery&quot; at the bottom of the &quot;Need
    Help?...&quot; screen.</strong></li>
  <li><strong>The report you were working on will appear.&nbsp; If not, contact support for
    further help.</strong></li>
  <li><strong>After you have recovered the report, you should save it with the &quot;Save
    Report...&quot; menu option.</strong></li>
  <li><strong>You can now close this window.</strong></li>
</ul>

<p>&nbsp;</p>


</body>
</html>

