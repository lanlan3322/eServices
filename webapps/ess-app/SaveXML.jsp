<%--
SaveXML.jsp - saves a report to the user's register file (XMLR) 
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

<jsp:useBean id = "SaveXML"
     class="ess.ReportContainer"
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
String database = request.getParameter("database");
String ownersName = request.getParameter("email");
String reportComment = request.getParameter("comment");
if (reportComment != null) SaveXML.setComment(reportComment);

Log.println("[000] SaveXML.jsp Started for " + PersFile.getEmailAddress());

boolean pFlag = PersFile.setPersInfo(ownersName); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) {  

SaveXML.setConnection(PersFile.getConnection());
SaveXML.setSQLTerminator(PersFile.getSQLTerminator());



%>
<html>
<body onLoad="DataDownload()">
<% if (request.getParameter("status").equals("Copy")) { %>

   You cannot change a Copy of an expense report.  You must make all changes to the original.

<% } else { %>
   <% SaveXML.setOwner(request.getParameter("email")); 
    if (SaveXML.getDOMProcessed()) { 
      SaveXML.setStatus(request.getParameter("status"));
      String xDOM = request.getParameter("report");
      Log.println("[000] SaveXML.jsp report being saved: " + xDOM);
      if (request.getParameter("reference").equals("")) {
        SaveXML.setXMLFile(xDOM);
      } else {
        SaveXML.setXMLFile(xDOM,request.getParameter("reference")); 
      } %>
      <%java.util.Date now = new java.util.Date(); %> 
      <% if (SaveXML.getStatus() == "Failure") { 
            Log.println("[500] SaveXML.jsp - Save Failure");
      %>
         The system has failed to save your expense report.  Please contact support.  <Strong>Do not close your browser.</Strong>
      <% } else { %>
         Your expense report has been saved as of <%= now %> and is registered as report <%= SaveXML.getLastReference() %> for <%= request.getParameter("email") %>.
         It has a status of <%= SaveXML.getStatus() %>.<br><br>
         Please remember to submit for reimbursement when complete.
      <% } 
    } else {
     Log.println("[500] SaveXML.jsp Register access failure for: " + PersFile.getEmailAddress()); 
%>
     An error has been detected in accessing your personal report database (xmlr).<br>
     Please attempt to save your report again.  If the problem persists, contact support<br>
     immediately and do not close you browser.
<%
    }
  %>
<% }%>

<br><br>
<span id="personalData">Your personal database is being updated.  Please wait...</span>
<br><br>

<script langauge="JavaScript">
function DataDownload() {
   parent.contents.setNameValue(parent.contents.Header,"status","<%= SaveXML.getStatus() %>");
   parent.contents.setNameValue(parent.contents.Header, "reference","<%= SaveXML.getLastReference() %>");
   parent.contents.ReportIsSaved = true;
   sendPersDbase();
}

   var http_request = false;
   var AJAXProcessDone = false;
   
   function makePOSTRequest(url, parameters) {
      http_request = false;
      if (window.XMLHttpRequest) { // Mozilla, Safari,...
         http_request = new XMLHttpRequest();
         if (http_request.overrideMimeType) {
         	// set type accordingly to anticipated content type
            //http_request.overrideMimeType('text/xml');
            http_request.overrideMimeType('text/html');
         }
      } else if (window.ActiveXObject) { // IE
         try {
            http_request = new ActiveXObject("Msxml2.XMLHTTP");
         } catch (e) {
            try {
               http_request = new ActiveXObject("Microsoft.XMLHTTP");
            } catch (e) {}
         }
      }
      if (!http_request) {
         alert('Cannot create XMLHTTP instance');
         AJAProcessDnne = true;
         return false;
      }
      
      http_request.onreadystatechange = checkMessage;
      http_request.open('POST', url, true);
      http_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      http_request.setRequestHeader("Content-length", parameters.length);
      http_request.setRequestHeader("Connection", "close");
      http_request.send(parameters);
   }

   function checkMessage() {
      if (http_request.readyState == 4) {
         if (http_request.status == 200) {
            result = http_request.responseText;
            document.getElementById('personalData').innerHTML = result;            
         } else {
            alert('There was a communications problem with\n updating your personal database.');
         }
         AJAXProcessDone = true;
      }
   }
   
   function sendPersDbase() {
   
   // request.getParameter("email")
  
      var poststr = "email=" + encodeURIComponent( parent.contents.getNameValue(parent.Header, "email") ) +
                    "&persdbase=" + encodeURIComponent( parent.contents.CreatePersDBXML(parent.PersDBase) );
      makePOSTRequest(parent.contents.defaultApps + "SavePersXMLAJAX.jsp", poststr);
   }

</script>
</body>
</html>
<% } else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } %>

