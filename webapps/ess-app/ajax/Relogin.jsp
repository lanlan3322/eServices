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
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />      
<jsp:useBean id = "CD"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Unescape"
class="org.apache.commons.lang.StringEscapeUtils"
scope="page" />               

<%@ include file="../DBAccessInfo.jsp" %>
<%
   String securityContext = config2.getInitParameter("ESSSecurity"); //JH 9-19-2003
   if (securityContext == null) securityContext = "APPLICATION";
   String email = request.getParameter("email"); 
   if (email != null)  email = Unescape.unescapeHtml(email);
   String password = request.getParameter("password");
   if (password != null)  password = Unescape.unescapeHtml(password);
   String language = request.getParameter("language"); 
   String database = DBDatabase;                          //Need to clean this up!!!!!

   if (DBDriver != null && !DBDriver.equals("")) {
       PersFile.setDBDriver(DBDriver);
   }
// Next 2 lines added 7/3/2007 -- get more info and 
   Log.println("[244] ajax/Relogin.jsp - session ID: " + session.getId() + ", IP address: " + request.getRemoteAddr()  + ", Personnel Number: " + PersFile.getPersNum()  + ", Email: " + email + ", Challenge Code: " + PersFile.getChallengeCode()); 
   PersFile.close();
   PersFile.setDB(database,DBUser,DBPassword);
   PersFile.setSQLTerminator(DBSQLTerminator);
   PersFile.setSQLStrings();
   PersFile.setLDAP(LDAPProvider,LDAPSearchPrincipal,LDAPCredentials,LDAPFactory,LDAPSearchString,LDAPEmailAttribute,LDAPPrincipalAttribute);
   
   Log.println("[000] ajax/Relogin.jsp - New connection established");

   if (PersFile.setPersInfo(email) && PersFile.active.equals("1") && (securityContext.equalsIgnoreCase("HOST") || PersFile.validPassword(password) && PersFile.active.equals("1"))) { 
     PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey()); 
     Lang.setLanguage(PersFile.getLanguage());
     session.putValue("loginAttempts", new java.lang.Integer(0));    %>
     <%@ include file="../getDBase.jsp" %>
~OK[<%= PersFile.getChallengeCode()%>]<%= Lang.getString("RELOGIN_OK") %>
<%   Log.println("[224] ajax/Relogin.jsp " + PersFile.email + " is relogged on from " + request.getRemoteAddr() + " under session ID: " + session.getId()); 
     Log.setAddUser(PersFile.email,session.getId(), request.getRemoteAddr(),PersFile.getName());  //JH 2006-10-12
     Sys.closeMyState();

   } else { 
     Lang.setLanguage(language);
%>
~NO<%= Lang.getString("ERROR_INVALID_RELOGIN_PASSWORD") %>
<%   Log.println("[400] ajax/Relogin.jsp " + email + " has failed to relogin from " + request.getRemoteAddr()); 
   } %>
