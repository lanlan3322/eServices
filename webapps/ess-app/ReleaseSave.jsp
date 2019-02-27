<%--
ReleaseSave.jsp - Marks reports with batch date and "paid" status
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

  SendInfo.setConnection(PersFile.getConnection());
  SendInfo.setSQLTerminator(PersFile.getSQLTerminator());

  Reg.setConnection(PersFile.getConnection()); 
  Reg.setSQLTerminator(PersFile.getSQLTerminator());

  boolean errorCondition = false; 
 
  String pal_address = SendInfo.getSystemString("PAL_EMAIL_ADDRESS","expense@adisoft-inc.com");

  String msgdata = request.getParameter("msgdata");
  String rcpt2 = request.getParameter("rcpt2");
  String reply2 = request.getParameter("reply2");

  java.util.Date currentDate = Dt.getDate();
  String currentDateString = Dt.getSimpleDate(currentDate);
  String currentTimeString = Dt.getSimpleTime(currentDate);

  String backcolor = "class=\"offsetColor\"";
  String oldbackcolor = "";
  String newbackcolor;

%>
  <html>
  <head>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <meta http-equiv="Pragma" content="no-cache">
  <meta http-equiv="Expires" content="-1">

  <title>Processed Reports</title>
  <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
  </head>
  <body>
  <%@ include file="StandardTopNR.jsp" %>
  <br><br><strong><em>
  <big>Processed Reports<br>
  Run date: <%=currentDateString %> at <%=currentTimeString %> 
  </em></strong><br><br>
  <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
  <form>
  <tr>
  <td width="15%" <%=backcolor%> align="center"><u>Voucher</u></td>
  <td width="25%" <%=backcolor%> align="center"><u>Reporter</u></td>
  <td width="15%" <%=backcolor%> align="center"><u>Status</u></td>
  <td width="35%" <%=backcolor%>><u>Message</u></td>
  </tr>
<%  

   newbackcolor = backcolor;
   backcolor = oldbackcolor; 
   oldbackcolor = newbackcolor;


   String report2Approve;
   String report2AppStat;
   String report2Payment;
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
   String newDuplicate;
   String newLimit;
   String notifyMsg;
   String newApprovalType;
   String newSignerColumn;
   String newDateColumn;
   String centralReference;
   String oldStep;
   String comment = "";
   int reportCount = 0;

   String retSQL = SystemDOM.getDOMTableValueFor("releasepayments","retrievesql","");
   String upSQL = SystemDOM.getDOMTableValueFor("releasepayments","updatesql","");
   String upSQLReceipts = SystemDOM.getDOMTableValueFor("releasepayments","updatesqlreceipts","");
   String upSQLExpenses = SystemDOM.getDOMTableValueFor("releasepayments","updatesqlexpenses","");
   String reconSQLReceipts = SystemDOM.getDOMTableValueFor("releasepayments","updateprepopreceipts","");
   String reconSQLStatement = SystemDOM.getDOMTableValueFor("releasepayments","updateprepopitems","");


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
   java.util.StringTokenizer pt = new java.util.StringTokenizer(request.getParameter("payment"), ";"); 
   
   String action = request.getParameter("action");
   boolean actionFlag;
   if (action.equals("result") || action.equals("reject")){
      actionFlag = true;
   } else {
      actionFlag = false;
%>    <br><strong><em>Invalid action criteria - contact support!</em></strong>
<%   Log.println("[500] ReleaseSave.jsp - Invalid action by " + ownersName);
   }
   
   while (rp.hasMoreTokens() && actionFlag) {
     report2Approve = rp.nextToken().trim() ;
     report2AppStat = st.nextToken().trim() ;
	 report2Payment = pt.nextToken().trim() ;
     voucherNumber = voucherNumber + 1;
     
     SQLCommand = retSQL;
   
     if (SQLCommand.equals("")) {
        SQLCommand = "SELECT ";
        SQLCommand += "PERS_NUM, RP_STAT, NAME, RC_AMT, PVOUCHER, DEPART, VOUCHER ";
        SQLCommand += "FROM REPORT ";
        SQLCommand += "WHERE VOUCHER = '$voucher$' AND RP_STAT = '$status$'" + PersFile.getSQLTerminator();
     }
     
     SQLCommand = Reg.SQLReplace(SQLCommand,"$voucher$",report2Approve);
     SQLCommand = Reg.SQLReplace(SQLCommand,"$status$",report2AppStat);
     
     if (Reg.setResultSet(SQLCommand)) {

        persnum = PersFile.getTrim(Reg.myResult.getString(1));  //personnel number
        repstat = PersFile.getTrim(Reg.myResult.getString(2));  //report status
        if (encrypt.equalsIgnoreCase("YES")) {
          bArray = Reg.myResult.getBytes(3);
          E = new String(bArray);
          persname = unScramble(E,encrypt,encryptKey);   
        } else {
          persname = PersFile.getTrim(Reg.myResult.getString(3)); //report name
        }
        receiptAmount = PersFile.getTrim(Reg.myResult.getString(4)); //receipt amount
        userReference = PersFile.getTrim(Reg.myResult.getString(5)); //user reference
        depart = PersFile.getTrim(Reg.myResult.getString(6));        //department
        centralReference = PersFile.getTrim(Reg.myResult.getString(7)); //report reference

        subTable = getRoutingRuleName(DepartDOM, depart, PersFile.depart, Log);

        // Don't know if we need these...
        signerColumn = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"updatesqlsigner");

        xFlag = Reporter.setPersNumInfo(persnum); 
        
        if (xFlag ) {   
%>      <tr><td width="15%" <%=backcolor%> align="center"><%=report2Approve%></td><td width="25%" <%=backcolor%> align="center"><%= persname %></td>
<%          
           signerColumn = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"updatesqlsigner"); 
           dateColumn = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,"updatesqldate"); 

           nextStep = StatusDOM.getDOMTableValueWhere(subTable,"translation",report2AppStat,action);

           newStatusCode = StatusDOM.getDOMTableValueWhere(subTable,"status",nextStep,"translation");
           
           SQLCommand = upSQL;
   
           if (SQLCommand.equals("")) {
              SQLCommand = "UPDATE REPORT SET ";
              SQLCommand += "HISTORY = '$payment$' RP_STAT = '$status$' ";
              SQLCommand += "WHERE RTRIM(VOUCHER) = '$voucher$'" + PersFile.getSQLTerminator();
           }
     
           SQLCommand = Reg.SQLReplace(SQLCommand,"$voucher$",report2Approve);
           SQLCommand = Reg.SQLReplace(SQLCommand,"$status$",newStatusCode);
           SQLCommand = Reg.SQLReplace(SQLCommand,"$payment$",report2Payment);
           SQLCommand = Reg.SQLReplace(SQLCommand,"$date$",SQLDate);
           SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",PersFile.persnum);
           SQLCommand = Reg.SQLReplace(SQLCommand,"$reporter$",persnum);
           
           SQLResult = Reg.doSQLExecute(SQLCommand);

           if ( SQLResult > -1) { 
             comment = "Report released.";
             repDBStat = StatXlation(newStatusCode, CompanyName, StatusDOM); 
             %><td width="15%" <%=backcolor%> align="center"><%= repDBStat %></td><%
             Log.println("[202] ReleaseSave.jsp - report voucher " + report2Approve + " released by " + ownersName + " to " + newStatusCode);

             // Updating the receipts
             SQLCommand = upSQLReceipts;
             if (!SQLCommand.equals("")) {
                  SQLCommand = Reg.SQLReplace(SQLCommand,"$voucher$",report2Approve);
                  SQLCommand = Reg.SQLReplace(SQLCommand,"$status$",newStatusCode);
                  SQLCommand = Reg.SQLReplace(SQLCommand,"$date$",SQLDate);
                  SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",PersFile.persnum);
                  SQLCommand = Reg.SQLReplace(SQLCommand,"$reporter$",persnum);
           
                  SQLResult = Reg.doSQLExecute(SQLCommand);

                  if ( SQLResult <= -1) { 
                  
                    comment = comment + "  Error - Receipt update failed due to database access problem - investigate!";
                    Log.println("[500] ReleaseSave.jsp - receipts update " + report2Approve + " had a database access error: " + SQLResult);
                  } 
             }

             // Updating the expenses
             SQLCommand = upSQLExpenses;
             if (!SQLCommand.equals("")) {
                  SQLCommand = Reg.SQLReplace(SQLCommand,"$voucher$",report2Approve);
                  SQLCommand = Reg.SQLReplace(SQLCommand,"$status$",newStatusCode);
                  SQLCommand = Reg.SQLReplace(SQLCommand,"$date$",SQLDate);
                  SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",PersFile.persnum);
                  SQLCommand = Reg.SQLReplace(SQLCommand,"$reporter$",persnum);
           
                  SQLResult = Reg.doSQLExecute(SQLCommand);

                  if ( SQLResult <= -1) { 
                    comment = comment + "  Error - Expense update failed due to database access problem - investigate!";
                    Log.println("[500] ReleaseSave.jsp - Expense update " + report2Approve + " had a database access error: " + SQLResult);
                  } 
             }
/////////////////////////          
             int ReceiptsReconciled = 0;
             SQLCommand = reconSQLReceipts;
             if (!SQLCommand.equals("")) {
            	 
            	  SQLCommand = Reg.SQLReplace(SQLCommand,"$voucher$",report2Approve);
                  SQLCommand = Reg.SQLReplace(SQLCommand,"$date$",SQLDate);
                  
                  SQLResult = Reg.doSQLExecute(SQLCommand);

                  if ( SQLResult <= -1) { 
                    comment = comment + "  Error - Receipt reconcilement failed due to database access problem - investigate!";
                    Log.println("[500] ReleaseSave.jsp - Receipt reconcilement " + report2Approve + " had a database access error: " + SQLResult);
                  } else {
                	  ReceiptsReconciled = SQLResult;
                  }
             }
             
       
             int ItemsReconciled = 0;
             SQLCommand = reconSQLStatement;
             if (!SQLCommand.equals("")) {
            	 
            	  SQLCommand = Reg.SQLReplace(SQLCommand,"$voucher$",report2Approve);
                  SQLCommand = Reg.SQLReplace(SQLCommand,"$date$",SQLDate);
                  
                  SQLResult = Reg.doSQLExecute(SQLCommand);

                  if ( SQLResult <= -1) { 
                    comment = comment + "  Error - Statement reconcilement failed due to database access problem - investigate!";
                    Log.println("[500] ReleaseSave.jsp - Statement reconcilement " + report2Approve + " had a database access error: " + SQLResult);
                  } else {
                	  ItemsReconciled = SQLResult;
                  }
             }
             
             if (ItemsReconciled != ReceiptsReconciled) {
                 comment = comment + "  Error - Reconcilement issue receipts = " + ReceiptsReconciled + ", prepop items = " + ItemsReconciled;
                 Log.println("[500] ReleaseSave.jsp - Error - Reconcilement issue receipts = " + ReceiptsReconciled + ", prepop items = " + ItemsReconciled);
             } else {
            	 Log.println("[000] ReleaseSave.jsp - Reconcilement items: " + ItemsReconciled + " for " + report2Approve);
             }
////////////////////////////
           } else {   
             %><td width="15%" <%=backcolor%> align="center">Not Released</td><%
             comment = "Error - Report release failed due to database access problem!";
            Log.println("[500] ReleaseSave.jsp - report approval " + report2Approve + " had a database access error: " + SQLResult);
           } 
           %><td width="35%" <%=backcolor%>><%=comment %></td></tr><%
           reportCount = reportCount + 1;   
        } else { %>  
             <tr>
             <td width="15%" <%=backcolor%> align="center"><%=report2Approve %></td>
             <td width="25%" <%=backcolor%> align="center"><%=persnum %></td>
             <td width="15%" <%=backcolor%> align="center"> <%= report2AppStat %></td>
             <td width="35%" <%=backcolor%>>Error - Reporter has not been found!</td>
             </tr>
            <% Log.println("[500] ReleaseSave.jsp - Cannot approve " + report2Approve + " - reporter not found"); 
            %>
     <% }  //Done with the find reporter logic 
     %> 
     
     
  <% } //If the SQL select is OK

     newbackcolor = backcolor;
     backcolor = oldbackcolor; 
     oldbackcolor = newbackcolor;

     comment = "";

   } //While the tokens are still there
%>    
 
<tr>
<td width="15%" <%=backcolor%> align="center"></td>
<td width="25%" <%=backcolor%> align="center"></td>
<td width="15%" <%=backcolor%> align="center">Reports:</td>
<td width="35%" <%=backcolor%> align="right"><%= Integer.toString(reportCount) %></td>
</tr>

</table>
<br><br>
<script langauge="JavaScript">
</script>
<%@ include file="StandardBottomNR.jsp" %>
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
     Log.println("[400] ReleaseSave.jsp Invalid password (3X) for " + ownersName); %>
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
<%@ include file="SendAnEmail.jsp" %>
<%@ include file="DepartRouteRule.jsp" %>




