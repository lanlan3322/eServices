<%--
PrepopInfo.jsp - DOM to map prepop items to correct expense types
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

<%-- Must be included after SystemInfo.jsp --%>
<%-- Review scope of these 2 beans --%>
<jsp:useBean id = "Mapping"
     class="ess.PrepopulatedMapping"
     scope="application" />
<%    
   String prepop_file = SysTable.getSystemString("XMLPREPOPULATEDMAP","C:\\WORK\\"); 
   java.io.File PrepopFile = new java.io.File(prepop_file);
   Mapping.setDOM(PrepopFile); 
%>