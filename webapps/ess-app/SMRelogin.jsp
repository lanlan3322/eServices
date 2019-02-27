<%--
Relogin.jsp - relogin in the event the session object times out
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
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "CD"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<%@ include file="DBAccessInfo.jsp" %>

<%
   String securityContext = config2.getInitParameter("ESSSecurity"); //JH 9-19-2003
   if (securityContext == null) securityContext = "APPLICATION";
   String email = request.getParameter("email"); 
   String loginClock = request.getHeader("sm-universalid");
   if (loginClock.length() > 2) loginClock = loginClock.substring(2);
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

<%
   if (loginClock != null && PersFile.setPersNumInfo(loginClock) 
     && PersFile.active.equals("1") && email.equalsIgnoreCase(PersFile.getEmailAddress())) 
     { 
     PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey()); 
     session.putValue("loginAttempts", new java.lang.Integer(0));    %>
   
     <%@ include file="getDBase.jsp" %>

         <HTML><BODY onLoad="initValues()">
         <strong><em>Your session has been renewed.</em></strong><br>
         <script>
         function initValues() {
           var workStr = parent.contents.LastHTMLFile;
           if (workStr != null && workStr != "") {
              parent.CCode = "<%= PersFile.getChallengeCode()%>";
              var regExp = /&ccode=\d*&/g
              parent.contents.LastHTMLFile = workStr.replace(regExp, "&ccode=" + parent.CCode + "&");
              var Timer = setTimeout("parent.contents.TransWindow(parent.contents.LastHTMLFile)",2000);
           }
         }
         </script>
         </BODY></HTML>

<%   Log.println("[224] SMRelogin.jsp " + PersFile.email + " is relogged on from " + request.getRemoteAddr() + " under session ID: " + session.getId()); 
     Log.setAddUser(PersFile.email,session.getId(), request.getRemoteAddr(),PersFile.getName());  //JH 2006-10-12
     Sys.closeMyState();

   } else { %>
       <HTML><BODY>
       Error accessing user account in <%= database %>.
       </BODY></HTML>
<%   Log.println("[400] SMRelogin.jsp " + email + " has failed to relogin from " + request.getRemoteAddr()); 
   } %>
