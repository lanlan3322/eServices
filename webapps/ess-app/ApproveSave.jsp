<%--
ApproveSave.jsp - Saves approval to database, sends out e-mail, and handles dup signer 
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
     scope="page" />
<jsp:useBean id = "SystemDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "SysTable"
     class="ess.ServerSystemTable"
     scope="page" />
<jsp:useBean id = "StateTable"
     class="ess.StateTable"
     scope="page" />
<jsp:useBean id = "Currency"
     class="ess.Currency"
     scope="page" />     

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
     SystemDOM.setSQLTerminator(PersFile.getSQLTerminator());
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

  StateTable.setStateTable(PersFile.getConnection(),PersFile.getSQLTerminator());
  
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

  String msgdata = request.getParameter("msgdata");
  String rcpt2 = request.getParameter("rcpt2");
  String reply2 = request.getParameter("reply2");

  CanApprove.setConnection(PersFile.getConnection());
  CanApprove.setSQLTerminator(PersFile.getSQLTerminator()); 
  CanApprove.setUpFiles();
  CanApprove.setApprover(PersFile);

%>
<html>
<body>
<%-- @ include file="parameters.jsp" --%>
<strong><em>The following report(s) have been signed off by you:</em></strong><br>
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
   String nextStep;
   String newStatusCode;
   String receiptAmount;
   String limitRequired; 
   String CEOLimit;
   String signAnyway;
   boolean atLeastOnce;
   String firstSigner;
   String currency;
   String signerColumn;
   String dupAllowed; 
   String dateColumn;
   String userReference;
   String subTable;
   String depart;
   String company;
   String newNotifyPerson;
   String secondSigner;
   String adminSigner;
   String newDuplicate;
   String newLimit;
   boolean newAtLeastOnce;
   String newCEOLimit;
   String notifyMsg;
   String newApprovalType;
   String newSignerColumn;
   String newDateColumn;
   String centralReference;
   String oldStep;
   boolean currencyOK;

   int SQLResult;
   int SQLResult2;

   String newNextStep;
   String newNewStatusCode;

   int voucherNumber = 0;

   String newAsOfDate = Dt.xBaseDate.format(Dt.date);
   String SQLDate = SystemDOM.getDOMTableValueFor("sql","datesql");
   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");

   if (SQLType.equalsIgnoreCase("MM/DD/YYYY")) { 
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",Dt.getSimpleDate(Dt.date));
   } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",Dt.getOracleDate(Dt.date));
   } else { //generate YYYY-MM-DD
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",newAsOfDate);
   } 

   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);

   java.util.StringTokenizer rp = new java.util.StringTokenizer(request.getParameter("voucher"), ";"); 
   java.util.StringTokenizer st = new java.util.StringTokenizer(request.getParameter("status"), ";"); 
   
   String action = request.getParameter("action");
   boolean actionFlag;
   if (action.equals("result") || action.equals("reject")){
      actionFlag = true;
   } else {
      actionFlag = false;
%>    <br><strong><em>Invalid action criteria - contact support!</em></strong>
<%   Log.println("[500] ApproveSave.jsp - Invalid action by " + ownersName);
   }
   
   while (rp.hasMoreTokens() && actionFlag) {  
     report2Approve = rp.nextToken().trim() ;
     report2AppStat = st.nextToken().trim() ;
     Log.println("[000] ApproveSave.jsp - approval process: " + report2Approve + ", " +  report2AppStat + ", " + ownersName);     
     voucherNumber = voucherNumber + 1;
     SQLCommand = "SELECT ";
     SQLCommand += "PERS_NUM, RP_STAT, NAME, RC_AMT, SIGN1, SIGN2, PVOUCHER, DEPART, ADMIN1, VOUCHER, CURRENCY, COMPANY ";
     SQLCommand += "FROM REPORT ";
     SQLCommand += "WHERE RTRIM(VOUCHER) = '" + report2Approve + "' AND RTRIM(RP_STAT) = '" + report2AppStat + "'" + PersFile.getSQLTerminator();
     if (Reg.setResultSet(SQLCommand)) {
// Info from the report
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
        currency = PersFile.getTrim(Reg.myResult.getString(11));
        if (currency.equals(""))
        {
           	currency = PersFile.getCurrency();
        }
        company = PersFile.getTrim(Reg.myResult.getString(12));

// Gets the correct routing rule(s)
        subTable = getRoutingRuleName(DepartDOM, depart, PersFile.depart, Log);
// Gets the who-can-approve method (MANAGER, ADMIN, etc)
        approvalType = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"approval");
        if (approvalType.equals("")) 
        {
          Log.println("[500] ApproveSave.jsp rule not found - using default");
          subTable = "default";
          approvalType = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"approval");
        }
// Other approval requirements ($ limit required, duplicate signers) and which clumn should be filled in
        limitRequired = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"limitrequired");
        CEOLimit = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"ceolimit");
        signAnyway = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"signwithoutlimit");
        atLeastOnce = signAnyway.equalsIgnoreCase("yes");
        dupAllowed = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"duplicatesignerallowed");
        signerColumn = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"updatesqlsigner");
// These are hard coded values - change later
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
// Sets up the personnel object of the report owner
        xFlag = Reporter.setPersNumInfo(persnum); 
// Answers question, can I even approve the report?? 
        if (xFlag && CanApprove.canApprove(Reporter, depart, company, approvalType, 9) 
         && (ifOnceAndOnlyOnce(PersFile, atLeastOnce, adminSigner, firstSigner, secondSigner)
            || CheckLimit(PersFile,receiptAmount,currency,limitRequired, CEOLimit, Currency, Log)) 
         && CheckNotSigner(PersFile, Reporter)
         && CheckDupSigner(PersFile, firstSigner, dupAllowed, signerColumn)) {
%>
          <br> Report <%=report2Approve %> for <%= persname %>
<%          
           signerColumn = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"updatesqlsigner"); 
           dateColumn = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"updatesqldate"); 
// This is the new status (nextstep) - checks for the random sample ----------------------
           nextStep = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,action);
           nextStep = randomSampleStatus(StateTable, StatusDOM, nextStep, Log);
// Gets all the the new information from the next step
           newStatusCode = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"translation");
           newNotifyPerson = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"notify");
           notifyMsg = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"notifymessage");
// Check that the "action" is "result", otherwise do not allow any duplication.
           if (PersFile.userField3.equalsIgnoreCase("SINGLE")) {
              newDuplicate = "YES";
           } else {
              newDuplicate = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"duplicatesignerallowed");
           }
           signAnyway = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"signwithoutlimit");
           newAtLeastOnce = signAnyway.equalsIgnoreCase("yes");
           newLimit = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"limitrequired");
           newCEOLimit = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"ceolimit");
           newApprovalType = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"approval");
           newSignerColumn = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"updatesqlsigner"); 
           newDateColumn = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"updatesqldate"); 

// Gets the next-next step so can enter the approval loop below with the next status to check
// checks for the random sample ----------------------
           newNextStep = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,action);
           newNextStep = randomSampleStatus(StateTable, StatusDOM, newNextStep, Log);
           newNewStatusCode = StatusDOM.getDOMTableValueWhere(subTable,"status",newNextStep,"translation");

// Update with the next step (note: not the next-next step)
// Need to handle the following two cases here:
//    Clear out the admin1, sign1, sign2 if they affect the approval
//    Need to add in the admin1, sign1 and sign2 if they get updated (was this done?? - don't think so)
           SQLCommand = "UPDATE REPORT SET ";
           SQLCommand += "RP_STAT = '"+ newStatusCode + "', ";
           SQLCommand += signerColumn + " = '"+ PersFile.persnum + "', ";
           SQLCommand += dateColumn + " = " + SQLDate + " ";
           SQLCommand += "WHERE RTRIM(VOUCHER) = '" + report2Approve + "'" + PersFile.getSQLTerminator();
// Check that the "action" is "result", otherwise do not allow any duplication.
           SQLResult = Reg.doSQLExecute(SQLCommand);
           SQLResult2 = SQLResult;
// Now the next step is now the current status of the report
           oldStep = nextStep;
// hard-coded - look into changing....           
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
             TransLogUpdate(Reg, Dt, SystemDOM, "approval", report2Approve, userReference, PersFile.persnum, newStatusCode, SQLDate);
           } else {
             Log.println("[500] ApproveSave.jsp - First update did not take");
           }
           Log.println("[000] ApproveSave.jsp (1)- '" + persnum + "','" + newDuplicate + "','" +depart + "','" + newLimit + "','" + receiptAmount + "','" + adminSigner + "','" + firstSigner + "','" + secondSigner + "','" + newApprovalType + "','" + newSignerColumn + "','" + oldStep + "'" );

// if the above SQL update went OK and the signer can approve the next bucket
// This is the status bump while loop
           while (SQLResult2 > -1
              && isDummy("newCEOLimit",newCEOLimit, Log)
              && newDuplicate.equalsIgnoreCase("YES")
              && isDummy("newDuplicate", newDuplicate, Log)
              && CheckDupSigner(PersFile, firstSigner, newDuplicate, newSignerColumn)
              && isDummy("newApprovalType", newApprovalType, Log)
              && (CanApprove.canApprove(Reporter, depart, company, newApprovalType, 9) 
                 || isNotCEOLimit(receiptAmount,currency,newLimit,newCEOLimit,Currency,Log))
              && isDummy("newLimit", newLimit, Log)
              && (ifOnceAndOnlyOnce(PersFile, newAtLeastOnce, adminSigner, firstSigner, secondSigner)   //JH 2008-05-19
                 || CheckLimit(PersFile,receiptAmount,currency,newLimit,newCEOLimit,Currency,Log))) {
         
              SQLCommand = "UPDATE REPORT SET ";
              SQLCommand += "RP_STAT = '"+ newNewStatusCode + "', ";
              SQLCommand += newSignerColumn + " = '"+ PersFile.persnum + "', ";
              SQLCommand += newDateColumn + " = " + SQLDate + " ";
              SQLCommand += "WHERE RTRIM(VOUCHER) = '" + report2Approve + "'" + PersFile.getSQLTerminator();
              SQLResult2 = Reg.doSQLExecute(SQLCommand);

              if (SQLResult2 > -1) {
                oldStep = newNextStep;
                //oldStep = nextStep;
                if (newSignerColumn.equalsIgnoreCase("ADMIN1")) {
                  adminSigner = PersFile.persnum;
                }
                if (signerColumn.equalsIgnoreCase("SIGN1")) {
                  firstSigner = PersFile.persnum;
                }
                if (signerColumn.equalsIgnoreCase("SIGN2")) {
                  secondSigner = PersFile.persnum;
                }
                TransLogUpdate(Reg, Dt, SystemDOM, "approval", report2Approve, userReference, PersFile.persnum, newNewStatusCode, SQLDate);
                nextStep = newNextStep;
                //nextStep = StatusDOM.getDOMTableValueWhere(subTable,"status",newNextStep,action);
                //nextStep = randomSampleStatus(StateTable, StatusDOM, nextStep, Log);
               
                if (nextStep != null && !nextStep.equals("")) {
                  //newNewStatusCode = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"translation");
                  newNotifyPerson = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"notify");
                  notifyMsg = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"notifymessage");
                  if (PersFile.userField3.equalsIgnoreCase("SINGLE")) {
                     newDuplicate = "YES";
                  } else {
                     newDuplicate = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"duplicatesignerallowed");
                  }
                  newLimit = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"limitrequired");
                  newCEOLimit = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"ceolimit");
                  signAnyway = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"signwithoutlimit");
                  newAtLeastOnce = signAnyway.equalsIgnoreCase("yes");
                  newApprovalType = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"approval");
                  newSignerColumn = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"updatesqlsigner"); 
                  newDateColumn = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"updatesqldate"); 

                  //nextStep = StatusDOM.getDOMTableValueWhere(subTable,"status",newNextStep,action);
                  //nextStep = randomSampleStatus(StateTable, StatusDOM, nextStep, Log);

                  newNextStep = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,action);
                  newNextStep = randomSampleStatus(StateTable, StatusDOM, newNextStep, Log);
                  newNewStatusCode = StatusDOM.getDOMTableValueWhere(subTable,"status",newNextStep,"translation");

                } else { 
                  newStatusCode = "";
                  newNotifyPerson = "";
                  notifyMsg = "";
                  newDuplicate = "";
                  newLimit = "";
                  newAtLeastOnce = false;
                  newCEOLimit = "";
                  newApprovalType = "";
                  newSignerColumn = ""; 
                  newDateColumn = "";
                  newNextStep = ""; 
                }
              }

           } // end of the status bump while loop
   
           if (oldStep != null && !oldStep.equals("")) {
              newStatusCode = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"translation");
              newNotifyPerson = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"notify");
              notifyMsg = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"notifymessage");
              newDuplicate = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"duplicatesignerallowed");
              newLimit = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"limitrequired");
              newCEOLimit = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"ceolimit");
              signAnyway = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"signwithoutlimit");
              newAtLeastOnce = signAnyway.equalsIgnoreCase("yes");
              newApprovalType = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"approval");
              newSignerColumn = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"updatesqlsigner"); 
              newDateColumn = StatusDOM.getDOMTableValueWhere(subTable,"status",oldStep,"updatesqldate"); 
           } else {
              newStatusCode = "";
              newNotifyPerson = "";
              notifyMsg = "";
              newDuplicate = "";
              newLimit = "";
              newCEOLimit = "";
              newAtLeastOnce = false;
              newApprovalType = "";
              newSignerColumn = ""; 
              newDateColumn = ""; 
           }

           if ( SQLResult > -1) { 
             repDBStat = StatXlation(newStatusCode, CompanyName, StatusDOM); %>
             &nbsp;set to <%= repDBStat %>
        <%   Log.println("[202] ApproveSave.jsp - report voucher " + report2Approve + " approved by " + ownersName + " to " + newStatusCode);
             //Send email if there is a special message to send as typed into the text box
             if (voucherNumber == 1 && !msgdata.equals("")) {
                if (!SendAnEmail(rcpt2, reply2, "Expense report: " + report2Approve  + ", user reference: " + userReference.substring(1) + " - " + repDBStat, msgdata, SendInfo)) {
                %>
                 <br><strong><em>Message to reporter has not been sent - please use other means to contact them</em></strong><br>
                <%
                }
             }
             if (newNotifyPerson.equals("")) 
             {
               Log.println("[000] ApproveSave.jsp - no notification sent");
               // Need to update the Report->MANAGER field
               SQLCommand = "UPDATE REPORT SET ";
               SQLCommand += "MANAGER = '' ";
               SQLCommand += "WHERE RTRIM(VOUCHER) = '" + report2Approve + "'" + PersFile.getSQLTerminator();
               SQLResult2 = Reg.doSQLExecute(SQLCommand);
               if (SQLResult2 < 0) Log.println("[500] ApproveSave.jsp - routeTo update failure (1)"); 
             } else {
               Log.println("[205] ApproveSave.jsp - method: " + newNotifyPerson);
               Log.println("[206] ApproveSave.jsp notify - '" + newStatusCode + "','" + persnum + "','" + newDuplicate + "','" +depart + "','" + newLimit + "','" + receiptAmount + "','" + adminSigner + "','" + firstSigner + "','" + secondSigner + "','" + signAnyway + "'," + Boolean.toString(newAtLeastOnce));
               ess.RouteTo routeTo = (ess.RouteTo) (Class.forName(newNotifyPerson)).newInstance();
               routeTo.init(PersFile.getConnection(),PersFile.getSQLTerminator());
               routeTo.setCurrencyConversion(Currency.getRate(currency)); //JH 2008-03-11
               String sendTo = routeTo.getEmailAddress(persnum,newDuplicate,depart,company, newLimit,receiptAmount,adminSigner,firstSigner,secondSigner,newAtLeastOnce);
               String sendToPersNum = routeTo.getRouteToPersNum();
               Log.println("[207] ApproveSave.jsp - new approver: " + sendToPersNum);
               if (sendTo.equals("")) {
                 Log.println("[400] ApproveSave.jsp - notify not found");
                 // Need to update the Report->MANAGER field
                 SQLCommand = "UPDATE REPORT SET ";
                 SQLCommand += "MANAGER = '' ";
                 SQLCommand += "WHERE RTRIM(VOUCHER) = '" + report2Approve + "'" + PersFile.getSQLTerminator();
                 SQLResult2 = Reg.doSQLExecute(SQLCommand);
                 if (SQLResult2 < 0) Log.println("[500] ApproveSave.jsp - routeTo update failure (2)"); 
               } else {                
                 Log.println("[000] ApproveSave.jsp - notify: " + sendTo);
                 if (notifyMsg.equals("")) notifyMsg = "Report $voucher$ for $name$ notification.";
                 notifyMsg = Reg.SQLReplace(notifyMsg,"$voucher$",centralReference);
                 notifyMsg = Reg.SQLReplace(notifyMsg,"$name$",persname);
                 notifyMsg = Reg.SQLReplace(notifyMsg,"$persnum$",persnum);
                 notifyMsg = Reg.SQLReplace(notifyMsg,"$department$",depart);
                 notifyMsg = Reg.SQLReplace(notifyMsg,"$depart$",depart);
                 notifyMsg = Reg.SQLReplace(notifyMsg,"$pvoucher$",userReference.substring(1));
                 Log.println("[000] ApproveSave.jsp - msg: " + notifyMsg);
                 // Need to update the Report->MANAGER field
                 sendToPersNum = routeTo.getRouteToPersNum();
                 SQLCommand = "UPDATE REPORT SET ";
                 SQLCommand += "MANAGER = '" + sendToPersNum +"' ";
                 SQLCommand += "WHERE VOUCHER = '" + report2Approve + "'" + PersFile.getSQLTerminator();
                 SQLResult2 = Reg.doSQLExecute(SQLCommand);
                 if (SQLResult2 < 0) Log.println("[500] ApproveSave.jsp - routeTo update failure (3)"); 
                 if (!SendAnEmail(sendTo, pal_address, "Expense report message", notifyMsg, SendInfo)) {
                    Log.println("[500] ApproveSave.jsp - notification message failure");
                    %>
                     <br><strong><em>Warning - Notification message to <%= sendTo %> not sent.</em></strong><br>
                    <%
                 }
               }
             }
        %>
        <% } else { %>
             -- approval denied due to database access problem
        <%  Log.println("[500] ApproveSave.jsp - report approval " + report2Approve + " had a database access error");
           } %>
     <% } else { %>
          <br> Cannot approve <%=report2Approve %> with current Status of <%= report2AppStat %>  
            <% if (xFlag) { %>
                  &nbsp;-- No approval authority
            <%    Log.println("[500] ApproveSave.jsp - Cannot approve " + report2Approve + " - no authority");
               } else { %>
                  &nbsp;-- Reporter has not been found - (<%=persnum %>)
            <%    Log.println("[500] ApproveSave.jsp - Cannot approve " + report2Approve + " - reporter not found");
               } %>
     <% } %>
  <% } else { %>
       <br> Cannot validate <%=report2Approve %> with current Status of <%= report2AppStat %> 
  <%   Log.println("[500] ApproveSave.jsp - Cannot validate " + report2Approve);
     } %>
<% } %>
<br><br><strong><em>End of signoff</em></strong>
<p align="center"><a href="javascript: void parent.contents.PersWithDBase('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ApproveList.jsp?downlevel=','approvallevel','1')" tabindex="1"><em><strong>Return to reports requiring approval</strong></em></a></p>
<script langauge="JavaScript">
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
     Log.println("[400] ApprovalSave.jsp Invalid password (3X) for " + ownersName); %>
     <%@ include file="ReloginRedirectMsg.jsp" %>
<% } else {
      session.putValue("loginAttempts", new java.lang.Integer(numTrys));
%>
     <%@ include file="InvalidPasswordMsg.jsp" %>
<% } 

}
%>
<%@ include file="TransactionLogUpdate.jsp" %>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>
<%@ include file="LimitRequired.jsp" %>
<%@ include file="DupSigner.jsp" %>
<%@ include file="NotSigner.jsp" %>
<%@ include file="SendAnEmail.jsp" %>
<%@ include file="DepartRouteRule.jsp" %>
<%@ include file="RandomSampleSelect.jsp" %>

