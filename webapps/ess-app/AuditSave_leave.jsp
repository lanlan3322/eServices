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
<jsp:useBean id = "Reg2"
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
<jsp:useBean id = "XM"
     class="ess.SMTPSingle"
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

  Reg2.setConnection(PersFile.getConnection());
  Reg2.setSQLTerminator(PersFile.getSQLTerminator());

  boolean errorCondition = false;

  String pal_address = SendInfo.getSystemString("PAL_EMAIL_ADDRESS","eclaim@elc.com.sg");
  String eMailHR = SystemDOM.getDOMTableValueFor("configuration", "hr_mail", "ivy@elc.com.sg");

  String received = request.getParameter("received");

  CanApprove.setConnection(PersFile.getConnection());
  CanApprove.setSQLTerminator(PersFile.getSQLTerminator());
  CanApprove.setUpFiles();
  CanApprove.setApprover(PersFile);

  String smtp_address = SendInfo.getSystemString("smtp_address","services@elc.com.sg");
  String smtp_port = SendInfo.getSystemString("smtp_port","25");
  String smtp_delimiter = SendInfo.getSystemString("smtp_delimiter",".");
  String smtp_domain = SendInfo.getSystemString("smtp_domain","elc.com.sg");
  String messageBodyType = SendInfo.getSystemString("messages","messagebodytype","body=8BITMIME");
  String contentType = SendInfo.getSystemString("messages","contenttype","text/plain; charset=utf-8");
  String authType = SendInfo.getSystemString("smtp_authtype","none");
  String smtp_logon = SendInfo.getSystemString("smtp_logon","");
  String smtp_password = SendInfo.getSystemString("smtp_password","");

  XM.setIP_URL(smtp_address);
  XM.setPort(smtp_port);
  XM.setDelimiter(smtp_delimiter);
  XM.setDomain(smtp_domain);
  XM.setMessageBodyType(messageBodyType);
  XM.setContentType(contentType);
  XM.setAuthType(authType);
  XM.setAuthID(smtp_logon);
  XM.setAuthCode(smtp_password);

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
   String _total = request.getParameter("msgdata");
   String _type = request.getParameter("reply2");
   String _userid = request.getParameter("rcpt2");
   String reference = request.getParameter("reference");

   java.util.StringTokenizer rp = new java.util.StringTokenizer(_voucher, ";");
   java.util.StringTokenizer st = new java.util.StringTokenizer(_status, ";");
   java.util.StringTokenizer nt = new java.util.StringTokenizer(_total, ";");
   java.util.StringTokenizer tp = new java.util.StringTokenizer(_type, ";");
   java.util.StringTokenizer us = new java.util.StringTokenizer(_userid, ";");

   String receiptNumberString = request.getParameter("receipts");

   //////java.util.StringTokenizer rp = new java.util.StringTokenizer(request.getParameter("voucher"), ";");

   String action = request.getParameter("action");
   boolean actionFlag;
   String leaveTotal = "0";
   String leaveBalanceNew = "0";
   String leaveType = "0";
   String userID = "0";
   String leaveBalance = "0";
   String subjectHR = "Leave approved:";
   String msg3 = "New leave application is approved by AO and the balance is updated!\n";
   if (action.equals("result") || action.equals("reject") || action.equals("receiptonly")){
      actionFlag = true;
   } else {
      actionFlag = false;
%>    <br><strong><em>Invalid action criteria - contact support!</em></strong>
<%   Log.println("[500] AuditSave.jsp - Invalid action by " + ownersName);
   }
	String name = PersFile.name;
	String emailUser = "";
   if(action.equals("reject"))
   {
		_total = _status + "(REJECTED by AO:" + _total + ")";
           SQLCommand = "UPDATE LEAVERECORD SET LEAVE_STATUS = 'Rejected', LEAVE_REASON = '" + _total + "' WHERE LEAVE_NUM ='" + _voucher + "'" + PersFile.getSQLTerminator();
           SQLResult = Reg.doSQLExecute(SQLCommand);
		   String SQLCommand2 = "SELECT EMAIL,FNAME,LNAME,MANAGER FROM USER WHERE PERS_NUM = '" + reference + "'" + PersFile.getSQLTerminator();
		   if (Reg.setResultSet(SQLCommand2)) {
			   emailUser = PersFile.getTrim(Reg.myResult.getString(1));
			   name = PersFile.getTrim(Reg.myResult.getString(2)) + " " + PersFile.getTrim(Reg.myResult.getString(3));
			   String numVO = PersFile.getTrim(Reg.myResult.getString(4));
			   String subject = "Rejected leave:" + _voucher + "; Reason:" + _total + " By AO!";
			   String msg = "There is leave rejected by AO.\nPlease verify it!\n";
				String sEmailMsg = "\n  Leave Details:\n";
				String SQLCommand4 = "SELECT * FROM LEAVERECORD WHERE LEAVE_NUM='" + _voucher + "'" + PersFile.getSQLTerminator();
				if (Reg.setResultSet(SQLCommand4)) {
				sEmailMsg += "    User Name:  " + name + "\n";
				sEmailMsg += "    User ID:         " + PersFile.getTrim(Reg.myResult.getString(1)) + "\n";
				sEmailMsg += "    Department: " + PersFile.getTrim(Reg.myResult.getString(2)) + "\n";
				sEmailMsg += "    From:             " + PersFile.getTrim(Reg.myResult.getString(8));
				sEmailMsg += " " + PersFile.getTrim(Reg.myResult.getString(9)) + "\n";
				sEmailMsg += "    To:                  " + PersFile.getTrim(Reg.myResult.getString(10));
				sEmailMsg += " " + PersFile.getTrim(Reg.myResult.getString(11)) + "\n";
				sEmailMsg += "    Total:             " + PersFile.getTrim(Reg.myResult.getString(5)) + "\n";
				sEmailMsg += "    Type:              " + PersFile.getTrim(Reg.myResult.getString(7)) + "\n";
				sEmailMsg += "    Reason:         " + PersFile.getTrim(Reg.myResult.getString(13)) + "\n";
				sEmailMsg += "    Created on:  " + PersFile.getTrim(Reg.myResult.getString(6));
				}
			   msg += sEmailMsg;
			   SendAnEmail(emailUser, pal_address, subject, msg, SendInfo);
				msg3 = "New leave application is rejected by AO!\n";
				msg3 += sEmailMsg;
				SendAnEmail(eMailHR, pal_address, subject, msg3, SendInfo);
			   SQLCommand = "SELECT EMAIL FROM USER WHERE PERS_NUM = '" + numVO + "'" + PersFile.getSQLTerminator();
			   if (Reg.setResultSet(SQLCommand)) {
				String eMailVO = PersFile.getTrim(Reg.myResult.getString(1));
				SendAnEmail(eMailVO, pal_address, subject, msg3, SendInfo);
			   }
		   }
%>
<br><strong><em>The leave is rejected:</em></strong>
<br><strong><em>Reason: <%= _total%></em></strong>
<br><strong><em>Leave Num: <%= _voucher%></em></strong>
<br><strong><em>Person Num: <%= reference%></em></strong>
<%
	}else{
   /// Looping thru the tokens
		while (rp.hasMoreTokens() && actionFlag) {
		   report2Approve = rp.nextToken().trim() ;
		 report2AppStat = st.nextToken().trim() ;
		 leaveTotal = nt.nextToken().trim() ;
		 leaveType = tp.nextToken().trim() ;
		 userID = us.nextToken().trim() ;
           SQLCommand = "UPDATE LEAVERECORD SET LEAVE_STATUS = 'Approved' WHERE LEAVE_NUM ='" + report2Approve + "'" + PersFile.getSQLTerminator();
           SQLResult = Reg.doSQLExecute(SQLCommand);


				String[] dataValue = newAsOfDate.split("-");
				int yearValue = Integer.parseInt(dataValue[0]);
				int monthValue = Integer.parseInt(dataValue[1]);
				String[] dataValueTo = report2AppStat.split("-");
				int yearValueTo = Integer.parseInt(dataValueTo[0]);
				if(yearValueTo > yearValue){
					continue;
				}


			String strType = leaveType;
		   if(leaveType.equalsIgnoreCase("Off In Lieu")){
				strType = "OFINLIEU";
		   }
		   else if(leaveType.equalsIgnoreCase("Hospitalisation")){
				strType = "HOSPITAL";
		   }
		   else if(leaveType.equalsIgnoreCase("Compassionate")){
				strType = "COMP";
		   }
		   else if(leaveType.equalsIgnoreCase("Compassionate Next-of-kin")){
				strType = "COMP_NEXTOFKIN";
		   }
           SQLCommand = "SELECT " + strType + "_BAL, BRING_FORWARD, UNPAID_BAL FROM LEAVEINFO WHERE PERS_NUM ='" + userID + "'" + PersFile.getSQLTerminator();
		   if (Reg.setResultSet(SQLCommand)) {
			   leaveBalance = PersFile.getTrim(Reg.myResult.getString(1));
			   String leaveBringForward = PersFile.getTrim(Reg.myResult.getString(2));
			   if(monthValue > 6){
				   leaveBringForward = "0";
			   }
			   String leaveUnpaidBalance = PersFile.getTrim(Reg.myResult.getString(3));
				if(leaveType.equalsIgnoreCase("Annual")){
					float leaveTotalBalance = Float.parseFloat(leaveBalance) + Float.parseFloat(leaveBringForward);
					float value = leaveTotalBalance - Float.parseFloat(leaveTotal);
				   if(value <= 0){
					   leaveBalance = "0";
					   leaveBringForward = "0";
					   float newBalance = Float.parseFloat(leaveUnpaidBalance) + value;
					   leaveUnpaidBalance = String.valueOf(newBalance);
					}
					else{
						value = Float.parseFloat(leaveBringForward) - Float.parseFloat(leaveTotal);
						if(value <= 0){
						   leaveBringForward = "0";
						   float newBalance = Float.parseFloat(leaveBalance) + value;
						   leaveBalance = String.valueOf(newBalance);
						}
						else{
						   leaveBringForward = String.valueOf(value);
						}
					}
				}
				else{
					leaveBalance = String.valueOf(Float.parseFloat(leaveBalance) - Float.parseFloat(leaveTotal));
				}
				   SQLCommand = "UPDATE LEAVEINFO SET UNPAID_BAL = ";
				   SQLCommand += leaveUnpaidBalance;
				   if(monthValue < 7){
						SQLCommand += ", BRING_FORWARD = " + leaveBringForward;
					}
				   SQLCommand += ", " + strType + "_BAL =" + leaveBalance + " WHERE PERS_NUM ='" + userID + "'" + PersFile.getSQLTerminator();
				   SQLResult = Reg.doSQLExecute(SQLCommand);
		   }
		}

		rp = new java.util.StringTokenizer(_voucher, ";");
		st = new java.util.StringTokenizer(_status, ";");
		nt = new java.util.StringTokenizer(_total, ";");
		tp = new java.util.StringTokenizer(_type, ";");
		us = new java.util.StringTokenizer(_userid, ";");
		while (rp.hasMoreTokens() && actionFlag) {
			report2Approve = rp.nextToken().trim() ;
			report2AppStat = st.nextToken().trim() ;
			leaveTotal = nt.nextToken().trim() ;
			leaveType = tp.nextToken().trim() ;
			userID = us.nextToken().trim() ;
			String subject = subjectHR + report2Approve;
			String sEmailMsg = "\n  Leave Details:\n";
			String msg = "Your leave is approved:\n";
			String SQLCommand3 = "SELECT EMAIL,FNAME,LNAME FROM USER WHERE PERS_NUM = '" + userID + "'" + PersFile.getSQLTerminator();
			if (Reg.setResultSet(SQLCommand3)) {
			   emailUser = PersFile.getTrim(Reg.myResult.getString(1));
			   name = PersFile.getTrim(Reg.myResult.getString(2)) + " " + PersFile.getTrim(Reg.myResult.getString(3));
				String SQLCommand5 = "SELECT * FROM LEAVERECORD WHERE LEAVE_NUM='" + report2Approve + "'" + PersFile.getSQLTerminator();
				if (Reg.setResultSet(SQLCommand5)) {
					sEmailMsg += "    User Name:    " + name + "\n";
					sEmailMsg += "    User ID:         " + PersFile.getTrim(Reg.myResult.getString(1)) + "\n";
					sEmailMsg += "    Department:   " + PersFile.getTrim(Reg.myResult.getString(2)) + "\n";
					sEmailMsg += "    From:             " + PersFile.getTrim(Reg.myResult.getString(8));
					sEmailMsg += " " + PersFile.getTrim(Reg.myResult.getString(9)) + "\n";
					sEmailMsg += "    To:                  " + PersFile.getTrim(Reg.myResult.getString(10));
					sEmailMsg += " " + PersFile.getTrim(Reg.myResult.getString(11)) + "\n";
					sEmailMsg += "    Total:             " + PersFile.getTrim(Reg.myResult.getString(5)) + "\n";
					sEmailMsg += "    Type:              " + PersFile.getTrim(Reg.myResult.getString(7)) + "\n";
					sEmailMsg += "    Reason:          " + PersFile.getTrim(Reg.myResult.getString(13)) + "\n";
					sEmailMsg += "    Created on:    " + PersFile.getTrim(Reg.myResult.getString(6));
    		   String strType = leaveType;
    		   if(leaveType.equalsIgnoreCase("Off In Lieu")){
    				strType = "OFINLIEU";
    		   }
    		   else if(leaveType.equalsIgnoreCase("Hospitalisation")){
    				strType = "HOSPITAL";
    		   }
    		   else if(leaveType.equalsIgnoreCase("Compassionate")){
    				strType = "COMP";
    		   }
    		   else if(leaveType.equalsIgnoreCase("Compassionate Next-of-kin")){
    				strType = "COMP_NEXTOFKIN";
    		   }
               SQLCommand = "SELECT " + strType + "_BAL, BRING_FORWARD, UNPAID_BAL FROM LEAVEINFO WHERE PERS_NUM ='" + userID + "'" + PersFile.getSQLTerminator();
    		   if (Reg.setResultSet(SQLCommand)) {
    			   leaveBalance = PersFile.getTrim(Reg.myResult.getString(1));
    		   }
           msg3 += sEmailMsg;
           msg3 += "\n---------------------------------------------\n\n";
    		   msg += sEmailMsg + "\n\n    LeaveBalance = " +leaveBalance ;
    			   msg += " (" + strType + ")";
    			   SendAnEmail(emailUser, pal_address, subject, msg, SendInfo);
        }
      }

%>
<br><br><strong><em>User Num: <%= userID%>, Leave Total: <%= leaveTotal%></em></strong>
<%
		}
			SendAnEmail(eMailHR, pal_address, subjectHR, msg3, SendInfo);
	}
%>
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
  var x = setTimeout("init()",1000);
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
