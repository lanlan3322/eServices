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
  String eMailDA = SystemDOM.getDOMTableValueFor("configuration", "domain_mail", "ivy@elc.com.sg");

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
   if(_status == null){
	   _status = "No reason";
   }

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
   String subjectHR = "Inventory return verified (" + newAsOfDate + ") ";
   String msg3 = "New inventory returns are verified!\n";
   if (action.equals("result") || action.equals("reject") || action.equals("receiptonly") || action.equals("delivered")){
      actionFlag = true;
   } else {
      actionFlag = false;
%>    <br><strong><em>Invalid action criteria - contact support!</em></strong>
<%   Log.println("[500] inventorySave.jsp ln 271 - Invalid action : " + action);
   }
	String name = PersFile.name;
	String emailUser = "";
   if(action.equals("reject"))
   {/*
	   //need to update balance if cancel request start
		String newStatusStr = "SELECT * FROM DB_OPERATED_ITEM WHERE REF_ID_OPERATION = '";
		newStatusStr += _voucher + "'" + PersFile.getSQLTerminator();
		if (Reg.setResultSet(newStatusStr)) {
			try {
				do {
					String sId = PersFile.getTrim(Reg.myResult.getString(1));
					String sAmount = PersFile.getTrim(Reg.myResult.getString(2));
					
					String newStr = "UPDATE DB_ITEM SET ITEM_AMOUNT = ITEM_AMOUNT + ";
					newStr += sAmount;
					newStr += " WHERE ITEM_ID ='" + sId + "'" + PersFile.getSQLTerminator();
					
					SQLResult = Reg2.doSQLExecute(newStr);
				} while (Reg.myResult.next());
			} catch (java.lang.Exception ex) {
				Log.println("[500] ajax/InventoryConfirm.jsp ln100 exception toString : " + ex.toString());
				ex.printStackTrace();
			} //try
		}
	   //need to update balance if cancel request finish

	   _total = _status + "...(REJECTED:" + _total + ")";
           SQLCommand = "UPDATE DB_OPERATION SET OPERATION_STATUS = 'Rejected', OPERATION_REASON = '" + _total + "', OPERATION_DELIVERED ='" + newAsOfDate + "' WHERE OPERATION_ID ='" + _voucher + "'" + PersFile.getSQLTerminator();
           SQLResult = Reg.doSQLExecute(SQLCommand);
		   String SQLCommand2 = "SELECT EMAIL,FNAME,LNAME,MANAGER FROM USER WHERE PERS_NUM = '" + reference + "'" + PersFile.getSQLTerminator();
		   if (Reg.setResultSet(SQLCommand2)) {
			   emailUser = PersFile.getTrim(Reg.myResult.getString(1));
			   name = PersFile.getTrim(Reg.myResult.getString(2)) + " " + PersFile.getTrim(Reg.myResult.getString(3));
			   String numVO = PersFile.getTrim(Reg.myResult.getString(4));
			   String subject = "Rejected inventory request:" + _voucher + "; Reason:" + _total + "!";
			   String msg = "There is inventory request rejected.\nPlease check with Domain Admin!\n";
				String sEmailMsg = "\n  Inventory Request Details:\n";
				String SQLCommand4 = "SELECT * FROM DB_OPERATION WHERE OPERATION_ID='" + _voucher + "'" + PersFile.getSQLTerminator();
				if (Reg.setResultSet(SQLCommand4)) {
				sEmailMsg += "    User Name:  " + name + "\n";
				sEmailMsg += "    User ID:    " + PersFile.getTrim(Reg.myResult.getString(2)) + "\n";
				sEmailMsg += "    Created on: " + PersFile.getTrim(Reg.myResult.getString(3)) + "\n";
				//sEmailMsg += "    Reason:     " + PersFile.getTrim(Reg.myResult.getString(7)) + "\n";
				sEmailMsg += "    Type:       " + PersFile.getTrim(Reg.myResult.getString(9)) + "\n";
				sEmailMsg += "    Rejected:   " + _total + "\n";
				}
			   msg += sEmailMsg;
			   SendAnEmail(emailUser, pal_address, subject, msg, SendInfo);
			   //SendAnEmail(eMailDA, pal_address, subject, msg, SendInfo);
				msg3 = "New inventory request is rejected!\n";
				msg3 += sEmailMsg;
				SendAnEmail(eMailHR, pal_address, subject, msg3, SendInfo);
			   SQLCommand = "SELECT EMAIL FROM USER WHERE PERS_NUM = '" + numVO + "'" + PersFile.getSQLTerminator();
			   if (Reg.setResultSet(SQLCommand)) {
				String eMailVO = PersFile.getTrim(Reg.myResult.getString(1));
				SendAnEmail(eMailVO, pal_address, subject, msg3, SendInfo);
			   }
		   }
Log.println("[500] inventorySave.jsp - request rejected: " + SQLCommand);*/
%>   
<br><strong><em>The inventory request is rejected:</em></strong>
<br><strong><em>Reason: <%= _total%></em></strong>
<br><strong><em>Request Num: <%= _voucher%></em></strong>
<br><strong><em>Person Name: <%= name%></em></strong>
<%   
	}else{
   /// Looping thru the tokens
		while (rp.hasMoreTokens() && actionFlag) {  
		   report2Approve = rp.nextToken().trim() ;
		 //report2AppStat = st.nextToken().trim() ;
		 //leaveTotal = nt.nextToken().trim() ;
		 //leaveType = tp.nextToken().trim() ;
		 //userID = us.nextToken().trim() ;
		 userID = st.nextToken().trim() ;
		 String newStatues = "Prepared";
		 if(action.equals("delivered")){
			 newStatues = "Delivered";
		 }
           SQLCommand = "UPDATE DB_OPERATION SET OPERATION_STATUS = '" + newStatues + "', OPERATION_PREPARED ='" + newAsOfDate + "' WHERE OPERATION_ID ='" + report2Approve + "'" + PersFile.getSQLTerminator();
           SQLResult = Reg.doSQLExecute(SQLCommand);
		Log.println("[500] inventorySave.jsp ln 353 - returns processed: " + SQLCommand);
	   
	   //need to update balance if return start
		String newStatusStr = "SELECT * FROM DB_OPERATED_ITEM WHERE REF_ID_OPERATION = '";
		newStatusStr += report2Approve + "'" + PersFile.getSQLTerminator();
		if (Reg.setResultSet(newStatusStr)) {
			try {
				do {
					String sId = PersFile.getTrim(Reg.myResult.getString(1));
					String sAmount = PersFile.getTrim(Reg.myResult.getString(2));
					
					String newStr = "UPDATE DB_ITEM SET ITEM_AMOUNT = ITEM_AMOUNT + ";
					newStr += sAmount;
					newStr += " WHERE ITEM_ID ='" + sId + "'" + PersFile.getSQLTerminator();
					
					SQLResult = Reg2.doSQLExecute(newStr);
					
					String itemCat = "";
					SQLCommand = "SELECT ITEM_CATEGORY FROM db_item WHERE ITEM_ID = '" + sId + "'" + PersFile.getSQLTerminator();
					if (Reg2.setResultSet(SQLCommand)) { 
						itemCat = PersFile.getTrim(Reg2.myResult.getString(1));
					}
					newStr = "UPDATE db_category SET cat_amount = cat_amount + '";
					newStr += sAmount + "' WHERE cat_name = '";
					newStr += itemCat;
					newStr += "'" + PersFile.getSQLTerminator();
					SQLResult = Reg2.doSQLExecute(newStr);
		
				} while (Reg.myResult.next());
			} catch (java.lang.Exception ex) {
				Log.println("[500] ajax/InventoryConfirm.jsp ln371 exception toString : " + ex.toString());
				ex.printStackTrace();
			} //try
		}
	   //need to update balance if return finish

		}
		rp = new java.util.StringTokenizer(_voucher, ";"); 
		st = new java.util.StringTokenizer(_status, ";"); 
		nt = new java.util.StringTokenizer(_total, ";"); 
		tp = new java.util.StringTokenizer(_type, ";"); 
		us = new java.util.StringTokenizer(_userid, ";"); 
		while (rp.hasMoreTokens() && actionFlag) {  
			report2Approve = rp.nextToken().trim() ;
			//report2AppStat = st.nextToken().trim() ;
			//leaveTotal = nt.nextToken().trim() ;
			//leaveType = tp.nextToken().trim() ;
			//userID = us.nextToken().trim() ;
			userID = st.nextToken().trim() ;
			String subject = subjectHR + report2Approve;
			String sEmailMsg = "\n  Inventory Returns Details:\n";
			String msg = "Your inventory return is verified:\n";
			String SQLCommand3 = "SELECT EMAIL,FNAME,LNAME FROM USER WHERE PERS_NUM = '" + userID + "'" + PersFile.getSQLTerminator();
			if (Reg.setResultSet(SQLCommand3)) {
			   emailUser = PersFile.getTrim(Reg.myResult.getString(1));
			   name = PersFile.getTrim(Reg.myResult.getString(2)) + " " + PersFile.getTrim(Reg.myResult.getString(3));
				//String SQLCommand5 = "SELECT * FROM LEAVERECORD WHERE LEAVE_NUM='" + report2Approve + "'" + PersFile.getSQLTerminator();
				String SQLCommand5 = "SELECT * FROM DB_OPERATION WHERE OPERATION_ID='" + report2Approve + "'" + PersFile.getSQLTerminator();
				if (Reg.setResultSet(SQLCommand5)) {
					sEmailMsg += "    User Name:  " + name + "\n";
					sEmailMsg += "    User ID:    " + PersFile.getTrim(Reg.myResult.getString(2)) + "\n";
					sEmailMsg += "    Created on: " + PersFile.getTrim(Reg.myResult.getString(3)) + "\n";
					sEmailMsg += "    Reason:     " + PersFile.getTrim(Reg.myResult.getString(7)) + "\n";
					sEmailMsg += "    Type:       " + PersFile.getTrim(Reg.myResult.getString(9)) + "\n";
				}
				msg3 += sEmailMsg;
		   }
			
			msg += sEmailMsg;
			SendAnEmail(emailUser, pal_address, subject, msg, SendInfo);
			//SendAnEmail(eMailDA, pal_address, subject, msg, SendInfo);
			msg3 += "\n---------------------------------------------\n\n";

%>
<br><br><strong><em>User : <%= name%>, Reason: <%= PersFile.getTrim(Reg.myResult.getString(7))%></em></strong>
<%	
		} 
		SendAnEmail(eMailDA, pal_address, subjectHR, msg3, SendInfo);
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


