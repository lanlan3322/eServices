<%--
AuditSave.jsp - Saves result of an audit
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
     scope="page" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "Reporter"
     class="ess.PersonnelTable"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "CanApprove"
     class="ess.Approver"
     scope="session" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "SendInfo"
     class="ess.ServerSystemTable"
     scope="application" />
<jsp:useBean id = "SystemDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "SysTable"
     class="ess.ServerSystemTable"
     scope="page" />
<jsp:useBean id = "ESS"
     class="ess.DB2Audit"
     scope="session" />
<jsp:useBean id = "Currency"
     class="ess.Currency"
     scope="session" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />   

<%@ include file="DBAccessInfo.jsp" %>

<%

String securityContext3 = config.getServletContext().getInitParameter("ESSSecurity"); //JH 9-19-2003
if (securityContext3 == null) securityContext3 = "APPLICATION";

String ownersName = request.getParameter("email");
String password = request.getParameter("password");
if (password == null) password = "";
String CCode = "";
String NeedPassword = "NO";

boolean pFlag = PersFile.setPersInfo(ownersName); 

if (pFlag) {
   SysTable.setConnection(PersFile.getConnection());   //SystemInfo.jsp handled differently here
   SysTable.setSQLTerminator(PersFile.getSQLTerminator());
   if (!SystemDOM.getDOMProcessed()) {
     String system_file = SysTable.getSystemString("XMLSYSTEM","C:\\WORK\\"); 
     java.io.File SystemFile = new java.io.File(system_file);
     SystemDOM.setDOM(SystemFile);
   }
   NeedPassword = SystemDOM.getDOMTableValueFor("configuration", "pwd_approval","yes");

   if(PersFile.getChallengeCode().equals("")) {
     PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
   }
   CCode = request.getParameter("ccode"); 
}

if (pFlag  && (NeedPassword.equalsIgnoreCase("NO") || PersFile.password.toUpperCase().equals(password.toUpperCase())) && PersFile.active.equals("1") && PersFile.getChallengeCode().equals(CCode)) { 

%>
  <%@ include file="StatusInfo.jsp" %>
  <%@ include file="DepartInfo.jsp" %>
<%

  session.putValue("loginAttempts", new java.lang.Integer(0));

  String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
  String database = request.getParameter("database");

  Reporter.setConnection(PersFile.getConnection());
  Reporter.setSQLTerminator(PersFile.getSQLTerminator()); 
  Reporter.setSQLStrings();

  if (!Currency.isAlreadyLoaded()) {
     Currency.setConnection(PersFile.getConnection());
     Currency.setSQLTerminator(PersFile.getSQLTerminator()); 
     Currency.setSQLStrings();
  }

  SendInfo.setConnection(PersFile.getConnection());
  SendInfo.setSQLTerminator(PersFile.getSQLTerminator());

  Reg.setConnection(PersFile.getConnection()); 
  Reg.setSQLTerminator(PersFile.getSQLTerminator());

  boolean errorCondition = false; 
 
  String pal_address = SendInfo.getSystemString("PAL_EMAIL_ADDRESS","expense@adisoft-inc.com");

  String received = request.getParameter("received");
  String msgdata = request.getParameter("msgdata");
  String rcpt2 = request.getParameter("rcpt2");
  String reply2 = request.getParameter("reply2");

  CanApprove.setConnection(PersFile.getConnection());
  CanApprove.setSQLTerminator(PersFile.getSQLTerminator()); 
  CanApprove.setUpFiles();
  CanApprove.setApprover(PersFile);

%>
<html>
<body onLoad="initTimer()">
<%-- @ include file="parameters.jsp" --%>
<strong><em><%= Lang.getString("followingRepSigOff")%></em></strong><br>
<%
   String report2Approve;
   String report2AppStat;
   String SQLCommand;
   String persnum;
   boolean xFlag;
   String repstat;
   String persname;
   byte[] bArray;    //used for encrypted values
   String E;         //     ditto
   String approvalType;
   String repDBStat;
   String nextStep = "";
   String newStatusCode = "";
   String receiptAmount;
   String limitRequired; 
   String CEOLimit;
   String firstSigner;
   String signerColumn;
   String dupAllowed; 
   String dateColumn;
   String userReference;
   String subTable;
   String depart;
   String newNotifyPerson;
   String secondSigner;
   String adminSigner;
   String newDuplicate = "";
   String newLimit = "";
   String newCEOLimit = "";
   String notifyMsg;
   String newApprovalType = "";
   String newSignerColumn = "";
   String newDateColumn = "";
   String centralReference;
   String oldStep;
   String oldReceived;
   String currency;
   String company;

   int SQLResult;
   int SQLResult2;

   String newNextStep = "";
   String newNewStatusCode = "";

   int voucherNumber = 0;

   String newAsOfDate = Dt.xBaseDate.format(Dt.date);
   String receivedDate = "";
   String SQLDate = SystemDOM.getDOMTableValueFor("sql","datesql");
   String RSQLDate = SQLDate;
   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   String BlankDate = SystemDOM.getDOMTableValueFor("sql","blankdate");
   if (SQLType.equals("MM/DD/YYYY")) { 
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",Dt.getSimpleDate(Dt.date));
     if (received != null && !received.equals("")) received = Dt.getSimpleDate(Dt.getDateFromStr(received,PersFile.getDateFormat()));
   } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")) {    // oracle
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",Dt.getOracleDate(Dt.date));
     if (received != null && !received.equals("")) received = Dt.getOracleDate(Dt.getDateFromStr(received,PersFile.getDateFormat()));
   } else { //generate YYYY-MM-DD
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",newAsOfDate);
     if (received != null && !received.equals("")) received = Dt.getSQLDate(Dt.getDateFromStr(received,PersFile.getDateFormat()));
   } 
   if (received != null && !received.equals("")) {                   //JH 2007-05-24
         receivedDate = Reg.SQLReplace(RSQLDate,"$date$",received);
   } else {
         receivedDate = Reg.SQLReplace(RSQLDate,"$date$",BlankDate);
   }
   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);

   String _voucher = request.getParameter("voucher");
   String _status = request.getParameter("status");

   Log.println("[000] AuditSave.jsp _voucher: " + _voucher);
   Log.println("[000] AuditSave.jsp _status: " + _status);

   java.util.StringTokenizer rp = new java.util.StringTokenizer(_voucher, ";"); 
   java.util.StringTokenizer st = new java.util.StringTokenizer(_status, ";"); 
   
   String receiptNumberString = request.getParameter("receipts");
   
   //////java.util.StringTokenizer rp = new java.util.StringTokenizer(request.getParameter("voucher"), ";"); 
   
   String action = request.getParameter("action");
   boolean actionFlag;
   if (action.equals("result") || action.equals("reject") || action.equals("receiptonly")){
      actionFlag = true;
   } else {
      actionFlag = false;
%>    <br><strong><em>Invalid action criteria - contact support!</em></strong>
<%   Log.println("[500] AuditSave.jsp - Invalid action by " + ownersName);
   }
   
   /// Looping thru the tokens
   while (rp.hasMoreTokens() && actionFlag) {  
     report2Approve = rp.nextToken().trim() ;
     report2AppStat = st.nextToken().trim() ;
     voucherNumber = voucherNumber + 1;
     SQLCommand = "SELECT ";
     SQLCommand += "PERS_NUM, RP_STAT, NAME, RC_AMT, SIGN1, SIGN2, PVOUCHER, DEPART, ADMIN1, VOUCHER, RECEIVED, CURRENCY, COMPANY ";
     SQLCommand += "FROM REPORT ";
     SQLCommand += "WHERE VOUCHER = '" + report2Approve + "' AND RP_STAT = '" + report2AppStat + "'" + PersFile.getSQLTerminator();
     if (Reg.setResultSet(SQLCommand)) {

        //Getting names,etc to use to avoid duplicate signers, etc. later
        persnum = PersFile.getTrim(Reg.myResult.getString(1));
        repstat = PersFile.getTrim(Reg.myResult.getString(2));
        if (encrypt.equalsIgnoreCase("YES")) {
          bArray = Reg.myResult.getBytes(3);
          E = new String(bArray);
          persname = unScramble(E,encrypt,encryptKey);   
        } else {
          persname = PersFile.getTrim(Reg.myResult.getString(3));
        }

        receiptAmount = PersFile.getTrim(Reg.myResult.getString(4));
        firstSigner = PersFile.getTrim(Reg.myResult.getString(5));  //need variable name for column later to check for dup sign
        secondSigner = PersFile.getTrim(Reg.myResult.getString(6)); 
        userReference = PersFile.getTrim(Reg.myResult.getString(7));
        depart = PersFile.getTrim(Reg.myResult.getString(8));
        adminSigner = PersFile.getTrim(Reg.myResult.getString(9)); 
        centralReference = PersFile.getTrim(Reg.myResult.getString(10));
        oldReceived = PersFile.getTrim(Reg.myResult.getString(11));
        currency = PersFile.getTrim(Reg.myResult.getString(12));
        company = PersFile.getTrim(Reg.myResult.getString(13));

        subTable = getRoutingRuleName(DepartDOM, depart, PersFile.depart, Log);

        approvalType = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"approval");
        if (approvalType.equals("")) 
        {
          Log.println("[500] ApprovalSave.jsp rule not found - using default");
          subTable = "default";
          approvalType = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"approval");
        }

        limitRequired = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"limitrequired");
        CEOLimit = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"ceolimit");
        dupAllowed = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"duplicatesignerallowed");
        signerColumn = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"updatesqlsigner");

        if (signerColumn.equalsIgnoreCase("ADMIN1")) {
          adminSigner = "";
          firstSigner = "";
          secondSigner = "";
        }
        if (signerColumn.equalsIgnoreCase("SIGN1")) {
          firstSigner = "";
          secondSigner = ""; 
        }
        if (signerColumn.equalsIgnoreCase("SIGN2")) {
          secondSigner = "";
        }

        xFlag = Reporter.setPersNumInfo(persnum); 
        if (xFlag && CanApprove.canApprove(Reporter, depart, company, approvalType, 9) 
         && CheckLimit(PersFile,receiptAmount,currency,limitRequired,CEOLimit,Currency,Log)
         && CheckNotAuditor(PersFile, Reporter, firstSigner)
         && CheckDupSigner(PersFile, firstSigner, dupAllowed, signerColumn)) {
%>
          <br> Report <%=report2Approve %> for <%= persname %>
<%          
           signerColumn = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"updatesqlsigner"); 
           dateColumn = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"updatesqldate"); 

           if (!action.equals("receiptonly")) {   //JH 2007-05-24
              nextStep = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,action);

              newStatusCode = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"translation");
              newNotifyPerson = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"notify");
              if (PersFile.userField3.equalsIgnoreCase("SINGLE")) {
                 newDuplicate = "YES";
              } else {
                 newDuplicate = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"duplicatesignerallowed");
              }
              newLimit = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"limitrequired");
              newCEOLimit = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"ceolimit");
              newApprovalType = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"approval");
              newSignerColumn = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"updatesqlsigner"); 
              newDateColumn = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"updatesqldate"); 

              newNextStep = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,action);
              newNewStatusCode = StatusDOM.getDOMTableValueWhere(subTable,"status",newNextStep,"translation");
           }
//
// Need to handle the following two cases here:
//   
//    Clear out the admin1, sign1, sign2 if they affect the approval
//    Need to add in the admin1, sign1 and sign2 if they get updated
//
           if (newStatusCode.equals("")) newStatusCode = repstat;  //need to test this stuff!
           boolean updateReportHeader = !newStatusCode.equals(repstat);

           if (updateReportHeader) {

              SQLCommand = "UPDATE REPORT SET ";
              SQLCommand += "RP_STAT = 'G3', ";
//              SQLCommand += "RP_STAT = '"+ newStatusCode + "', ";
              SQLCommand += signerColumn + " = '"+ PersFile.persnum + "', ";
              SQLCommand += dateColumn + " = " + SQLDate + " ";
              if (received != null) SQLCommand += ", " + "RECEIVED = " + receivedDate + " ";
              SQLCommand += "WHERE VOUCHER = '" + report2Approve + "'" + PersFile.getSQLTerminator();

              SQLResult = Reg.doSQLExecute(SQLCommand);

           } else { 
              if (oldReceived == null || oldReceived.equals("")) {
                oldReceived = BlankDate;
              } else if (SQLType.equals("MM/DD/YYYY")) { 
                oldReceived = Dt.getSimpleDate(Dt.getDateFromXBase(oldReceived));
              } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")) {    // oracle
                oldReceived = Dt.getOracleDate(Dt.getDateFromXBase(oldReceived));
              } else { //generate YYYY-MM-DD
                oldReceived = Dt.getSQLDate(Dt.getDateFromXBase(oldReceived));
              } 
              Log.println("[---] AuditSave.jsp compare date: " + oldReceived + " with " + received);
              if (!oldReceived.equals(received)) {
                SQLCommand =  "UPDATE REPORT SET RECEIVED = " + receivedDate + " ";
                SQLCommand += "WHERE VOUCHER = '" + report2Approve + "'" + PersFile.getSQLTerminator();
                SQLResult = Reg.doSQLExecute(SQLCommand);
                if (SQLResult == 1) ESS.setReceiptsReceivedDate(received);

              } else { 
                SQLResult = 1;
                Log.println("[000] AuditSave.jsp - Receipt update by " + ownersName + " for " + report2Approve);
              }
           }

           SQLResult2 = SQLResult;

           oldStep = nextStep;
           if (SQLResult2 > -1){
             if (signerColumn.equalsIgnoreCase("ADMIN1")) {
               adminSigner = PersFile.persnum;
             }
             if (signerColumn.equalsIgnoreCase("SIGN1")) {
               firstSigner = PersFile.persnum;
             }
             if (signerColumn.equalsIgnoreCase("SIGN2")) {
               secondSigner = PersFile.persnum;
             }
             // If successful, post and receipt check updates
             Log.println("[000] AuditSave.jsp receipt string: " + receiptNumberString);
             if (receiptNumberString != null && receiptNumberString.trim().length() > 0)
             {
               java.util.StringTokenizer x = new java.util.StringTokenizer(receiptNumberString, ";");
               java.util.StringTokenizer y = new java.util.StringTokenizer(request.getParameter("checks"), ";");
               if (ReceiptCheckUpdate(Reg, SystemDOM, report2Approve, x, y, PersFile.getSQLTerminator(),Log,(ess.Report) ESS))
               {
                  Log.println("[000] AuditSave.jsp - Receipt check update OK");
               } else {
                  Log.println("[500] AuditSave.jsp - Receipt check update failed (SQL)");
                 %> - Receipt check update failed - <%
               }
               receiptNumberString = null;  // also serves as a flag
             } else {
               Log.println("[000] AuditSave.jsp - No receipts found");
             }
           }
           Log.println("[000] AuditSave.jsp - '" + persnum + "','" + newDuplicate + "','" +depart + "','" + newLimit + "','" + receiptAmount + "','" + adminSigner + "','" + firstSigner + "','" + secondSigner + "','" + newApprovalType + "','" + newSignerColumn + "','" + oldStep + "'" );

////// Additional approval stamps
           while (SQLResult2 > -1
              && updateReportHeader
              && newDuplicate.equalsIgnoreCase("YES")
              && CheckDupSigner(PersFile, firstSigner, newDuplicate, newSignerColumn)
              && CanApprove.canApprove(Reporter, depart, company, newApprovalType, 9) 
              && CheckLimit(PersFile,receiptAmount,currency,newLimit,newCEOLimit,Currency,Log)) {
         
              SQLCommand = "UPDATE REPORT SET ";
              SQLCommand += "RP_STAT = 'G3', ";
//              SQLCommand += "RP_STAT = '"+ newNewStatusCode + "', ";
              SQLCommand += newSignerColumn + " = '"+ PersFile.persnum + "', ";
              SQLCommand += newDateColumn + " = " + SQLDate + " ";
              SQLCommand += "WHERE VOUCHER = '" + report2Approve + "'" + PersFile.getSQLTerminator();
              SQLResult2 = Reg.doSQLExecute(SQLCommand);

              if (SQLResult2 > -1) {
                
                oldStep = newNextStep;
                if (newSignerColumn.equalsIgnoreCase("ADMIN1")) {
                  adminSigner = PersFile.persnum;
                }
                if (signerColumn.equalsIgnoreCase("SIGN1")) {
                  firstSigner = PersFile.persnum;
                }
                if (signerColumn.equalsIgnoreCase("SIGN2")) {
                  secondSigner = PersFile.persnum;
                }

                nextStep = StatusDOM.getDOMTableValueWhere(subTable,"status",newNextStep,action);
                if (nextStep != null && !nextStep.equals("")) {
                  newNewStatusCode = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"translation");
                  newNotifyPerson = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"notify");
                  if (PersFile.userField3.equalsIgnoreCase("SINGLE")) {
                     newDuplicate = "YES";
                  } else {
                     newDuplicate = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"duplicatesignerallowed");
                  }
                  newLimit = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"limitrequired");
                  newCEOLimit = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"ceolimit");
                  newApprovalType = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"approval");
                  newSignerColumn = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"updatesqlsigner"); 
                  newDateColumn = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"updatesqldate"); 
                  newNextStep = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,action);
                } else { 
                  newStatusCode = "";
                  newNotifyPerson = "";
                  newDuplicate = "";
                  newLimit = "";
                  newCEOLimit = "";
                  newApprovalType = "";
                  newSignerColumn = ""; 
                  newDateColumn = "";
                  newNextStep = ""; 
                }
              }
           }
//////// End of additional approval stamps
 
//////// Forward for the next approver   
           if (oldStep != null && !oldStep.equals("")) {
              newStatusCode = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"translation");
              newNotifyPerson = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"notify");
              newDuplicate = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"duplicatesignerallowed");
              newLimit = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"limitrequired");
              newCEOLimit = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"ceolimit");
              newApprovalType = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"approval");
              newSignerColumn = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"updatesqlsigner"); 
              newDateColumn = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"updatesqldate"); 
           } else {
              newStatusCode = "";
              newNotifyPerson = "";
              newDuplicate = "";
              newLimit = "";
              newCEOLimit = "";
              newApprovalType = "";
              newSignerColumn = ""; 
              newDateColumn = ""; 
           }

           if ( SQLResult > -1) { 
             if (!updateReportHeader) {
                repDBStat = "No status change";
             } else {
                repDBStat = StatXlation(newStatusCode, CompanyName, StatusDOM);
             } 
             %>
             &nbsp;result&nbsp;=&nbsp;<%= Lang.getDataString(repDBStat) %>
        <%   Log.println("[202] AuditSave.jsp - report voucher " + report2Approve + " approved by " + ownersName + " to " + newStatusCode);
             //Send email if there is a special message to send as typed into the text box
             if (voucherNumber == 1 && !msgdata.equals("")) {
            	 String subject4Msg = ess.Utilities.replaceStr(Lang.getString("email_audit_subject"), "$voucher$",report2Approve);
            	 subject4Msg = ess.Utilities.replaceStr(subject4Msg,"$pvoucher$",userReference.substring(1));
            	 subject4Msg = ess.Utilities.replaceStr(subject4Msg,"$status$",Lang.getString(repDBStat));
                if (!SendAnEmail(rcpt2, reply2, subject4Msg, msgdata, SendInfo)) {
                %>
                 <br><strong><em>Message to reporter has not been sent - please use other means to contact them</em></strong><br>
                <%
                }
             }
             if (newNotifyPerson.equals("")) 
             {
               Log.println("[000] AuditSave.jsp - no notification sent");
               // Need to update the Report->MANAGER field
               SQLCommand = "UPDATE REPORT SET ";
               SQLCommand += "MANAGER = '' ";
               SQLCommand += "WHERE VOUCHER = '" + report2Approve + "'" + PersFile.getSQLTerminator();
               SQLResult2 = Reg.doSQLExecute(SQLCommand);
               if (SQLResult2 < 0) Log.println("[500] AuditSave.jsp - routeTo update failure (1)"); 
             } else {
               Log.println("[205] AuditSave.jsp - method: " + newNotifyPerson);
               Log.println("[000] AuditSave.jsp - '" + persnum + "','" + newDuplicate + "','" +depart + "','" + newLimit + "','" + receiptAmount + "','" + adminSigner + "','" + firstSigner + "','" + secondSigner + "'" );
               ess.RouteTo routeTo = (ess.RouteTo) (Class.forName(newNotifyPerson)).newInstance();
               routeTo.init(PersFile.getConnection(),PersFile.getSQLTerminator());
// The auditsave does not currently support the "signanyway" option - it has been set to 'false' all the time.
// Company added 2008-6-20 JH
               String sendTo = routeTo.getEmailAddress(persnum, newDuplicate, depart, company, newLimit,receiptAmount,adminSigner,firstSigner,secondSigner, false);
               String sendToPersNum = routeTo.getRouteToPersNum();
               if (sendTo.equals("")) {
                 Log.println("[400] AuditSave.jsp - notify not found");
                 // Need to update the Report->MANAGER field
                 SQLCommand = "UPDATE REPORT SET ";
                 SQLCommand += "MANAGER = '' ";
                 SQLCommand += "WHERE VOUCHER = '" + report2Approve + "'" + PersFile.getSQLTerminator();
                 SQLResult2 = Reg.doSQLExecute(SQLCommand);
                 if (SQLResult2 < 0) Log.println("[500] AuditSave.jsp - routeTo update failure (2)"); 
               } else {                
                 Log.println("[000] AuditSave.jsp - notify: " + sendTo);
                 notifyMsg = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"notifymessage");
                 if (notifyMsg.equals("")) notifyMsg = "Report $voucher$ for $name$ awaiting your action.";
                 notifyMsg = Reg.SQLReplace(notifyMsg,"$voucher$",centralReference);
                 notifyMsg = Reg.SQLReplace(notifyMsg,"$name$",persname);
                 notifyMsg = Reg.SQLReplace(notifyMsg,"$pvoucher$",userReference.substring(1));
                 Log.println("[000] AuditSave.jsp - msg: " + notifyMsg);
                 // Need to update the Report->MANAGER field
                 sendToPersNum = routeTo.getRouteToPersNum();
                 SQLCommand = "UPDATE REPORT SET ";
                 SQLCommand += "MANAGER = '" + sendToPersNum +"' ";
                 SQLCommand += "WHERE VOUCHER = '" + report2Approve + "'" + PersFile.getSQLTerminator();
                 SQLResult2 = Reg.doSQLExecute(SQLCommand);
                 if (SQLResult2 < 0) Log.println("[500] AuditSave.jsp - routeTo update failure (3)"); 
                 
            	 String subject4Notice = ess.Utilities.replaceStr(Lang.getString("email_audit_notify"), "$voucher$",centralReference);
            	 subject4Notice = ess.Utilities.replaceStr(subject4Notice,"$pvoucher$",userReference.substring(1));
            	 subject4Notice = ess.Utilities.replaceStr(subject4Notice,"$name$",persname);

                 if (!SendAnEmail(sendTo, pal_address, subject4Notice, notifyMsg, SendInfo)) {
                    Log.println("[500] AuditSave.jsp - notification message failure");
                    %>
                     <br><strong><em>Warning - Notification message to <%= sendTo %> not sent.</em></strong><br>
                    <%
                 }
               }
             }
        %>
        <% } else { %>
             -- approval denied due to database access problem
        <%  Log.println("[500] AuditSave.jsp - report approval " + report2Approve + " had a database access error");
           } %>
     <% } else { %>
          <br><%= Lang.getString("cannotApp")%> <%=report2Approve %> <%= Lang.getString("withCurSta")%> <%= report2AppStat %>  
            <% if (xFlag) { %>
                  &nbsp;-- <%= Lang.getString("noAppAut")%>
            <%    Log.println("[500] AuditSave.jsp - Cannot approve " + report2Approve + " - no authority");
               } else { %>
                  &nbsp;-- Reporter has not been found - (<%=persnum %>)
            <%    Log.println("[500] AuditSave.jsp - Cannot approve " + report2Approve + " - reporter not found");
               } %>
     <% } %>
  <% } else { %>
       <br> Cannot validate <%=report2Approve %> with current Status of <%= report2AppStat %> 
  <%   Log.println("[500] AuditSave.jsp - Cannot validate " + report2Approve);
     } %>
<% } %>
<br><br><strong><em><%= Lang.getString("endOfSign")%></em></strong>
<p align="center"><a href="javascript: void init()" tabindex="1"><em><strong><%= Lang.getString("returnSelLis")%></strong></em></a></p>

<form method="POST" action="AuditList.jsp">
  <input type="hidden" name="email" value>
  <input type="hidden" name="ccode" value>
  <input type="hidden" name="xaction" value>
  <input type="hidden" name="database" value>
  <input type="hidden" name="begdate" value>
  <input type="hidden" name="enddate" value>
  <input type="hidden" name="downlevel" value>
  <input type="hidden" name="reportclass" value="form">
  <input type="hidden" name="reporttype" value="SELECT * FROM REPORT WHERE">
</form>


<script langauge="JavaScript">

function initTimer() {
  var x = setTimeout("init()",5000);
}

function init() {
  with (document.forms[0]) {
    document.forms[0].action = parent.contents.defaultApps + parent.contents.getLastDisplay();
    begdate.value = parent.contents.getDBString(parent.PersDBase, "reportBegDate", document.forms[0].begdate.value);
    enddate.value = parent.contents.getDBString(parent.PersDBase, "reportEndDate", document.forms[0].enddate.value);
    downlevel.value = parent.contents.getDBString(parent.PersDBase, "approvallevel", "1");
    email.value = parent.contents.getNameValue(parent.Header, "email");
    database.value = parent.database;
    ccode.value = parent.CCode;
    xaction.value = "List";
    reporttype.value = parent.contents.getLastSQL();
    submit();
  }
}

</script>
</body>
</html>

<% 
} else { 

   java.lang.Integer xLoginTrys = (java.lang.Integer) session.getValue("loginAttempts");
   java.lang.Integer loginAttempts = new java.lang.Integer(4);
   if (xLoginTrys != null) {
      loginAttempts = xLoginTrys;
   }
   int numTrys;
   numTrys = loginAttempts.intValue() + 1;
   if (numTrys > 3 || securityContext3.equalsIgnoreCase("HOST")) {
     Log.println("[400] AuditSave.jsp Invalid password (3X) for " + ownersName); %>
     <%@ include file="ReloginRedirectMsg.jsp" %>
<% } else {
      session.putValue("loginAttempts", new java.lang.Integer(numTrys));
%>
     <%@ include file="InvalidPasswordMsg.jsp" %>
<% } 

}
%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>
<%@ include file="LimitRequired.jsp" %>
<%@ include file="DupSigner.jsp" %>
<%@ include file="NotAuditor.jsp" %>
<%@ include file="SendAnEmail.jsp" %>
<%@ include file="DepartRouteRule.jsp" %>
<%@ include file="ReceiptCheckUpdate.jsp" %>


