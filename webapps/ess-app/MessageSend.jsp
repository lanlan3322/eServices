<%--
MessageSend.jsp - Send EOD message
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
<jsp:useBean id = "Reporter"
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
     scope="session" />
<jsp:useBean id = "SendInfo"
     class="ess.ServerSystemTable"
     scope="application" />

<%@ include file="DBAccessInfo.jsp" %>

<%
String securityContext3 = config.getServletContext().getInitParameter("ESSSecurity"); //JH 9-19-2003
if (securityContext3 == null) securityContext3 = "APPLICATION";

String ownersName = request.getParameter("email");
String password = request.getParameter("password");

if (password == null) password = "";

boolean pFlag = PersFile.setPersInfo(ownersName); 

if (pFlag  && PersFile.active.equals("1")) {        //add in a level check
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

Reporter.setConnection(PersFile.getConnection());
Reporter.setSQLTerminator(PersFile.getSQLTerminator()); 
Reporter.setSQLStrings();

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
<body>
<%-- @ include file="parameters.jsp" --%>
<em>Started: <%= Dt.entryDate() %></em><br><br>
<strong><em>The following email messages have been sent:<br><br></em></strong><br>
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
   String receiptAmount;
   String dateColumn;
   String userReference;
   String subTable = "default";   //later set per routing rule
   String depart;
   String notifyMsg;
   String centralReference;
   String update;
   String credate;
   String sendTo;

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
   
   String action = request.getParameter("action");
   
   while (rp.hasMoreTokens()) {  
     report2Approve = rp.nextToken().trim() ;
     report2AppStat = st.nextToken().trim() ;
     voucherNumber = voucherNumber + 1;
     SQLCommand = "SELECT ";
     SQLCommand += "PERS_NUM, RP_STAT, NAME, RE_AMT, PVOUCHER, VOUCHER, UP_DATE, DEPART, CRE_DATE ";
     SQLCommand += "FROM REPORT ";
     SQLCommand += "WHERE VOUCHER = '" + report2Approve + "' AND RTRIM(RP_STAT) = '" + report2AppStat + "'" + PersFile.getSQLTerminator();
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
        receiptAmount = money.format(money.parse(PersFile.getTrim(Reg.myResult.getString(4))));
        userReference = PersFile.getTrim(Reg.myResult.getString(5));
        depart = PersFile.getTrim(Reg.myResult.getString(8));
        centralReference = PersFile.getTrim(Reg.myResult.getString(6));
        update = PersFile.getTrim(Reg.myResult.getString(7));
        credate = PersFile.getTrim(Reg.myResult.getString(9)); 
        %>
        Message for <%= persname %>, upload <%= update%>, central reference <%= centralReference %>
        <%        
        repDBStat = StatXlation(repstat, CompanyName, StatusDOM);
        xFlag = Reporter.setPersNumInfo(persnum); 
        if (xFlag) {
          sendTo = Reporter.getEmailAddress();
          Log.println("[000] MessageSend.jsp - notify: " + persname + " via " + sendTo);
          notifyMsg = StatusDOM.getDOMTableValueWhere(subTable,"translation",repstat,"notifymessage");

          if (notifyMsg.equals("")) notifyMsg = "1. Reporter: $name$\n2. Central Reference: $voucher$\n3. User Reference: $pvoucher$\n4. Amount: $amount$\n5. Create Date: $date$\n6. Payment Date: $update$\n7. Status: $status$";
          notifyMsg = Reg.SQLReplace(notifyMsg,"$voucher$",centralReference);
          notifyMsg = Reg.SQLReplace(notifyMsg,"$date$",credate);
          notifyMsg = Reg.SQLReplace(notifyMsg,"$update$",update);
          notifyMsg = Reg.SQLReplace(notifyMsg,"$name$",persname);
          notifyMsg = Reg.SQLReplace(notifyMsg,"$pvoucher$",userReference.substring(1));
          notifyMsg = Reg.SQLReplace(notifyMsg,"$amount$",receiptAmount);
          notifyMsg = Reg.SQLReplace(notifyMsg,"$status$",repDBStat);
          Log.println("[000] MessageSend.jsp - msg: " + notifyMsg);

          if (SendAnEmail(sendTo, pal_address, "Payment notification message", notifyMsg, SendInfo)) {
            %>
            -- has been delivered.<br>
            <%  
              Log.println("[000] MessageSend.jsp - delivery OK to " + sendTo + " for " + centralReference);
          } else {
            %>
            -- delivery failure.<br>
            <%        
            Log.println("[400] MessageSend.jsp - delivery failure to " + sendTo + " for " + centralReference);
          }
       } else { 
        %>
            -- message not sent - could not locate recipient<br>
        <%  Log.println("[400] MessageSend.jsp - report approval " + report2Approve + " could not locate user");
       } 
     } else { 
       %>
           -- message not sent due to database access problem<br>
       <%  Log.println("[500] MessageSend.jsp - report approval " + report2Approve + " had a database access error");
     } 
       
   } %>
   <br><br><strong><em>End of send process</em></strong><br><br>
   <em>Finished: <%= Dt.entryDate() %>, Total: <%= voucherNumber %></em><br><br>
   <p align="center"><a href="javascript: void parent.main.print()"><em><strong>Print this list</strong></em></a></p>
   <script langauge="JavaScript">
   </script>
   </body>
   </html>
<% 
} else { 
   java.lang.Integer loginAttempts = (java.lang.Integer) session.getValue("loginAttempts");
   int numTrys = loginAttempts.intValue() + 1;
   if (numTrys > 3 || securityContext3.equalsIgnoreCase("HOST")) {
     Log.println("[400] ApprovalSave.jsp Invalid password (3X) for " + ownersName); %>
     <%@ include file="ReloginRedirectMsg.jsp" %>
<% } else { %>
     <%@ include file="InvalidPasswordMsg.jsp" %>
<% } 
}
%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>
<%@ include file="SendAnEmail.jsp" %>


