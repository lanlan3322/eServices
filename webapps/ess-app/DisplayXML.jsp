<%--
DisplayXML.jsp - testing routing to display the contents of the report send to the server
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

<%@ page contentType="text/xml" %>
<jsp:useBean id = "ReportDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "Enh"
     class="ess.Enhancement"
     scope="page" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<%@ include file="DBAccessInfo.jsp" %>

<% 
   ReportDOM.setDB(request.getParameter("database"),DBUser,DBPassword);
   Enh.setDB(request.getParameter("database"),DBUser,DBPassword);
   ReportDOM.setDOM(request.getParameter("report")); 

   ReportDOM.setNormal(); 
   ReportDOM.setPromoteSubElements("expenselist");

   Enh.setExp2Cat(ReportDOM);
   Enh.setTable("CHARGE");
   Enh.setSearch4("charge");
   Enh.setCompliment("reimb");
   Enh.setParentType("charge");
   Enh.setEnhancement("reimb");
   Enh.setGeneric(ReportDOM);
%>

<%=ReportDOM.toString() %>


