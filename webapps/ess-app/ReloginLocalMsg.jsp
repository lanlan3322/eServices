<%--
ReloginLocalMsg.jsp - message for LESS relogin
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

<%
String securityContext2 = config.getServletContext().getInitParameter("ESSSecurity"); //JH 9-19-2003
if (securityContext2 == null) securityContext2 = "APPLICATION";
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>LESS Relogin Message Page</title>
</head>
<%
if (securityContext2.toUpperCase().equals("HOST") ) {
%>
  <body onLoad="formInit()">
  <form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ReloginLocal.jsp">
    <input type="hidden" name="company" value>
    <input type="hidden" name="database" value>
    <input type="hidden" name="email" value>
    <input type="hidden" name="profiledate" value>
    <input type="hidden" name="password">
  </form>
  <script language="javascript">
  function formInit() {
    with (document.forms[0]) {
      database.value = "<%= database %>";
      company.value = "k1"; //omit??
      email.value = "<%= email %>";
      password.value = "";
      profiledate.value = "<%= profileDateString %>";
      submit();
    }
  }
  </script> 
  </body>
<%
} else {
%>
  <body>
  <p><big><strong>Security check.</strong></big></p>
  <script language="javascript">
  var Timer = setTimeout("parent.main.location = '<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/LoginLocal.jsp?email=<%= email%>&database=<%= database%>&profiledate=<%= profileDateString%>'",2000);
  </script>
  </body>
<%
}
%>

</html>

