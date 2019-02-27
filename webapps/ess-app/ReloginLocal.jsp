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
   
   String email = request.getParameter("email"); 
   //String email = request.getHeader("sm-user");

   String password = request.getParameter("password");
   String company = request.getParameter("company"); 
   String database = request.getParameter("database");
   String profiledate = request.getParameter("profiledate");
   String lessscreen = request.getParameter("lessscreen");

   Log.println("[---] ReloginLocal.jsp - " + securityContext);
   Log.println("[---] ReloginLocal.jsp - " + email);
   Log.println("[---] ReloginLocal.jsp - " + password);
   Log.println("[---] ReloginLocal.jsp - " + company);
   Log.println("[---] ReloginLocal.jsp - " + database);
   Log.println("[---] ReloginLocal.jsp - " + profiledate);
   //Log.println("[---] ReloginLocal.jsp - " + lessscreen);
   Log.println("[---] ReloginLocal.jsp - " + DBDatabase);
   Log.println("[---] ReloginLocal.jsp - " + DBUser);
   Log.println("[---] ReloginLocal.jsp - " + DBPassword);

   if (database == null) {
     PersFile.setDB(DBDatabase,DBUser,DBPassword);  // This probably won't help but rather
   } else {
     PersFile.setDB(database,DBUser,DBPassword);  // drive the error further down.
   }
   PersFile.setSQLTerminator(DBSQLTerminator);
   PersFile.setSQLStrings();

   if (PersFile.setPersInfo(email) && PersFile.active.equals("1") && (securityContext.toUpperCase().equals("HOST") || PersFile.password.toUpperCase().equals(password.toUpperCase()) && PersFile.active.equals("1"))) { 

   //if (email != null && PersFile.setPersInfo(email) && PersFile.active.equals("1")) { 

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

<%   Log.println("[224] ReloginLocal.jsp " + PersFile.email + " is relogged on from " + request.getRemoteAddr() + " under session ID: " + session.getId()); 
     Log.setAddUser(PersFile.email,session.getId(), request.getRemoteAddr(),PersFile.getName());  //JH 2006-10-12
     Sys.closeMyState();

   } else { %>
       <HTML><BODY>
       Error accessing user account in <%= database %>.
       </BODY></HTML>
<%   Log.println("[400] ReloginLocal.jsp " + email + " has failed to relogin from " + request.getRemoteAddr()); 
   } %>
