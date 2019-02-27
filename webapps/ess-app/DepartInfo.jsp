<%--
DepartInfo.jsp - creates depart DOM from table (include)
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
<%-- Must have a logfile --%>
<jsp:useBean id = "DepartDOM"
     class="ess.AdisoftDOM"
     scope="session" />
<%-- Set scope above to a broader range after initial test--%> 
<% if (!DepartDOM.getDOMProcessed()) {
     DepartDOM.setConnection(PersFile.getConnection());
     DepartDOM.setSQLTerminator(PersFile.getSQLTerminator());
     DepartDOM.setDOMFromTable("DEPART"); 
   }
%>