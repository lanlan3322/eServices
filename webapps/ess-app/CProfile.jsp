<%--
CProfile.jsp - Used as include by profile generates (e.g., ESSProfile.jsp) to setup support DOMs
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

<jsp:useBean id = "Extract"
     class="ess.EditTables"
     scope="page" />
<%@ include file="DBAccessInfo.jsp" %>
<% String db = request.getParameter("database");
   String folder = request.getParameter("folder");
   Extract.setDB(db,DBUser,DBPassword); 
   Extract.setSQLTerminator(DBSQLTerminator);
%>

<%-- Must be included after DBAccessInfo.jsp --%>
<jsp:useBean id = "SystemDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<%
    SystemDOM.setSQLTerminator(DBSQLTerminator);
%>
<jsp:useBean id = "SysTable"
     class="ess.ServerSystemTable"
     scope="page" />
<% SysTable.setDB(db,DBUser,DBPassword);
   SysTable.setSQLTerminator(DBSQLTerminator);
   if (!SystemDOM.getDOMProcessed()) {
     String system_file = SysTable.getSystemString("XMLSYSTEM","C:\\WORK\\"); 
     java.io.File SystemFile = new java.io.File(system_file);
     SystemDOM.setDOM(SystemFile);
      
   }
%>
<%-- Must be included after DBAccessInfo.jsp --%>
<jsp:useBean id = "StatusDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<% 
   String status_file = SysTable.getSystemString("XMLSTATUS","C:\\WORK\\"); 
   java.io.File StatusFile = new java.io.File(status_file);
   StatusDOM.setSQLTerminator(DBSQLTerminator);
   StatusDOM.setDOM(StatusFile); 
%>

