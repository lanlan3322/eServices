<%--
Login.jsp - Entrance to the ESS system
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
<%@ include file="DBAccessInfo.jsp" %>
<%@  include file="Headers.jsp" %>
<%
   if (PersFile != null && PersFile.active.equals("1")) { 
     Log.println("[320] LoginUtility.jsp " + PersFile.email + " is acccessing utilitiesn from " + request.getRemoteAddr() + " under session ID: " + session.getId() + ", challenge code: " + PersFile.getChallengeCode()); 

     String email = PersFile.email; 
     String database = "";
%>
<%@ include file="getDBase.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<%
     String company = Sys.getSystemString("customfolder","ess"); //replaces the parameter coming in.
    
%>
<%@ include file="Utilities.jsp" %>
<% 
   } else { %>
       <HTML><BODY><strong><em>
       <br>Cannot access this module.
       <br>If problem persists contact support.
       </em></strong>
       </BODY></HTML>
<%   Log.println("[420] LoginUtility.jsp invalid attempt");
     PersFile.close();
   } %>
