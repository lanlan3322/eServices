<%--
Check.jsp - Check item and return value or "Not Valid"
Copyright (C) 2008 R. James Holton

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

<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="page" />   
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />     
     
<%@ include file="DBAccessInfo.jsp" %>
<% 

response.setHeader("Cache-Control","no-cache"); //HTTP 1.1
response.setHeader("Pragma","no-cache"); //HTTP 1.0
response.setDateHeader ("Expires", 0); //prevents caching at the proxy server
String languageWanted = request.getParameter("language"); 
String message = request.getParameter("message");
Log.println("[000] GetMsg.jsp in " + languageWanted + " for " + message);
Lang.setLanguage(languageWanted);
%><%= Lang.getString(message) %>



