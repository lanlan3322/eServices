<%--
SMLogin.jsp - special login (entrance) for SiteMinder 
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
<%@  include file="../Headers.jsp" %>
<%
   String database = config2.getInitParameter("DBDatabase");
   String company = config2.getInitParameter("DBCompany");
   String loginClock = request.getHeader("sm-universalid");
   if (loginClock.length() > 2) loginClock = loginClock.substring(2).toUpperCase();
   String email = loginClock;
   String remoteIP = request.getRemoteAddr();

//   String database = config2.getInitParameter("DBDatabase");
//   String company = config2.getInitParameter("DBCompany");
//   String loginClock = request.getParameter("sm_user");
//   String email = loginClock;
//   String remoteIP = request.getRemoteAddr();
   if (DBDatabase != null) {
       database = DBDatabase;
   } else {
       database = request.getParameter("database");
   }

   if (!DBDriver.equals("") && DBDriver != null) {
       PersFile.setDBDriver(DBDriver);
   }
   PersFile.setDB(database,DBUser,DBPassword); 
   PersFile.setSQLTerminator(DBSQLTerminator);
   PersFile.setSQLStrings();
   
   String CurDateString = CD.xBaseDate.format(CD.date);

   boolean foundUser = false;
   if (PersFile.setPersNumInfo(loginClock) && ValidIPAddress(remoteIP)) {
     Log.println("[000] SMLogin.jsp primary login: " + loginClock);
     foundUser = true;
     email  = PersFile.getEmailAddress();
   }

   if (foundUser && PersFile.active.equals("1")) { 
     PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
     Log.println("[220] SMLogin.jsp " + PersFile.email + " is logged on from " + request.getRemoteAddr() + " under session ID: " + session.getId()); 
     Log.setAddUser(PersFile.email,session.getId(), request.getRemoteAddr(),PersFile.getName());  //JH 2006-10-12
%>
<%@  include file="getDBase.jsp" %>
<%@  include file="SystemInfo.jsp" %>

<%       session.putValue("loginAttempts", new java.lang.Integer(0));    %>     
       <%-- Report.jsp needs to be aware of the PersFile object --%>
       <%@ include file="Report.jsp" %>
<%
     Sys.closeMyState();

   } else { %>
       <HTML><BODY><strong><em>
       <br>Cannot validate user and password - Retry login process.
       <br>If problem persists contact support.
       </em></strong>
       </BODY></HTML>
<%   Log.println("[420] SMLogin.jsp invalid login attempt: " + loginClock);
     Log.println("[420] SMLogin.jsp File name: " + PersFile.name);
     Log.println("[420] SMLogin.jsp File active: " + PersFile.active);
     PersFile.close();
   } %>

<%! public boolean ValidIPAddress(String X) {
   boolean retVal = true;
   if (X.equals("127.0.0.1")) retVal = true; //localhost
   if (X.equals("192.168.0.2")) retVal = true; //adisoft1
   if (X.equals("63.198.222.34")) retVal = true; //adisoft-inc.com
   if (X.equals("151.198.141.124")) retVal = true; //adisoft-inc.com
   return retVal;
}
%>