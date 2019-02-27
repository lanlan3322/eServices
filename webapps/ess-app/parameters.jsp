<%--
parameters.jsp - Debug utility to include into a JSP to list a forms parameters
Copyright (C) 2004,2007 R. James Holton

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

<big> These are the parameters </big><br>
<%
String ParamName;
String ParamValue;
for (java.util.Enumeration e = request.getParameterNames(); e.hasMoreElements();){
     ParamName = (String) e.nextElement();
     ParamValue = request.getParameter(ParamName); %>
<%= ParamName %> = <%= ParamValue %><br> 
<%       
}
%>
<br> end of parameters<br><br><br>
<big> These are the headers </big><br>
<%
for (java.util.Enumeration e = request.getHeaderNames(); e.hasMoreElements();){
     ParamName = (String) e.nextElement();
     ParamValue = request.getHeader(ParamName); %>
<%= ParamName %> = <%= ParamValue %><br> 
<%       
}
%>
<br> end of headers<br>


