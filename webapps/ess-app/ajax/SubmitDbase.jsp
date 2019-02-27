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
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />           
<jsp:useBean id = "Scan"
     class="ess.Scan"
     scope="session" />        
     
<%@ include file="../DBAccessInfo.jsp" %>

<% 

String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
//String database = request.getParameter("database");

boolean errorCondition = false; 

String ownersName = request.getParameter("email");
Log.println("[286] Start ajax/SubmitDbase: " + ownersName + " under session ID: " + session.getId());
boolean pFlag = PersFile.setPersInfo(ownersName); 
String reportSaved = "No";
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
//if (pFlag) { 

  String reference = request.getParameter("reference");

  String report = request.getParameter("report");

  ReportDOM.setConnection(PersFile.getConnection());
  ReportDOM.setSQLTerminator(PersFile.getSQLTerminator());

  SendDbase.setConnection(PersFile.getConnection());
  SendDbase.setSQLTerminator(PersFile.getSQLTerminator());
  SendDbase.setLanguage(PersFile.getLanguage());   //Maybe this should be the system language not personal
  SendDbase.setDateFormat(PersFile.getDateFormat());
  SendDbase.setDecimal(PersFile.getDecimal());
  SendDbase.setSeparator(PersFile.getSeparator());
  SendDbase.setUpSystemFiles();
  SendDbase.setSubmitter(PersFile);

  SaveXML.setConnection(PersFile.getConnection()); 
  SaveXML.setSQLTerminator(PersFile.getSQLTerminator());

  Enh.setConnection(PersFile.getConnection());
  Enh.setSQLTerminator(PersFile.getSQLTerminator()); 
%> 

<%@ include file="../StatusInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>


<% if (request.getParameter("status").equals("Copy")) { %>

   <%= Lang.getString("ERROR_CANNOT_RESUBMIT_COPY") %>
<% } else { %>

<% SendDbase.setSQLStrings(); 

   SaveXML.setOwner(ownersName);
   
   if (SaveXML.getDOMProcessed()) {
    
   String reportComment = request.getParameter("comment");
   if (reportComment != null) SaveXML.setComment(reportComment);

   SaveXML.setXMLFile(report, reference);
 
   String xref = "00000000" + SaveXML.getLastReference(); //See SaveAndStatus.java
   String alternatePrefix = SystemDOM.getDOMTableValueFor("configuration","alternateprefix","");
   xref = alternatePrefix + xref.substring(xref.length() - 7);
   Log.println("[000] ajax/SubmitDbase.jsp pvoucher = " + xref);
   
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

   Log.println("[000] ajax/SubmitDbase.jsp report being saved: " + xDOM);
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
     if (false) {
//     if (!displayMessage.equals("")) {   //Should clean this up.  Don't need this if condition.
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
         String xSavedMsg1 = Lang.getString("SUBMIT_MSG1");
         xSavedMsg1 = Lang.getReplace(xSavedMsg1,"$now$",now.toString());
         xSavedMsg1 = Lang.getReplace(xSavedMsg1,"$lastReference$",SaveXML.getLastReference());
         xSavedMsg1 = Lang.getReplace(xSavedMsg1,"$email$",request.getParameter("email"));
         xSavedMsg1 = Lang.getReplace(xSavedMsg1,"$status$",Lang.getDataString(SaveXML.getStatus()));
         String xSavedMsg2 = Lang.getString("SUBMIT_MSG2");
         xSavedMsg2 = Lang.getReplace(xSavedMsg2,"$reference$",SendDbase.getVoucherNumber());
         xSavedMsg2 = Lang.getReplace(xSavedMsg2,"$status$",Lang.getDataString(StatXlation(SendDbase.getStatus(),CompanyName, StatusDOM)));
%>
        <%= xSavedMsg1 %><br>
        <br>
        <%= xSavedMsg2 %>
<%@ include file="RemoveWorkInclude.jsp" %>
<%   }

     errorCondition = false; //need to look at any error checking

     reportSaved = "Yes";
     
     //attach receipts here with an SQL statement
     Scan.setConnection(PersFile.getConnection());
     Scan.setSQLTerminator(PersFile.getSQLTerminator());
     Scan.setSystemTable(SysTable);
     if(Scan.setAutoAttach2Report(SendDbase.getPVoucher(),SendDbase.getVoucherNumber()) > 0)
     {
    	 Log.println("[380] ajax/SubmitDbase.jsp receipts scans attached");
     }

   } else {
       String xErrorMsg1 = Lang.getString("SUBMIT_MSG1");
       xErrorMsg1 = Lang.getReplace(xErrorMsg1,"$email$",request.getParameter("email"));
       xErrorMsg1 = Lang.getReplace(xErrorMsg1,"$lastReference$",SaveXML.getLastReference());
%>
     <%= xErrorMsg1 %><br><br>

<%   Log.println("[450] ajax/SubmitDbase.jsp report invalid submission for: " + request.getParameter("email"));
     java.util.Vector errorMsgs = SendDbase.getErrorLines();
     if (errorMsgs.size() > 0 || SendDbase.getProcessErrorMessage() != null)
     {
%>
     <%= Lang.getString("ERROR_REPORT_FAILED") %><br><br>
<%
       if (SendDbase.getProcessErrorMessage() != null)
       {
           %>
           <%= SendDbase.getProcessErrorMessage() %> <br>            
           <%
           Log.println("[451] ajax/SubmitDbase.jsp invalid submission error (process): " + SendDbase.getProcessErrorMessage());
       }
       if (errorMsgs.size() > 0) 
       {
         for (int i = 0; i < errorMsgs.size(); i++)
         { 
           %>
           <%= errorMsgs.elementAt(i) %> <br>            
           <%
           Log.println("[451] ajax/SubmitDbase.jsp invalid submission error (validation): " + errorMsgs.elementAt(i));
         }
       }

%><br><%
     }
%>
     <%= Lang.getString("ERROR_REPORT_RESUBMIT") %>
<%   errorCondition = true; //need to look at any error checking
   } 
   }else {
     Log.println("[500] ajax/SubmitDbase.jsp Register access failure for: " + PersFile.getEmailAddress()); 
%>
     <%= Lang.getString("ERROR_REPORT_PERSONAL_DATABASE") %>
<%   errorCondition = true; //need to look at any error checking
   }
   if (!SendDbase.isMessageSentOK()) {
%>
   <br><br><strong><em><%= Lang.getString("ERROR_REPORT_EMAIL") %></em></strong>
<%
   }
%>
<br><br>
<span id="personalData"><%= Lang.getString("PERSONAL_DATA_BEING_UPDATED") %></span>
<br><br>
<%
}


String EC;
if (errorCondition) {
	EC = "True";
} else {
	EC = "False";
}
%>

<script language="javascript" id="script" folder="<%= PersFile.getAppServer() + "/" + PersFile.getAppFolder() %>" file="ajax/SubmitDbaseJS.jsp?email=<%= ownersName%>&reference=<%= reference %>&ccode=<%= CCode%>&lastReference=<%= SaveXML.getLastReference()%>&status=<%= SaveXML.getStatus()%>&endproc=<%= request.getParameter("endproc")%>&saved=<%= reportSaved%>&errorcond=<%= EC%>"/>


<% } else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } 
Log.println("[287] End SubmitDbase: " + ownersName);
%>

<%@ include file="../StatXlation.jsp" %>
