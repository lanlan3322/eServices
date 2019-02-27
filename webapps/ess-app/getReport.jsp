<%--
getReport.jsp - Downloads report from XMLR to browser
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
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />           
     
<%
String database = request.getParameter("database");
String ownersName = request.getParameter("email");
String CCode = request.getParameter("ccode");
String reference  = request.getParameter("reference");
String repEdit = request.getParameter("edit");
String status = request.getParameter("status");
%>

<h2><%= Lang.getString("REPORT_BEING_DOWNLOADED") %></h2>

<span language="javascript" id="script" file="ajax/getReportJS.jsp?email=<%= ownersName%>&reference=<%= reference.trim()%>&ccode=<%= CCode%>&status=<%= status%>&edit=<%= repEdit%>&database=<%= database%>')" folder="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder()%>"></span>
