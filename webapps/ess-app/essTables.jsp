<%--
essTables.jsp - list tables that can be displayed via Table.jsp
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
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<%@ include file="DBAccessInfo.jsp" %>
<%
   if (true) {%>
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>New Page </title>
</head>

<body>

<p><em><big><big><strong>Test tables:</strong></big></big></em></p>

<p><a href="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/Table.jsp?table=ACCOUNT"><em><strong>Expense Types</strong></em></a></p>

<p><a href="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/Table.jsp?table=CHARGE"><em><strong>Payment Types</strong></em></a></p>

<p><a href="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/Table.jsp?table=GUIDE"><em><strong>Guidelines</strong></em></a></p>

<p><a href="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/Table.jsp?table=COMPANY"><em><strong>Company Codes</strong></em></a></p>

<p><a href="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/Table.jsp?table=MILEAGE"><em><strong>Mileage Rates</strong></em></a></p>

<p><a href="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/Table.jsp?table=FX"><em><strong>Foreign Exhange Rates</strong></em></a></p>

<p><a href="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/Table.jsp?table=CURRENCY"><em><strong>Currency</strong></em></a></p>

<p><a href="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/Table.jsp?table=SYSTEM"><em><strong>Web Front End

<p>&nbsp;</p>
</body>
</html>
  
<% } else { %>
       <HTML><BODY>
       Error accessing - Please note that unauthorized usage of this utilitiy is being tracked.

       </BODY><HTML>
<% } %>
