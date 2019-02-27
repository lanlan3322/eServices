<%--
SubmitDbase.jsp - submits a report for processing
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

<%@ page contentType="text/html" isThreadSafe="false" %>
<jsp:useBean id = "SendDbase"
     class="ess.ProcessESSReport"
     scope="page" />
<jsp:useBean id = "ReportDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "SaveXML"
     class="ess.ReportContainer"
     scope="page" />
<jsp:useBean id = "SavePers"
     class="ess.SavePersData"
     scope="page" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="session" />
<jsp:useBean id = "Enh"
     class="ess.Enhancement"
     scope="page" />
<%@ include file="DBAccessInfo.jsp" %>

<% 

String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
//String database = request.getParameter("database");

boolean errorCondition = false; 

String ownersName = request.getParameter("email");
Log.println("[286] Start SubmitDbase: " + ownersName + " under session ID: " + session.getId());
boolean pFlag = PersFile.setPersInfo(ownersName); 

String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 

  String reference = request.getParameter("reference");

  String report = request.getParameter("report");

  ReportDOM.setConnection(PersFile.getConnection());
  ReportDOM.setSQLTerminator(PersFile.getSQLTerminator());

  SendDbase.setConnection(PersFile.getConnection());
  SendDbase.setSQLTerminator(PersFile.getSQLTerminator());
  SendDbase.setUpSystemFiles();
  SendDbase.setSubmitter(PersFile);

  SaveXML.setConnection(PersFile.getConnection()); 
  SaveXML.setSQLTerminator(PersFile.getSQLTerminator());

  SavePers.setConnection(PersFile.getConnection());
  SavePers.setSQLTerminator(PersFile.getSQLTerminator()); 

  Enh.setConnection(PersFile.getConnection());
  Enh.setSQLTerminator(PersFile.getSQLTerminator()); 
%> 

<%@ include file="StatusInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>

<html>
<body onload="javascript: void DataDownload()">
<% if (request.getParameter("status").equals("Copy")) { %>

   You cannot resubmit a Copy of an expense report.  You must make all changes to the original and resubmit the original.

<% } else { %>

<% SendDbase.setSQLStrings(); 

   SavePers.setFile(request.getParameter("persdbase"),ownersName);

   SaveXML.setOwner(ownersName);
   
   if (SaveXML.getDOMProcessed()) {
    
   String reportComment = request.getParameter("comment");
   if (reportComment != null) SaveXML.setComment(reportComment);

   SaveXML.setXMLFile(report, reference);
 
   String xref = "00000000" + SaveXML.getLastReference(); //See SaveAndStatus.java
   //xref = "A" + xref.substring(xref.length() - 7);
   String alternatePrefix = SystemDOM.getDOMTableValueFor("configuration","alternateprefix","");
   xref = alternatePrefix + xref.substring(xref.length() - 7);
Log.println("[000] SubmitDbase.jsp pvoucher = " + xref);
   String xDOM = "";
   xDOM += "<register type=\"report\">";
   xDOM += "<reply-to>" + ownersName + "</reply-to>";
   xDOM += "<reference>" + xref + "</reference>";
   xDOM += report;
   xDOM += "</register>";
   ReportDOM.setDOM(xDOM); 
   ReportDOM.setNormal(); 
   ReportDOM.setPromoteSubElements("expenselist");

   Enh.setExp2Cat(ReportDOM);           //enhancing file with mappings 
   Enh.setTable("CHARGE"); 
   Enh.setSearch4("charge");
   Enh.setCompliment("reimb");
   Enh.setParentType("charge");
   Enh.setEnhancement("reimb");
   Enh.setGeneric(ReportDOM);           // done with the mappings

   Log.println("[000] SubmitDbase.jsp report being saved: " + xDOM);
   SendDbase.run(ReportDOM.getDOM(),xref);
   if (SendDbase.isPersistanceOK()) {
//String statusStr = request.getParameter("status");
     String statusStr = "New";
     if (statusStr.equals("Changed Sent") || statusStr.equals("Sent") || statusStr.equals("Resent") ) {
        SaveXML.setStatus("Resent");
     } else {
        SaveXML.setStatus("Sent");
     }
     java.util.Date now = new java.util.Date();
     SaveXML.setRegisterWithThrRef(SaveXML.getLastReference(),SendDbase.getVoucherNumber());
     
     String displayMessage = SystemDOM.getDOMTableValueFor("messages","received","");

     if (!displayMessage.equals("")) {
         displayMessage = ess.Utilities.getNReplace(displayMessage,"$time$",now.toString());
         displayMessage = ess.Utilities.getNReplace(displayMessage,"$email$",request.getParameter("email"));
         displayMessage = ess.Utilities.getNReplace(displayMessage,"$personalStatus$",SaveXML.getStatus());
         displayMessage = ess.Utilities.getNReplace(displayMessage,"$personalReference$",SaveXML.getLastReference());
         displayMessage = ess.Utilities.getNReplace(displayMessage,"$centralStatus$",StatXlation(SendDbase.getStatus(),CompanyName, StatusDOM));
         displayMessage = ess.Utilities.getNReplace(displayMessage,"$centralReference$",SendDbase.getVoucherNumber());
%>
         <%= displayMessage %>
<%
     } else {
%>
        Your expense report has been submitted on <%= now%> and is registered under <%= request.getParameter("email")%>.  
        It has the status of <%= SaveXML.getStatus() %> and has been saved under reference <%= SaveXML.getLastReference() %>.
        <br>
        <br>
        It is registered in the central database under reference <%= SendDbase.getVoucherNumber() %> with a status of <%= StatXlation(SendDbase.getStatus(),CompanyName, StatusDOM) %>.
<%   }

     errorCondition = false; //need to look at any error checking
%>
     <script>
     parent.contents.ReportIsSaved = true;
     </script>
<%
   } else {
%>
     There was difficulty submitting your report! <br>
     It is registered under <%= request.getParameter("email")%> with reference <%= SaveXML.getLastReference() %>.<br>
     but has not been accepted by the central database for further processing.<br><br>

<%   Log.println("[450] SubmitDbase.jsp report invalid submission for: " + request.getParameter("email"));
     java.util.Vector errorMsgs = SendDbase.getErrorLines();
     if (errorMsgs.size() > 0 || SendDbase.getProcessErrorMessage() != null)
     {
%>
     The following error message(s) may help you determine the cause:<br><br>
<%
       if (SendDbase.getProcessErrorMessage() != null)
       {
           %>
           <%= SendDbase.getProcessErrorMessage() %> <br>            
           <%
           Log.println("[451] SubmitDbase.jsp invalid submission error (process): " + SendDbase.getProcessErrorMessage());
       }
       if (errorMsgs.size() > 0) 
       {
         for (int i = 0; i < errorMsgs.size(); i++)
         { 
           %>
           <%= errorMsgs.elementAt(i) %> <br>            
           <%
           Log.println("[451] SubmitDbase.jsp invalid submission error (validation): " + errorMsgs.elementAt(i));
         }
       }

%><br><%
     }
%>
     Submit your report again after reviewing it. If problem persists contact support.
<%   errorCondition = true; //need to look at any error checking
   } 
   }else {
     Log.println("[500] SubmitDbase.jsp Register access failure for: " + PersFile.getEmailAddress()); 
%>
     An error has been detected in accessing your personal report database (xmlr).<br>
     Please attempt to submit your report again.  If the problem persists, contact support<br>
     immediately and do not close you browser.
<%   errorCondition = true; //need to look at any error checking
   }
%>
<% if (SavePers.getStatus().equals("Saved")) { %>
<br><br>Your personal data has been saved on the server.
<% } else { %>
<br><br>There was difficulty saving your personal data.  Please contact support.
<% } %>

<% if (!SendDbase.isMessageSentOK()) {
%>
   <br><br><strong><em>There was a problem with the email messages.  Please inform your approver if necessary.</em></strong>
<%
   }
%> 
<%}%>
<script langauge="JavaScript">
function DataDownload() {
//Do this no matter what

parent.contents.setNameValue(parent.contents.Header, "reference","<%= SaveXML.getLastReference() %>");
parent.contents.setNameValue(parent.contents.Header, "status","<%= SaveXML.getStatus() %>");

<% if (request.getParameter("endproc").equals(null) || errorCondition) {
      if (errorCondition) {   %>
       //no end process - error condition detected
  <%  } else { %>
       //no end process specified
<%    }
   } else { %>
<%= request.getParameter("endproc") %> 
<% } %>
}

function blankOutReport() {
<%
   if (!errorCondition) {
%>
     parent.contents.NewReport();
     parent.contents.ProcessHeader(parent.Header); 
     alert("Your report has been saved.  You may now start a new report if you wish.");
<% } 
%>
}


</script>
</body>
</html>
<% } else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } 
Log.println("[287] End SubmitDbase: " + ownersName);
%>

<%@ include file="StatXlation.jsp" %>
