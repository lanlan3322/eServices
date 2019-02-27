<%--
AuditLogin.jsp - Audit module login control
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
<%@ include file="../DBAccessInfo.jsp" %>

<%
   String email = request.getParameter("email"); 
   String email2 = request.getParameter("email2"); 
   String password = request.getParameter("password");
 
   String database;

   Log.println("[000] AuditLogin.jsp Access from: " + request.getRemoteAddr());


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
   if (password == null) password = "";
   PersFile.setSQLStrings();
   
   String CurDateString = CD.xBaseDate.format(CD.date);

   boolean foundUser = false;
   if (PersFile.setPersInfo(email)) {
     Log.println("[000] AuditLogin.jsp primary login: " + email);
      foundUser = true;
   } else {
     Log.println("[000] AuditLogin.jsp secondary login attempt: " + email2);
     if (email2 != null) foundUser = PersFile.setPersInfo(email2);
     email = email2; 
   }
   if (foundUser && PersFile.validPassword(password.toUpperCase()) && PersFile.isAuditor()) { 
     PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
     Log.println("[220] AuditLogin.jsp " + PersFile.email + " is logged on from " + request.getRemoteAddr() + " under session ID: " + session.getId()); %>
<%@  include file="../getDBase.jsp" %>
<%@  include file="../SystemInfo.jsp" %>
<%   
     String company = Sys.getSystemString("customfolder","ess"); //replaces the parameter coming in.

     int days2Expire = Sys.getSystemInt("PWD_EXPIRES_DAYS");
     if (days2Expire == -1) days2Expire = 1000;

     String NewExpireDate; 
     if (PersFile.asofdate == null || PersFile.asofdate.equals("")) {
       NewExpireDate = "1980-01-01";
     } else {
       Log.println("[000] Login.jsp asofdate: " + PersFile.asofdate);
       NewExpireDate = CD.xBaseDate.format(CD.addDays(CD.getDateFromXBase(PersFile.asofdate), days2Expire));
     }
     if (CurDateString.compareTo(NewExpireDate) < 0 || days2Expire == 0) {
       session.putValue("loginAttempts", new java.lang.Integer(0));    %>
       <%-- Report.jsp needs to be aware of the PersFile object --%>
       <%@ include file="Audit.jsp" %>
<%   } else { %>
         <HTML><BODY>
         <strong><em>Your password has expired.  Please change your password.</em></strong><br><br>
         <a href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/<%=company%>/pwdChange.html">Click here to change your password</a>
         </BODY></HTML>
<%   }

     Sys.closeMyState();

   } else { %>
       <HTML><BODY><strong><em>
       <br>Cannot validate user and password - Retry login process.
       <br>If problem persists contact support.
       </em></strong>
       </BODY></HTML>
<%   Log.println("[420] AuditLogin.jsp invalid login attempt: " + email);
     Log.println("[420] AuditLogin.jsp File email: " + PersFile.email);
     Log.println("[420] AuditLogin.jsp File name: " + PersFile.name);
     Log.println("[420] AuditLogin.jsp File active: " + PersFile.active);
     Log.println("[420] AuditLogin.jsp Remote IP: " + request.getRemoteAddr());
     PersFile.close();
   } %>
