<%--
getDBReport.jsp - downloads a report to the browser.  Report is from central db.
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

<%@ page contentType="text/html" %>
<jsp:useBean id = "Rep2"
     class="ess.DB2Client"
     scope="page" />
<jsp:useBean id = "Sys"
     class="ess.ServerSystemTable"
     scope="page" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
     
<%@ include file="DBAccessInfo.jsp" %>

<% 
String ownersName = request.getParameter("email");
String voucher = request.getParameter("voucher");

boolean pFlag = PersFile.setPersInfo(ownersName); 
String CCode = "";

if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 

Sys.setConnection(PersFile.getConnection()); 
Sys.setSQLTerminator(PersFile.getSQLTerminator());
Rep2.setConnection(PersFile.getConnection(),PersFile.getSQLTerminator()); 
Rep2.setDenormalizeClient(true);

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>DB Report Retrieval Utility</title>
</head>
<body onLoad = "javascript: void setReport()">
<p><em><strong><big>The requested report has been downloaded to your computer.</big></strong></em></p>
<% Rep2.setReportStrings(voucher);%>
<script>
function setReport() {

var HeaderString = <%= Rep2.getHeader() %>;
var PurposeString = <%= Rep2.getPurposes() %>;
var ReceiptString = <%= Rep2.getReceipts() %>;

parent.contents.NewReport();
parent.contents.DirectEdit = false;  //JH 2005-12-20
parent.contents.ProcessHeader(HeaderString);
<% if (request.getParameter("status").equals("Copy")) { %>
    parent.contents.setNameValue(parent.contents.Header,"status","Copy");
<% } else { %>
    parent.contents.setNameValue(parent.contents.Header,"status","Audit");
<% } %>   
parent.contents.setNameValue(parent.contents.Header,"editable","<%= Rep2.getReportEditable() %>");
parent.contents.ProcessRepList('1',PurposeString);
parent.contents.ProcessRepList('2',ReceiptString);
parent.contents.ReportIsSaved = true;  //jh 2006-10-04
parent.contents.ListDelay();


}


</script>
</body>
</html>
<% } else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } %>
