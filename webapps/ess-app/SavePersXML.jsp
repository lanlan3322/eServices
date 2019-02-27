<%--
SavePersXML.jsp - Saves personal data to the XMLU folder
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
<jsp:useBean id = "SavePers"
     class="ess.SavePersData"
     scope="page" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
     
<%@ include file="DBAccessInfo.jsp" %>
<%
String database = request.getParameter("database");
String ownersName = request.getParameter("email");
boolean pFlag = PersFile.setPersInfo(ownersName); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
     PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) {  
   boolean StatusFlag;
   SavePers.setConnection(PersFile.getConnection());
   SavePers.setSQLTerminator(PersFile.getSQLTerminator()); 
   SavePers.setFile(request.getParameter("persdbase"),ownersName); 
   if (SavePers.getStatus().equals("Saved")) { %>
     <html>
     <body onLoad="return2screen()">
     <br><br>Your personal data has been saved on the server.
  <% StatusFlag = true;
  } else { %>
     <html>
     <body>
     <br><br>There was difficulty saving your personal data.  Please try action again. If the problem persists, please contact support.
     <% StatusFlag = false;
  } %>

  <script langauge="JavaScript">

  function return2screen() {
  <% if (StatusFlag) { %>
       var timer = setTimeout("history.back()",2000);
  <% } %>
}
</script>
</body>
</html>
<% } else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } %>

