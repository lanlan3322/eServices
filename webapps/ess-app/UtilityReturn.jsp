<%--
XLogin.jsp - Entrance to the ESS system
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
     scope="request" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />   

<%@ include file="../DBAccessInfo.jsp" %>
<%@  include file="../Headers.jsp" %>
<%

   Log.println("[000] XLogin.jsp Access from: " + request.getRemoteAddr());

   if (PersFile != null && PersFile.active.equals("1")) { 
     if (PersFile.getChallengeCode().equals("")) {
        PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
     }
     Log.println("[320] XLogin.jsp " + PersFile.email + " is return from utilities from " + request.getRemoteAddr() + " under session ID: " + session.getId()); 
     // Log.setAddUser(email,session.getId(), request.getRemoteAddr(),PersFile.getName());  //JH 2006-10-12

     Lang.resetLanguage(PersFile.getLanguage());
%>
<%@  include file="../getDBase.jsp" %>
<%@  include file="../SystemInfo.jsp" %>
<%
     String email = PersFile.email; //normalizing the email address for pers data retrieval.
     String company = Sys.getSystemString("customfolder","ess"); //replaces the parameter coming in.
     String database = "";
%>

<%@  include file="XReport.jsp" %>
<%  

     Sys.closeMyState();

   } else { %>
       <HTML><BODY><strong><em><br/>
       <%= Lang.getString("ERROR_INVALID_LOGIN") %>
       </em></strong>
       </BODY></HTML>
<%   Log.println("[420] XLogin.jsp File email: " + PersFile.email);
     Log.println("[420] XLogin.jsp File name: " + PersFile.name);
     Log.println("[420] XLogin.jsp File active: " + PersFile.active);
     Log.println("[420] XLogin.jsp Remote IP: " + request.getRemoteAddr());
     PersFile.close();
   } %>

  

