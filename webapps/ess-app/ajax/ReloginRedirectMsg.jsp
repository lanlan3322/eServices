<%--
ReloginRedirectMsg.jsp - Message lets user know they need to log back in
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

<%-- Assumes SystemDOM is in the JSP that this gets embedded into --%>
<%-- Assumes Language (Lang) is part of the parent also --%>

<%
Log.println("[407] ajax/ReloginRedirectMsg.jsp event");
String securityContext2 = config.getServletContext().getInitParameter("ESSSecurity"); //JH 9-19-2003
if (securityContext2 == null) securityContext2 = "APPLICATION";

if (securityContext2.toUpperCase().equals("HOST") ) {
%>
  <p><big><big><strong><%= Lang.getString("EXPIRED_NETWORK_LOGIN") %></strong></big></big></p>

<%
} else {
%>

<jsp:useBean id = "SysTb"
     class="ess.ServerSystemTable"
     scope="page" />

<%
// Want to deal with the database being passed in with the borwser
   SysTb.setDB(DBDatabase, DBUser, DBPassword);
   SysTb.setSQLTerminator(DBSQLTerminator);

  String defaultURL = SysTb.getSystemString("webserver", "") + "/"
                      + SysTb.getSystemString("webfolder", "ess");
  
  Log.println("[408] ajax/ReloginRedirectMsg.jsp URL: " + defaultURL);  
  // Lang.getString("EXPIRED_SESSION_LOGIN")

%>
<div id="infoLogin">
<form action="javascript: void submitRec()">
  <input type="hidden" name="email" value>
   <input type="hidden" name="language" value>
  <span id="reloginMessage"></span>
  <label for="password"><span id="reloginPassword">password</span></label>
  <input type="password" name="password" size="13">
  <input id="btEnter" type="submit" value="Login" name=" " tabindex="15"> 
</form>  
</div>
  <script language="javascript" id="script" folder="<%= defaultURL %>" file="shared/relogin.js"/>
<%
}
%>



