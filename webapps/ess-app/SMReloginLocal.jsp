<%--
ReloginLocal.jsp - relogin for the LESS system
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
   
   String email; 
   String loginClock = request.getHeader("sm-universalid");
   if (loginClock.length() > 2) loginClock = loginClock.substring(2);
   String company = request.getParameter("company"); 
   String database = request.getParameter("database");
   String profiledate = request.getParameter("profiledate");
   String lessscreen = request.getParameter("lessscreen");

   Log.println("[---] SMReloginLocal.jsp - " + securityContext);
   Log.println("[---] SMReloginLocal.jsp - " + loginClock);
   Log.println("[---] SMReloginLocal.jsp - " + company);
   Log.println("[---] SMReloginLocal.jsp - " + database);
   Log.println("[---] SMReloginLocal.jsp - " + profiledate);
   Log.println("[---] SMReloginLocal.jsp - " + DBDatabase);
   Log.println("[---] SMReloginLocal.jsp - " + DBUser);
   Log.println("[---] SMReloginLocal.jsp - " + DBPassword);

   if (DBDriver != null && !DBDriver.equals("")) {
       PersFile.setDBDriver(DBDriver);
   }

   if (database == null) {
     PersFile.setDB(DBDatabase,DBUser,DBPassword);  // This probably won't help but rather
   } else {
     PersFile.setDB(database,DBUser,DBPassword);  // drive the error further down.
   }
   PersFile.setSQLTerminator(DBSQLTerminator);
   PersFile.setSQLStrings();

   if (loginClock != null && PersFile.setPersNumInfo(loginClock) && PersFile.active.equals("1")) { 

     email = PersFile.getEmailAddress();

     PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey()); 
     session.putValue("loginAttempts", new java.lang.Integer(0));    %>
   
     <%@ include file="getDBase.jsp" %>

         <HTML><BODY onLoad="initValues()">
         <strong><em>Session activated.</em></strong><br>
         <script>
         function initValues() {
           var Timer
           if (parent.main)
           {
             Timer = setTimeout("parent.main.location = '<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ProfileFeed.jsp?email=<%= email%>&database=<%= database%>&company=<%= company%>&profiledate=<%= profiledate%>&ccode=<%= PersFile.getChallengeCode()%>'",2000);
           } else {
             Timer = setTimeout("window.location = '<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ProfileFeed.jsp?email=<%= email%>&database=<%= database%>&company=<%= company%>&profiledate=<%= profiledate%>&ccode=<%= PersFile.getChallengeCode()%>'",2000);
           }
         }
         </script>
         </BODY></HTML>

<%   Log.println("[224] SMReloginLocal.jsp " + PersFile.getEmailAddress() + " is relogged on from " + request.getRemoteAddr() + " under session ID: " + session.getId()); 
     Sys.closeMyState();

   } else { %>
       <HTML><BODY>
       Error accessing user account in <%= database %>.
       </BODY></HTML>
<%   Log.println("[400] SMReloginLocal.jsp " + loginClock + " has failed to relogin from " + request.getRemoteAddr()); 
   } %>
