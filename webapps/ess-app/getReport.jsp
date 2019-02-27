<%--
getReport.jsp - Downloads report from XMLR to browser
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
<jsp:useBean id = "DOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "Rep2"
     class="ess.Report2Client"
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
<%-- jsp:useBean id = "GetXML" class="ess.SaveAndStatus" scope="page" --%>
<jsp:useBean id = "GetXML"
     class="ess.ReportContainer"
     scope="page" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<%@ include file="DBAccessInfo.jsp" %>
<% 
String database = request.getParameter("database");

String ownersName = request.getParameter("email");
boolean pFlag = PersFile.setPersInfo(ownersName); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
  DOM.setConnection(PersFile.getConnection()); //probably don't need this but leave for now...
  DOM.setSQLTerminator(PersFile.getSQLTerminator());
  Sys.setConnection(PersFile.getConnection()); 
  Sys.setSQLTerminator(PersFile.getSQLTerminator()); 
  String editable = request.getParameter("edit");
  if (editable == null) editable = "Yes";
%> 
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Report Retrieval Utility</title>
<link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
</head>
<body onLoad = "javascript: void setReport()">

<%  
   String reference  = request.getParameter("reference");
   String reg_dbase = Sys.getSystemString("XML_FOLDER","E:\\Register\\");
   String report = GetXML.getXML(reg_dbase,ownersName,reference);
   if (report != "") { 
     DOM.setDOM(report); 
     Rep2.setReportStrings(DOM.getDOM()); %>
     <p><h2>The requested report has been downloaded to your computer.</h2></p>

     <script>
     function setReport() {

     var HeaderString = <%= Rep2.getHeader() %>;
     var PurposeString = <%= Rep2.getPurposes() %>;
     var ReceiptString = <%= Rep2.getReceipts() %>;

     parent.contents.NewReport();
     parent.contents.DirectEdit = false; //JH 2005-12-20
     parent.contents.ProcessHeader(HeaderString);
     <% if (request.getParameter("status").equals("Copy")) { %>
        parent.contents.setNameValue(parent.contents.Header,"status","Copy");
     <% } else { %>
     <%  if (request.getParameter("status").equals("Sent") || request.getParameter("status").equals("Resent")) { %>
          parent.contents.setNameValue(parent.contents.Header,"status","Changed Sent");
     <%  } else { %>
          parent.contents.setNameValue(parent.contents.Header,"status","Changed New");
     <%  }
       } %>
       parent.contents.setNameValue(parent.contents.Header,"reference","<%= reference %>");
       parent.contents.setNameValue(parent.contents.Header,"editable","<%= editable %>");
       parent.contents.setGeneralLimit(parent.contents.getNameValue(parent.contents.Header,"currency"));
       parent.contents.ProcessRepList('1',PurposeString);
       parent.contents.ProcessRepList('2',ReceiptString);
       parent.contents.ReportIsSaved = true;  //jh 2006-10-04
       parent.contents.ListDelay();
    }

    </script>
    </body>
    </html>
<% } else { %>
    <p><h2>Requested report not found!  No action taken.</h2></p>
    <script>
    function setReport() {
    }
    </script>
    </body>
    </html>
<% Log.println("[500] getReport.jsp report not found: " + reference + " for " + ownersName);
   } %>
<% } else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } %>
