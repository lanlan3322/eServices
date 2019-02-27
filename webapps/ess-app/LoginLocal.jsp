<%--
LoginLocal.jsp - Security check to the LESS application
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

<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<%
   String email = request.getParameter("email"); 
   String company = request.getParameter("company"); 
   String database = request.getParameter("database");
   String profiledate = request.getParameter("profiledate");
%>

<html>
<head>
<title>Relogin screen</title>
<link rel="stylesheet" href="expense.css" type="text/css"></head>

<body bgcolor="#FFFFFF" leftmargin="0" topmargin="0" marginheight="0" marginwidth="0"
link="#000000" vlink="#000000" alink="#EAEAEA" onLoad="formInit()">
<div class="ExpenseTag"><strong>

<p>To download information from the central system, please enter your password, press the
&quot;Login&quot;.</strong></div>
<strong></p>

<form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ReloginLocal.jsp">
  <input type="hidden" name="company" value="<%= company%>">
  <input type="hidden" name="database" value="<%= database%>">
  <input type="hidden" name="profiledate" value="<%= profiledate%>">
  <input type="hidden" name="lessscreen" value="yes">
  <strong><div align="center"><center><p>Email:</strong>
  <input type="text" name="email" size="35" value="<%= email%>"></strong></p>
  <strong><div align="center"><center><p>Password:</strong>
  <input type="password" name="password" size="13"></strong></p> 
  </center></div>
  <div align="center"><center><p>
  <input type="button" value="Login" name=" " tabindex="15" onClick="Javascript: void document.forms[0].submit()"> 
<script language="javascript">
function formInit() {
  with (document.forms[0]) {
    company.value = "k1"; //omit??
    password.focus();
  }
}
</script> </p>
  </center></div>
</form>
</body>
</html>
