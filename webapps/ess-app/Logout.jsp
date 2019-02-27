<%--
Logout.jsp - ends the users session
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
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" /> 
          
<%@ include file="DBAccessInfo.jsp" %>
<% 
String homepage = "";
String ownersName = request.getParameter("email");
boolean pFlag = PersFile.setPersInfo(ownersName); 
if (pFlag) { %>
  <%@ include file="StatusInfo.jsp" %>
  <%@ include file="SystemInfo.jsp" %>
<% 
  homepage = SystemDOM.getDOMTableValueFor("configuration","home_page");
  String browserLanguage = request.getParameter("language");
  if ((browserLanguage != null) && (!browserLanguage.equalsIgnoreCase("")))
  {
   Lang.setLanguage(browserLanguage);
  } else {
   Lang.setLanguage(PersFile.getLanguage());
  }
} else {
  Log.println("[400] Logout.jsp Redirect not possible.");
}


%>
<html>
<body onLoad="setTimeout('restart()',5000)"
>
<em><strong><strong>
<%= Lang.getString("logout_message","You have been logged off ESS") %>
</strong></strong></em>
</body>
<script Language="JavaScript">

function restart() {
<% if (!homepage.equals("")) {
%>
     window.location = "<%=homepage %>";
<%
   }
%>
}

</script>
</html>
<%
Log.println("[221] Logout.jsp " + PersFile.email + " is logged out, session ID: " + session.getId());
// check to see if email is valid before doing these next things
Log.setRemoveReports(session.getId());
Log.setRemoveUsers(session.getId());
PersFile.resetProfile();
PersFile.close(); 
session.invalidate();
%>
