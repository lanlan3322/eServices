<%--
SystemAndSecurityInfo.jsp - access to security.xml as a DOM
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

<%-- Must be included after DBAccessInfo.jsp --%>
<jsp:useBean id = "SystemDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "SecurityDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "SysTable"
     class="ess.ServerSystemTable"
     scope="page" />
<% SysTable.setConnection(PersFile.getConnection());
   if (!SystemDOM.getDOMProcessed()) {
     SysTable.setSQLTerminator(DBSQLTerminator);
     String system_file = SysTable.getSystemString("XMLSYSTEM","C:\\WORK\\"); 
     java.io.File SystemFile = new java.io.File(system_file);
     SystemDOM.setSQLTerminator(DBSQLTerminator);
     SystemDOM.setDOM(SystemFile);
   }
   if (!SecurityDOM.getDOMProcessed()) {
     String security_file = SystemDOM.getDOMTableValueFor("configuration","xmlsecurity"); 
     java.io.File SecurityFile = new java.io.File(security_file);
     SecurityDOM.setSQLTerminator(DBSQLTerminator);
     SecurityDOM.setDOM(SecurityFile);
   }
%>