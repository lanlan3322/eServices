<%--
DelinquentSend.jsp - Sends notices to delinquent approvals
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
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="session" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "Notify"
     class="ess.PersonnelTable"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="page" />
<jsp:useBean id = "SendInfo"
     class="ess.ServerSystemTable"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />  

<%@ include file="DBAccessInfo.jsp" %>

<%
String securityContext3 = config.getServletContext().getInitParameter("ESSSecurity"); //JH 9-19-2003
if (securityContext3 == null) securityContext3 = "APPLICATION";
Log.println("[---] DelinquentSend.jsp 1: " + securityContext3); 
String ownersName = request.getParameter("email");
String password = request.getParameter("password");
Log.println("[---] DelinquentSend.jsp 2: " + ownersName); 
if (password == null) password = "";
Log.println("[---] DelinquentSend.jsp 3: " + password);
boolean pFlag = PersFile.setPersInfo(ownersName); 
if (pFlag) Log.println("[---] DelinquentSend.jsp pFlag is true");
Log.println("[---] DelinquentSend.jsp active: " + PersFile.active);

if (pFlag  && PersFile.active.equals("1")) {        //add in a level check
Log.println("[---] DelinquentSend.jsp 4");
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
%>

<%@ include file="StatusInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<%@ include file="DepartInfo.jsp" %>
<%@ include file="NumericSetup.jsp" %>

<%


String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String database = request.getParameter("database");

Notify.setConnection(PersFile.getConnection());
Notify.setSQLTerminator(PersFile.getSQLTerminator()); 
Notify.setSQLStrings();

SendInfo.setConnection(PersFile.getConnection());
SendInfo.setSQLTerminator(PersFile.getSQLTerminator());

Reg.setConnection(PersFile.getConnection()); 
Reg.setSQLTerminator(PersFile.getSQLTerminator());

boolean errorCondition = false; 

String pal_address = SendInfo.getSystemString("PAL_EMAIL_ADDRESS","expense@adisoft-inc.com");

String msgdata = request.getParameter("msgdata");
String rcpt2 = request.getParameter("rcpt2");
String reply2 = request.getParameter("reply2");

%>

<html>
<head>
<title>Follow-up Notification</title>
<link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
</head>

<body>
<%@ include file="StandardTop.jsp" %>
<h1>Follow-up Notification Report</h1>
<em>Started: <%= Dt.entryDate() %></em><br><br>
<%
   String backcolor = "class=\"offsetColor\"";
   String oldbackcolor = "";
   String newbackcolor;
   
   String report2Approve;
   String escalate;
   String SQLCommand;
   String persnum;
   boolean xFlag;
   String repstat;
   String persname;
   byte[] bArray;    //used for encrypted values
   String E;         //     ditto
   String approvalType;
   String repDBStat;
   String receiptAmount;
   String dateColumn;
   String userReference;
   String subTable = "default";   //later set per routing rule
   String depart;
   String notifyMsg;
   String centralReference;
   String update;
   String credate;
   String manager;
   String sendTo;
   String routeto = "";
   String origapprover = "";

   String newNextStep;
   String newNewStatusCode;

   int voucherNumber = 0;

   String SQLDate = SystemDOM.getDOMTableValueFor("sql","datesql");
   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   if (SQLType.equalsIgnoreCase("MM/DD/YYYY")) { 
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",Dt.simpleDate.format(Dt.date));
   } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",Dt.getOracleDate(Dt.date));
   } else { //generate YYYY-MM-DD
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",Dt.xBaseDate.format(Dt.date));
   } 
   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);

   java.util.StringTokenizer rp = new java.util.StringTokenizer(request.getParameter("voucher"), ";"); 
   java.util.StringTokenizer st = new java.util.StringTokenizer(request.getParameter("status"), ";"); 

// These two are preferable, but don't seem to be handling all the escape characters but they are being "normalized"
// String notifymessage = SystemDOM.getDOMTableValueFor("delinquentmessages","notifymessage");
// String escalatemessage = SystemDOM.getDOMTableValueFor("delinquentmessages","escalatemessage");
 
   String resendDaysStr = SystemDOM.getDOMTableValueFor("delinquentmessages","resendafterdays"); //trick for following  
  
   String notifymessage = SystemDOM.getDOMTableValueWhere("resendafterdays",resendDaysStr,"notifymessage");
   String approvermessage = SystemDOM.getDOMTableValueWhere("resendafterdays",resendDaysStr,"approvermessage");
   String escalatemessage = SystemDOM.getDOMTableValueWhere("resendafterdays",resendDaysStr,"escalatemessage");

Log.println("[000] DelinquentSend.jsp notifymessage - " + notifymessage);
Log.println("[000] DelinquentSend.jsp escalatemessage - " + escalatemessage);
Log.println("[000] DelinquentSend.jsp resendDaysStr - " + resendDaysStr);

   String action = request.getParameter("action");
%>   
   
<table>
<tr>
<td><u>Reporter</u></td>
<td><u>Last Submit</u></td>
<td><u>Report #</u></td>
<td><u>Report Status</u></td>
<td><u>Approver</u></td>
<td><u>Escalate</u></td>
<td><u>Message Status</u></td>
<% 
   while (rp.hasMoreTokens()) {  
     report2Approve = rp.nextToken().trim() ;
     escalate = st.nextToken().trim() ;
     voucherNumber = voucherNumber + 1;
     //Look at messagesendsql later if we need to customize.  Need to use a replace.
   
     SQLCommand = SystemDOM.getDOMTableValueFor("delinquentmessages","messagesendsql","");
   
     if (SQLCommand.equals("")) {
        SQLCommand = "SELECT ";
        SQLCommand += "PERS_NUM, RP_STAT, NAME, RE_AMT, PVOUCHER, VOUCHER, UP_DATE, DEPART, CUR_DATE, MANAGER ";
        SQLCommand += "FROM REPORT ";
        SQLCommand += "WHERE VOUCHER = '$voucher$'" + PersFile.getSQLTerminator();
     }

     SQLCommand = Reg.SQLReplace(SQLCommand,"$voucher$",report2Approve);

     if (Reg.setResultSet(SQLCommand)) {

        persnum = PersFile.getTrim(Reg.myResult.getString(1));
        repstat = PersFile.getTrim(Reg.myResult.getString(2));
        if (encrypt.equalsIgnoreCase("YES")) {
          bArray = Reg.myResult.getBytes(3);
          E = new String(bArray);
          persname = unScramble(E,encrypt,encryptKey);   
        } else {
          persname = PersFile.getTrim(Reg.myResult.getString(3));
        }
        persname = PersFile.setRightName(persname);
        receiptAmount = money.format(money.parse(PersFile.getTrim(Reg.myResult.getString(4))));
        userReference = PersFile.getTrim(Reg.myResult.getString(5));
        depart = PersFile.getTrim(Reg.myResult.getString(8));
        centralReference = PersFile.getTrim(Reg.myResult.getString(6));
        update = PersFile.getTrim(Reg.myResult.getString(7));
        credate = PersFile.getTrim(Reg.myResult.getString(9)); 
        manager = PersFile.getTrim(Reg.myResult.getString(10));
        repDBStat = StatXlation(repstat, CompanyName, StatusDOM);

        %>
        <tr <%=backcolor%>><td><%= persname %></td><td><%= credate%></td><td><%= centralReference %></td><td><%= repDBStat %></td>
        <%        

        
        notifyMsg = "";
        origapprover = "";
        routeto = "";
        if (escalate.equals("S")) {
           xFlag = Notify.setPersNumInfo(persnum); 
           notifyMsg = notifymessage;
        } else {    
           xFlag = Notify.setPersNumInfo(manager); 
           if (xFlag) {    //might want to change to a dynamic routing
             if (escalate.equals("E") ) {
                origapprover = Notify.setRightName(Notify.name);
                if (Notify.setPersNumInfo(Notify.getManager())) {
                  routeto = Notify.setRightName(Notify.name);
                  notifyMsg = escalatemessage;
                } else {
                  routeto = "Not found!";  
                  xFlag = false;
                }
             } else {   //will equal "A"
                origapprover = Notify.setRightName(Notify.name);
                notifyMsg = approvermessage;
             }
           } 
        }  

%> 
        <td><%= origapprover %></td><td><%= routeto %></td>
<%

        if (xFlag) {
//determine the followup type
          sendTo = Notify.getEmailAddress();

          if (notifyMsg.equals("")) notifyMsg = "1. Reporter: $name$\n2. Central Reference: $voucher$\n3. User Reference: $pvoucher$\n4. Amount: $amount$\n5. Create Date: $date$\n6. Payment Date: $update$\n7. Status: $status$";

          notifyMsg = Reg.SQLReplace(notifyMsg,"$voucher$",centralReference);
          notifyMsg = Reg.SQLReplace(notifyMsg,"$date$",credate);
          notifyMsg = Reg.SQLReplace(notifyMsg,"$update$",update);
          notifyMsg = Reg.SQLReplace(notifyMsg,"$name$",persname);
          notifyMsg = Reg.SQLReplace(notifyMsg,"$pvoucher$",userReference.substring(1));
          notifyMsg = Reg.SQLReplace(notifyMsg,"$amount$",receiptAmount);
          notifyMsg = Reg.SQLReplace(notifyMsg,"$status$",repDBStat);
          notifyMsg = Reg.SQLReplace(notifyMsg,"$approver$",origapprover);
          Log.println("[000] DelinquentSend.jsp - msg: " + notifyMsg);

          if (SendAnEmail(sendTo, pal_address, "Approval notification follow-up message", notifyMsg, SendInfo)) {
            %>
            <td>Delivered</td>
            <%  
              Log.println("[000] DelinquentSend.jsp - delivery OK to " + sendTo + " for " + persname + ", report: " + centralReference);
          } else {
            %>
            <td>Failed</td>
            <%        
            Log.println("[400] DelinquentSend.jsp - delivery failure to " + sendTo + " for " + persname + ", report: " + centralReference);
          }
       } else { 
        %>
            <td>Failed - no recipient</td>
        <%  Log.println("[400] DelinquentSend.jsp - report approval " + report2Approve + " could not locate user");
       } 
     } else { 
       %>
       <tr <%=backcolor%>><td></td><td></td><td></td><td></td><td></td><td></td><td>message not sent due to database access problem</td>
       <%  Log.println("[500] DelinquentSend.jsp - report approval " + report2Approve + " had a database access error");
     } 
%>       
   </tr>
<%  
   newbackcolor = backcolor;
   backcolor = oldbackcolor; 
   oldbackcolor = newbackcolor;
   } %>
</table>
<br><em>Finished: <%= Dt.entryDate() %>, Total: <%= voucherNumber %></em><br><br>
<%@ include file="StandardBottom.jsp" %>
</body>
</html>
<% 
} else { 
   java.lang.Integer loginAttempts = (java.lang.Integer) session.getValue("loginAttempts");
   int numTrys = loginAttempts.intValue() + 1;
   if (numTrys > 3 || securityContext3.equalsIgnoreCase("HOST")) {
     Log.println("[400] ApprovalSave.jsp Invalid password (3X) for " + ownersName); %>
     <%@ include file="ReloginRedirectMsg.jsp" %>
<% } else { 
     if (securityContext3.equalsIgnoreCase("HOST"))
     { 
%>     <%@ include file="InvalidProcessMsg.jsp" %>
<%
     } else {
%>     <%@ include file="InvalidPasswordMsg.jsp" %>
<%   }
   } 
}
%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>
<%@ include file="SendAnEmail.jsp" %>


