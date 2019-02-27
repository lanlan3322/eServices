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


<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />           

<%
Log.println("[300] ajax/SaveXMLJS.jsp Started for " + PersFile.getEmailAddress());   //JH 2014-10-6

//boolean pFlag = PersFile.setPersInfo(request.getParameter("email")); 
boolean pFlag = true;

String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
//if (pFlag && PersFile.getChallengeCode().equals(CCode)) {  

%>
function DataDownload() {
   parent.setNameValue(parent.Header,"status","<%= request.getParameter("status") %>");
   parent.setNameValue(parent.Header, "reference","<%= request.getParameter("reference") %>");
   parent.ReportIsSaved = true;
   parent.SetReportIsSaved = true;
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
         alert('<%= Lang.getString("ERROR_AJAX_INSTANCE") %>');
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
            alert('<%= Lang.getString("ERROR_AJAX_PERSONAL_DATABASE") %>');
         }
         AJAXProcessDone = true;
		 //parent.PersWindow(parent.defaultApps + "ajax/XMLRList.jsp");
		 var sType = "<%= request.getParameter("type") %>";
		 if(sType == "Annual"){
			var poststr = "email=" + encodeURIComponent( parent.getNameValue(parent.Header, "email") );
			poststr += "&reference=" + "<%= request.getParameter("reference") %>";
			poststr += "&database=" + encodeURIComponent( parent.CreatePersDBXML(parent.PersDBase)) ;
			poststr += "&ccode=" + "<%=request.getParameter("ccode")%>";
			parent.PersWindow(parent.defaultApps + "ajax/SubmitwithGuide_leave.jsp?" + poststr);
		 }
		 else{
			parent.PersWindow(parent.defaultApps + "ajax/receipts/UploadSelect_leave.jsp?viewed=<%= request.getParameter("reference") %>");
		 }
      }
   }
   
   function sendPersDbase() {
      if (parent.getNameValue(parent.Header, "email") == "") {
         parent.setNameValue(parent.Header, "email", parent.getNameValue(parent.myHeader, "email"));
      }
Log.println("SaveXMLJS.jsp","sendPersDbase," + parent.getNameValue(parent.Header, "email"));
      var poststr = "email=" + encodeURIComponent( parent.getNameValue(parent.Header, "email") ) + "&persdbase=" + encodeURIComponent( parent.CreatePersDBXML(parent.PersDBase) );
      makePOSTRequest(parent.defaultApps + "ajax/SavePersXMLAJAX_leave.jsp", poststr);
   }
   
function screenLoad() {
  DataDownload();
  return true;
}

function screenUnload() {
  return true;
}


