<%--
SubmitLocal.jsp - sends report from LESS for processing
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
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="session" />
<jsp:useBean id = "Enh"
     class="ess.Enhancement"
     scope="page" />
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="page" />
<%@ include file="DBAccessInfo.jsp" %>

<% 

String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String database = request.getParameter("database");

String ownersName = request.getParameter("email");
String password = request.getParameter("password");
if (password == null) password = "";

//Need to put in a check for the DBDatabase parameter instead...
PersFile.setDB(database,DBUser,DBPassword); 


PersFile.setSQLTerminator(DBSQLTerminator);
PersFile.setSQLStrings();

boolean errorCondition = false; 
String reportIsSaved = "false";


boolean pFlag = PersFile.setPersInfo(ownersName); 
pFlag = true;  //override security check for now.  Need to do somekind of password thingy here.
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
//if (pFlag && PersFile.getChallengeCode().equals(CCode)) {  //think about adding this in later gator
if (pFlag) { 
%>
<%@ include file="StatusInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<%
  Log.println("[005] Start SubmitLocal: " + ownersName);

  String personalreference = request.getParameter("reference"); 
  String reference = request.getParameter("alternatereference"); //was reference...

  Log.println("[000] SubmitLocal.jsp reference: " + reference);
  Log.println("[000] SubmitLocal.jsp personalreference: " + personalreference);

  String report = request.getParameter("report");

  String displayMessage = "";

  ReportDOM.setConnection(PersFile.getConnection());
  ReportDOM.setSQLTerminator(PersFile.getSQLTerminator());

  SendDbase.setConnection(PersFile.getConnection());
  SendDbase.setSQLTerminator(PersFile.getSQLTerminator());
  SendDbase.setUpSystemFiles();

  SaveXML.setConnection(PersFile.getConnection()); 
  SaveXML.setSQLTerminator(PersFile.getSQLTerminator());

  //SavePers.setConnection(PersFile.getConnection());
  //SavePers.setSQLTerminator(PersFile.getSQLTerminator()); 

  Enh.setConnection(PersFile.getConnection());
  Enh.setSQLTerminator(PersFile.getSQLTerminator()); 
%> 

<html>
<body onLoad="javascript: void xDisplay()">
<% if (request.getParameter("status").equals("Copy")) { %>

   You cannot resubmit a Copy of an expense report.  You must make all changes to the original and resubmit the original.

<% } else { %>

<% SendDbase.setSQLStrings(); 

   //SavePers.setFile(request.getParameter("persdbase"),ownersName);
//This section of the code checks if this is a first time user and will
//create the necessary user register file - See logic in Intro.jsp  ====

   Reg.setConnection(PersFile.getConnection()); 

   String persnumber = PersFile.persnum.toUpperCase(); 
   String SQLCommand = "SELECT ";
   SQLCommand += "REGISTER.STATUS, REGISTER.REFERENCE, REGISTER.MESSAGE, REPORT.RP_STAT, ";
   SQLCommand += "REPORT.ACT_DATE, REPORT.ACT_TIME, REGISTER.REPDATE, REPORT.PERS_NUM, REPORT.RC_AMT ";
   SQLCommand += "FROM REGISTER LEFT JOIN REPORT ON RTRIM(REGISTER.THEIR_REF) = RTRIM(REPORT.VOUCHER) ";
   SQLCommand += "AND RTRIM(REPORT.VOUCHER) <> '' ";
   SQLCommand += "WHERE RTRIM(REGISTER.OWNER) = '" + Reg.repStr(ownersName.toUpperCase()) + "' "; 
   SQLCommand += "AND RTRIM(REGISTER.STATUS) <> 'Copy' AND RTRIM(REGISTER.STATUS) <> 'Remove' ";
   SQLCommand += "AND RTRIM(REGISTER.STATUS) <> 'Delete' AND RTRIM(REGISTER.STATUS) <> 'Problem' ";
   SQLCommand += "ORDER BY REGISTER.THEIR_REF DESC, REGISTER.XREF DESC" + PersFile.getSQLTerminator();
 
   SQLCommand = SystemDOM.getDOMTableValueFor("registertable","listreports",SQLCommand);
   if (SQLCommand != null && !SQLCommand.equals("")) {
      SQLCommand = Reg.SQLReplace(SQLCommand,"$owner$",Reg.repStr(ownersName.toUpperCase()));
   } 

   if (!Reg.setResultSet(SQLCommand)) { 
      CreateRegister(PersFile,Log);
   }
//======
   SaveXML.setOwner(ownersName);


   if (SaveXML.getDOMProcessed()) {
    
   String reportComment = request.getParameter("comment");
   if (reportComment != null) SaveXML.setComment(reportComment);

   SaveXML.setXMLFile(report, reference);
 
   String xref = "00000000" + SaveXML.getLastReference(); //See SaveAndStatus.java
   //xref = "A" + xref.substring(xref.length() - 7);
   String alternatePrefix = SystemDOM.getDOMTableValueFor("configuration","alternateprefix","");
   xref = alternatePrefix + xref.substring(xref.length() - 7);
Log.println("[000] SubmitLocal.jsp pvoucher = " + xref);
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

   Log.println("[000] SubmitLocal.jsp report being saved: " + xDOM);
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
     
     displayMessage = SystemDOM.getDOMTableValueFor("messages","received","");

     if (!displayMessage.equals("")) 
     {
         displayMessage = ess.Utilities.getNReplace(displayMessage,"$time$",now.toString());
         displayMessage = ess.Utilities.getNReplace(displayMessage,"$email$",request.getParameter("email"));
         displayMessage = ess.Utilities.getNReplace(displayMessage,"$personalStatus$",SaveXML.getStatus());
         displayMessage = ess.Utilities.getNReplace(displayMessage,"$personalReference$",SaveXML.getLastReference());
         displayMessage = ess.Utilities.getNReplace(displayMessage,"$centralStatus$",StatXlation(SendDbase.getStatus(),CompanyName, StatusDOM));
         displayMessage = ess.Utilities.getNReplace(displayMessage,"$centralReference$",SendDbase.getVoucherNumber());
     } else 
     {
        displayMessage += "Your expense report has been submitted on " + now + " and is registered under " + request.getParameter("email") + ".  ";  
        displayMessage += "It has the status of " + SaveXML.getStatus() + " and has been saved under reference " + SaveXML.getLastReference() + ".";
        displayMessage += "<br>";
        displayMessage += "<br>";       
        displayMessage += "It is registered in the central database under reference " + SendDbase.getVoucherNumber() + " with a status of " + StatXlation(SendDbase.getStatus(),CompanyName, StatusDOM) + ".";
     }
     
     errorCondition = false; //need to look at any error checking
     reportIsSaved = "true";
     
   } else 
   {

     displayMessage += "There was difficulty submitting your report! <br>";
     displayMessage += "It is registered under " + request.getParameter("email") + " with reference " + SaveXML.getLastReference() + ".<br>";
     displayMessage += "but has not been accepted by the central database for further processing.<br><br>";

     Log.println("[450] SubmitLocal.jsp report invalid submission for: " + request.getParameter("email"));
     java.util.Vector errorMsgs = SendDbase.getErrorLines();
     if (errorMsgs.size() > 0 || SendDbase.getProcessErrorMessage() != null)
     {
     displayMessage += "The following error message(s) may help you determine the cause:<br><br>";
       if (SendDbase.getProcessErrorMessage() != null)
       {

           displayMessage += SendDbase.getProcessErrorMessage() + "<br>";            
           Log.println("[451] SubmitLocal.jsp invalid submission error (process): " + SendDbase.getProcessErrorMessage());
       }
       if (errorMsgs.size() > 0) 
       {
         for (int i = 0; i < errorMsgs.size(); i++)
         { 
           displayMessage += errorMsgs.elementAt(i) + "<br>";            
           Log.println("[451] SubmitLocal.jsp invalid submission error (validation): " + errorMsgs.elementAt(i));
         }
       }

       displayMessage += "<br>";
     }

     displayMessage += "Submit your report again after reviewing it. If problem persists contact support.";
     errorCondition = true; //need to look at any error checking
   } 


   }else {
     Log.println("[500] SubmitLocal.jsp Register access failure for: " + PersFile.getEmailAddress()); 

     displayMessage += "An error has been detected in accessing your personal report database (xmlr).<br>";
     displayMessage += "Please attempt to submit your report again.  If the problem persists, contact support<br>";
     displayMessage += "immediately and do not close you browser.";
     errorCondition = true; //need to look at any error checking
   }

   if (SavePers.getStatus().equals("Saved")) { 
      displayMessage += "<br><br>Your personal data has been saved on the server.";
   } else { 
      displayMessage += "<br><br>There was difficulty saving your personal data.  Please contact support.";
   } 

   if (!SendDbase.isMessageSentOK()) {
      displayMessage += "<br><br><strong><em>There was a problem with the email messages.  Please inform your approver if necessary.</em></strong>";
   }
 
}

String errorConditionString;
if (errorCondition)
{
   errorConditionString = "true";
} else
{
   errorConditionString = "false";
}
%>
<form method="post" action="http://localhost:8085/LocalMessage.jsp">
  <input type="hidden" name="reportIsSaved" value>
  <input type="hidden" name="errorCondition" value>
  <input type="hidden" name="message" value>
  <input type="hidden" name="reference" value>
  <input type="hidden" name="status" value>
  <input type="hidden" name="centralReference" value>
  <input type="hidden" name="alternateReference" value>
  <input type="hidden" name="endproc" value>
</form>  
<script>
   function xDisplay() {
     document.forms[0].reportIsSaved.value = "<%= reportIsSaved %>";
     //      displayMessage += "parent.contents.ReportIsSaved = true;";
     document.forms[0].errorCondition.value = "<%= errorConditionString %>";
     document.forms[0].message.value = "<%= displayMessage %>";
     document.forms[0].reference.value = "<%= personalreference %>";
     document.forms[0].status.value = "<%= SaveXML.getStatus() %>";
     document.forms[0].centralReference.value = "<%= SendDbase.getVoucherNumber() %>";
     document.forms[0].alternateReference.value = "<%= SaveXML.getLastReference() %>";
     document.forms[0].endproc.value = "<%= request.getParameter("endproc") %>";
     document.forms[0].submit(); 
   }
</script>
</body>
</html>
<% 
} else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% 
} 
Log.println("[005] End SubmitLocal: " + ownersName);
%>

<%@ include file="CreateRegister.jsp" %>
<%@ include file="StatXlation.jsp" %>
