<%--
ImportInfo.jsp - Gets info needed by the report generator
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
<jsp:useBean id = "ImportDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "Sys"
     class="ess.ServerSystemTable"
     scope="page" />
<% 
   Sys.setConnection(PersFile.getConnection());
   Sys.setSQLTerminator(PersFile.getSQLTerminator());

   String report_file = Sys.getSystemString("XMLIMPORT","C:\\WORK\\"); 
   java.io.File ImportFile = new java.io.File(report_file);
   ImportDOM.setDOM(ImportFile); 
%>