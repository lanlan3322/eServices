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
<html>

<body onLoad="LoadItem()">

Loading item from report...

</body>

<script language="javascript">

function LoadItem() {

   parent.contents.DirectEdit = true;
   var HeaderString = <%= ESSDisplay.getClientHeader() %>;
   parent.contents.NewReport();
   parent.contents.ProcessHeader(HeaderString);
   parent.contents.setNameValue(parent.contents.Header,"status","Audit");
   parent.contents.setNameValue(parent.contents.Header,"editable","Yes");
<% if (transactionType.equalsIgnoreCase("header")) {
   //Header edit
   //This section is proably not used
%>   parent.main.location = '<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/ess/reportHeader.html';
<% } else if (transactionType.equalsIgnoreCase("purpose")) {   
   //Purpose edit
   //This section is proably not used
     if (referenceNo == null || referenceNo.equals("")) {
        String screenName = request.getParameter("sc"); 
%>   var PurposeString = <%= ESSDisplay.getClientPurposes() %>;  //sb able to remove with change to Report.class for purpose number of 12-20-2005
     parent.contents.ProcessRepList('1',PurposeString);
     var Buffer = [];

     parent.contents.ListIndex = PurposeString.length;
     parent.main.location = '<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/ess/' + '<%=screenName %>.html';
<%   } else {
%>   var Buffer = <%= ESSDisplay.getClientPurpose(referenceNo) %>;
     parent.contents.ListBuffer = Buffer[0][parent.contents.$items$];
     parent.contents.ListIndex = 0;  //Do we need this
     parent.main.location = '<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/ess/' + Buffer[0][parent.contents.$type$] + '.html';
<%   }
%>   
<% } else if (transactionType.equalsIgnoreCase("receipt")) { 
%>   //This section is proably not used
     var PurposeString = <%= ESSDisplay.getClientPurposes() %>;
     parent.contents.ProcessRepList('1',PurposeString);
<%   if (referenceNo == null || referenceNo.equals("")) {
        String screenName = request.getParameter("sc"); 
        Log.println("[---] DisplayReportItem.jsp - ReceiptString (new) : " + "[]");
%>   //var ReceiptString = <%= ESSDisplay.getClientReceipts() %>;
     var ReceiptString = [];   //jh 2006-4-26
     parent.contents.ProcessRepList('2',ReceiptString);
     var Buffer = [];
     parent.contents.ListIndex = ReceiptString.length;
     parent.main.location = '<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/aa/' + '<%=screenName %>.html';
<%   } else {
     Log.println("[---] DisplayReportItem.jsp - ReceiptString (existing) : " + ESSDisplay.getClientReceipt(referenceNo));
%>   var Buffer = <%= ESSDisplay.getClientReceipt(referenceNo) %>;
     parent.contents.ListBuffer = Buffer[0][parent.contents.$items$];
     parent.contents.ListIndex = 0;  //Do we need this
     parent.main.location = '<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/aa/' + Buffer[0][parent.contents.$type$] + '.html';
<%   }
   } else if (transactionType.equalsIgnoreCase("display")) {
%>   var PurposeString = <%= ESSDisplay.getClientPurposes() %>;
     parent.contents.ProcessRepList('1',PurposeString);
     var Buffer = <%= ess.Utilities.replaceStr(ESSDisplay.getClientReceipt(referenceNo),"expenselist","displaylist") %>;
     parent.contents.ListBuffer = Buffer[0][parent.contents.$items$];
     parent.contents.ListIndex = 0;  //Do we need this
     parent.main.location = '<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/aa/' + Buffer[0][parent.contents.$type$].replace("receipt","display") + '.html';
<% 
} %>
}
</script>

</html>

