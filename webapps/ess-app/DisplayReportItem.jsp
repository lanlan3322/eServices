<%--
DisplayReportItem.jsp - downloads a since transaction to the browser.  Report is a session object.

Copyright (C) 2007 R. James Holton

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
<jsp:useBean id = "ESSDisplay"
     class="ess.DB2ESS"
     scope="session" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
     
<%   String transactionType = request.getParameter("tt");
     String referenceNo = request.getParameter("rr"); %> 

<%-- Need to go and put the personnel/security checking here --%>

function LoadItem() {

   parent.DirectEdit = true;
   var HeaderString = <%= ESSDisplay.getClientHeader() %>;
   parent.NewReport();
   parent.ProcessHeader(HeaderString);
   parent.setNameValue(parent.Header,"status","Audit");
   parent.setNameValue(parent.Header,"editable","Yes");
<% 
   if (transactionType.equalsIgnoreCase("display")) {
%>   var PurposeString = <%= ESSDisplay.getClientPurposes() %>;
     parent.ProcessRepList('1',PurposeString);
     var Buffer = <%= ess.Utilities.replaceStr(ESSDisplay.getClientReceipt(referenceNo),"expenselist","displaylist") %>;
     parent.ListBuffer = Buffer[0][parent.$items$];
     parent.ListIndex = 0;  //Do we need this
     var httpLink = '<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/<%= PersFile.getLanguage() %>/' + Buffer[0][parent.$type$].replace("receipt","display") + '.html';
     window.open(httpLink , 'Transaction', 'dependent=yes, width=700, height=540, screenX=580, screenY=420, resizable, titlebar=yes, menubar=yes, status=no, scrollbars=yes');
<% } %>
}
LoadItem();

