<%--
HistoryList.jsp - List out reports from central database
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
<jsp:useBean id = "Reg3"
     class="ess.AdisoftDbase"
     scope="page" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "Reporter"
     class="ess.PersonnelTable"
     scope="page" />
<jsp:useBean id = "CanApprove"
     class="ess.Approver"
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
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />


<%@ include file="../DBAccessInfo.jsp" %>
<%@ include file="../NumericSetup.jsp" %>
<%

String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String CCode = "";
String database = request.getParameter("database");

String ownersName = request.getParameter("email");

Log.println("[000] ajax/HistoryList.jsp start:" + ownersName);

boolean pFlag = PersFile.setPersInfo(ownersName);
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode");
  CanApprove.setApprover(PersFile);
}

if (pFlag && PersFile.getChallengeCode().equals(CCode)) {
//if (pFlag) {
%>
<%@ include file="../StatusInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>
<%
   Reg.setConnection(PersFile.getConnection());
   Reg.setSQLTerminator(PersFile.getSQLTerminator());

   Reg2.setConnection(PersFile.getConnection());
   Reg2.setSQLTerminator(PersFile.getSQLTerminator());

   Reg3.setConnection(PersFile.getConnection());
   Reg3.setSQLTerminator(PersFile.getSQLTerminator());

   Reporter.setConnection(PersFile.getConnection());
   Reporter.setSQLTerminator(PersFile.getSQLTerminator());
   Reporter.setSQLStrings();

   CanApprove.setConnection(PersFile.getConnection());
   CanApprove.setSQLTerminator(PersFile.getSQLTerminator());
   CanApprove.setUpFiles();

   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);

   // String reportScript = SystemDOM.getDOMTableValueFor("history","ajaxscreenscript","ajax/HistoryReportV2.jsp");
   // The following lines replace the single line above

   String reportScript = SystemDOM.getDOMTableValueWhere("entryscreenmapping","entryscreen",PersFile.getEntryScreen(),"ajaxscreenscript");
   if ((reportScript == null) || (reportScript.equals(""))) {
    reportScript = SystemDOM.getDOMTableValueFor("history","ajaxscreenscript","ajax/HistoryReportV2.jsp");
   }

   String downlevel = request.getParameter("level");

   int checkLevelsDown = 1;
   if (downlevel != null) checkLevelsDown = java.lang.Integer.parseInt(downlevel);

   String persnumber = PersFile.persnum;    //need to replace with a PersFile.get...()

   String reporttype = request.getParameter("reporttype");
   if (reporttype == null) reporttype = "ajaxreporter";
   String begDateStr = request.getParameter("begdate");
   String endDateStr = request.getParameter("enddate");

   String SQLType = null;
   String begDateSQL = null;
   String endDateSQL = null;
   String begDateXB = null;
   String endDateXB = null;
     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
     String newbackcolor;
   String leaveNum = "";
   SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");

   if ((begDateStr != null) && (endDateStr != null))
   {

      begDateSQL = Dt.getSQLDate(Dt.getDateFromStr(begDateStr));  //need this format for 2 purposes
      endDateSQL = Dt.getSQLDate(Dt.getDateFromStr(endDateStr));

      if (SQLType.equals("MM/DD/YYYY")) {
        begDateXB = begDateStr;
        endDateXB = endDateStr;
      } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
        begDateXB = Dt.getOracleDate(Dt.getDateFromStr(begDateStr));
        endDateXB = Dt.getOracleDate(Dt.getDateFromStr(endDateStr));
      } else {    // s/b YYYY-MM-DD
        begDateXB = begDateSQL;
        endDateXB = endDateSQL;
      }
   }
   String approvalType = SystemDOM.getDOMTableValueFor("history","approval");
	String ANNUAL_BAL="0";
	String ANNUAL_ENT="0";
	String MARRIAGE_BAL="0";
	String MARRIAGE_ENT="0";
	String CHILDCARE_BAL="0";
	String CHILDCARE_ENT="0";
	String MEDICAL_BAL="0";
	String MEDICAL_ENT="0";
	String HOSPITAL_BAL="0";
	String HOSPITAL_ENT="0";
	String PATERNITY_BAL="0";
	String PATERNITY_ENT="0";
	String MATERNITY_BAL="0";
	String MATERNITY_ENT="0";
	String COMP_BAL="0";
	String COMP_ENT="0";
	String COMP_NEXTOFKIN_BAL="0";
	String COMP_NEXTOFKIN_ENT="0";
	String OFINLIEU_BAL="0";
	String OFINLIEU_ENT="0";
	String RESERVIST_BAL="0";
	String RESERVIST_ENT="0";
	String UNPAID_BAL="0";
	String UNPAID_ENT="0";
	String BRING_FORWARD="0";
	String ADVANCE_LEAVE="0";
	String PENDING_LEAVE="0";
	String ADDED_LEAVE="0";
   String SQLCommand = SystemDOM.getDOMTableValueFor("history",reporttype);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",persnumber);
   if (begDateStr != null) SQLCommand = Reg.SQLReplace(SQLCommand,"$begdate$",begDateXB);
   if (endDateStr != null) SQLCommand = Reg.SQLReplace(SQLCommand,"$enddate$",endDateXB);
   Log.println("[000] ajax/HistoryList.jsp SQL:" + SQLCommand);
   if (begDateStr != null) Log.println("[000] ajax/HistoryList.jsp begDate:" + begDateXB + " SQL: " + begDateSQL);
   if (endDateStr != null) Log.println("[000] ajax/HistoryList.jsp endDate:" + endDateXB + " SQL: " + endDateSQL);
%>

<%
//Inventory history start
if(true)//PersFile.depart.equalsIgnoreCase("TEST") || PersFile.depart.equalsIgnoreCase("MMT"))
{
	%>
<div id="expenseReport5" class="reportSection" style="display: none">
	<a class="titleForm" href="javascript: void hideDataFields('expenseReport5', showDataFields('expenseReportHidden5'), hideDataFields('expenseReportOptions5'))">Inventory History (Click here to open/close details)<span id="reportUsersReference5"></span></a>
<%
   String SQLInv = SystemDOM.getDOMTableValueFor("history","inventory_request_all");
   SQLInv = Reg.SQLReplace(SQLInv,"$persnum$",persnumber);


	if (Reg.setResultSet(SQLInv)) {

    try {
     do {
		String OPERATION_ID=PersFile.getTrim(Reg.myResult.getString(1));
		String OPERATION_BY=PersFile.getTrim(Reg.myResult.getString(2));
		String OPERATION_CREATED=PersFile.getTrim(Reg.myResult.getString(3));
		String OPERATION_DELIVERED=PersFile.getTrim(Reg.myResult.getString(4));
		String OPERATION_PREPARED=PersFile.getTrim(Reg.myResult.getString(5));
		String OPERATION_SIGNED=PersFile.getTrim(Reg.myResult.getString(6));
		String OPERATION_REASON=PersFile.getTrim(Reg.myResult.getString(7));
		String OPERATION_STATUS=PersFile.getTrim(Reg.myResult.getString(8));
		String OPERATION_TYPE=PersFile.getTrim(Reg.myResult.getString(9));
		String PERS_NAME=OPERATION_CREATED;
			PERS_NAME += " - " + OPERATION_REASON;
		String divIDreporter = "Report" + OPERATION_ID;
		String divHiddenreporter = "Hidden" + OPERATION_ID;
		String divOptionreporter = "Option" + OPERATION_ID;
		String divRefreporter = "Ref" + OPERATION_ID;

		String divID = "Report" + PERS_NAME;
		String divHidden = "Hidden" + PERS_NAME;
		String divOption = "Option" + PERS_NAME;
		String divRef = "Ref" + PERS_NAME;
		backcolor = "class=\"offsetColor\"";
		oldbackcolor = "";
		newbackcolor = backcolor;
%>

<%
   String SQLCommand_Leave1 = SystemDOM.getDOMTableValueFor("history","inventory_items");
   SQLCommand_Leave1 = Reg3.SQLReplace(SQLCommand_Leave1,"$persnum$",OPERATION_ID);
%>
<div id="<%=divIDreporter%>" class="reportSection" style="display: none">
	<a class="titleForm" href="javascript: void hideDataFields('<%=divIDreporter%>', showDataFields('<%=divHiddenreporter%>'), hideDataFields('<%=divOptionreporter%>'))">[ <%=OPERATION_STATUS%> - <%=OPERATION_TYPE%> ] <%= PERS_NAME%><span id="<%=divRefreporter%>"></span></a>

<%if (Reg3.setResultSet(SQLCommand_Leave1)) {

     String persname;
     byte[] bArray;    //used for encrypted values
     String E;         //     ditto
     boolean xFlag;
     boolean xfound = false;
     String voucher = "";
     String pvoucher = "";
     String reference;
     String repdate;
     String repamt;
     String repStat;
     String repDBStat;
	 String reason;
	 String created;
	 String total;
     int adjustment = 0; //see status.xml
%>
	<%	if(OPERATION_STATUS.equalsIgnoreCase("Delivered") && OPERATION_TYPE.equalsIgnoreCase("Request")){
	%>
        <input id="btSave" type="button" name="B1" value="Return"  onClick="Javascript: void returnItems('<%=OPERATION_ID%>')">
	<%	}
	%>
	<table id="previousTable" border="0" cellspacing="0" cellpadding="0">
     <thead>
         <tr>
			 <td class="ExpenseTag" width="5%" <%=backcolor%>>&nbsp;</td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>>Name</td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>>Category</td>
             <td class="ExpenseTag" width="65%" <%=backcolor%>>Description</td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>>Amount</td>
         </tr>
     </thead>

<%
		backcolor = "class=\"offsetColor\"";
		oldbackcolor = "";
		newbackcolor = backcolor;

    try {
		do {
			String sName = PersFile.getTrim(Reg3.myResult.getString(1));
			String sCat = PersFile.getTrim(Reg3.myResult.getString(2));
			String sDesc = PersFile.getTrim(Reg3.myResult.getString(3));
			String sAmount = PersFile.getTrim(Reg3.myResult.getString(4));

     %>
            <tr>
			<td width="5%" <%=backcolor%>>&nbsp;</td>
            <td width="10%" <%=backcolor%>><%= sName%></td>
            <td width="10%" <%=backcolor%>><%= sCat%></td>
            <td width="65%" <%=backcolor%>><%= sDesc%></td>
            <td width="10%"  <%=backcolor%>><%= sAmount%></td>
            </tr>
     <%     xfound = true;
            newbackcolor = backcolor;
            backcolor = oldbackcolor;
            oldbackcolor = newbackcolor;
     } while (Reg3.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] ajax/HistoryList.jsp exception toString : " + ex.toString());
    ex.printStackTrace();
%>
    <h2>Error in the SQL logic - contact support.<h2>
<%
  } //try
%>
  </table>

<% if (!xfound) { %>
<h2>
<%= Lang.getString("REPORTS_NOT_FOUND") %><br>
</h2>
<% } %>
<% } else { %>
    <div class="ExpenseTag">
    <%=PersFile.name%>, <%= Lang.getString("REPORTS_NOT_FOUND") %>
    <% Log.println("[400] ajax/HistoryList.jsp No expense reports where found."); %>
    </div>
<% } //if (Reg.setResultSet(SQLCommand))
%>

</div>
<div id="<%=divHiddenreporter%>" class="reportSection">
	<a class="titleForm" href="javascript: void showDataFields('<%=divIDreporter%>', showDataFields('<%=divOptionreporter%>'), hideDataFields('<%=divHiddenreporter%>'))"> [ <%=OPERATION_STATUS%> - <%=OPERATION_TYPE%> ] <%= PERS_NAME%><span id="<%=divRefreporter%>"></span></a>
    <div><a href="javascript: void showDataFields('<%=divIDreporter%>', showDataFields('<%=divOptionreporter%>'), hideDataFields('<%=divHiddenreporter%>'))">click here <span>to open inventory history</span></a></div>
</div>


<%
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    ex.printStackTrace();
%>
    <h2>Error in the SQL logic - contact support.<h2>
<%
  } //try
%>
  </table>
<% } else { %>
    <div class="ExpenseTag">
    <%=PersFile.name%>, <%= Lang.getString("REPORTS_NOT_FOUND") %>
    <% Log.println("[400] ajax/HistoryList.jsp No expense reports where found."); %>
    </div>
<% } //if (Reg.setResultSet(SQLCommand))
%>
</div>

<div id="expenseReportHidden5" class="reportSection">
	<a class="titleForm" href="javascript: void showDataFields('expenseReport5', showDataFields('expenseReportOptions5'), hideDataFields('expenseReportHidden5'))">Inventory History (Click here to open/close details)<span id="reportUsersReference5"></span></a>
    <div><a href="javascript: void showDataFields('expenseReport5', showDataFields('expenseReportOptions5'), hideDataFields('expenseReportHidden5'))">click here <span>to open inventory details</span></a></div>
</div>
<%
}//test department finish
//Inventory history finish
%>
<div id="expenseReport1" class="reportSection" style="display: none">
	<a class="titleForm" href="javascript: void hideDataFields('expenseReport1', showDataFields('expenseReportHidden1'), hideDataFields('expenseReportOptions1'))"><%= Lang.getString("HIS_WELCOME")%> (Click here to open/close details)<span id="reportUsersReference"></span></a>

<%   if (Reg.setResultSet(SQLCommand)) {

     String persname;
     byte[] bArray;    //used for encrypted values
     String E;         //     ditto
     boolean xFlag;
     boolean xfound = false;
     String voucher = "";
     String pvoucher = "";
     String reference;
     String repdate;
     String repamt;
     String repStat;
     String repDBStat;
     int adjustment = 0; //see status.xml
%>
     <script>
     //<%= SQLCommand %>//
     </script>

     <table id="previousTable" border="0" cellspacing="0" cellpadding="0">
     <thead>
         <tr>
             <th width="5%" <%=backcolor%>>&nbsp;</th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("reportReferenceName") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("reportUserReference") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("date") %></th>
             <th width="20%" <%=backcolor%>><%= Lang.getColumnTitle("name") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("amount") %></th>
             <th width="25%" <%=backcolor%>><%= Lang.getColumnTitle("paymentStatus") %></th>
             <th width="10%" <%=backcolor%>></th>
         </tr>
     </thead>
<%
		backcolor = "class=\"offsetColor\"";
		oldbackcolor = "";
		newbackcolor = backcolor;

    try {
     do {
//SQL order RP_STAT, PERS_NUM, VOUCHER, PVOUCHER, SUB_DATE, NAME,RE_AMT
        repStat = PersFile.getTrim(Reg.myResult.getString(1));
        reference = PersFile.getTrim(Reg.myResult.getString(2)); //used for subordinate lookup
        voucher = PersFile.getTrim(Reg.myResult.getString(3));
        pvoucher = PersFile.getTrim(Reg.myResult.getString(4));
        repdate = PersFile.getTrim(Reg.myResult.getString(5));
        if (encrypt.equalsIgnoreCase("YES")) {
          bArray = Reg.myResult.getBytes(6);
          E = new String(bArray);
          persname = unScramble(E,encrypt,encryptKey);
        } else {
          persname = PersFile.getTrim(Reg.myResult.getString(6));
        }
        repamt = PersFile.getTrim(Reg.myResult.getString(7));

        //Log.println("[000] HistoryList.jsp voucher: " + voucher + ", " + repdate);

        repDBStat = StatXlation(repStat, CompanyName, StatusDOM);

        // This is necessary due to Oracle
        if (repdate != null && !repdate.equals("")) {
           if (SQLType.equalsIgnoreCase("MM/DD/YYYY")) {
           } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
             repdate = Dt.getSQLDate(Dt.getOracleSQLDate(repdate));
           } else {    // s/b YYYY-MM-DD
           }
        } else {
           Log.println("[400] ajax/HistoryList.jsp repdate is null or blank - " + voucher);
        }
        if ((begDateStr == null) || (repdate != null && repdate.compareTo(begDateSQL) > -1  && repdate.compareTo(endDateSQL) < 1)) {
          xFlag = true;
          if (reporttype.equals("subordinates")) {
            if (xFlag = Reporter.setPersNumInfo(reference)) {;
               xFlag = CanApprove.canApprove(Reporter, approvalType, checkLevelsDown + adjustment);
            }
          }
          if (xFlag) {
     %>
            <tr>
            <td width="5%" <%=backcolor%>>&nbsp;</td>
            <td width="10%" <%=backcolor%>><%= voucher%></td>
            <td width="10%" <%=backcolor%>><%= pvoucher%></td>
            <td width="10%" <%=backcolor%>><%= Dt.getUserDateStr(Dt.getSimpleDate(Dt.getDateFromXBase(repdate)),PersFile.getDateFormat())%></td>
            <td width="20%" <%=backcolor%>><%= persname%></td>
            <td width="10%" <%=backcolor%>><%= money.format(money.parse(repamt))%></td>
            <td width="25%" <%=backcolor%>><%= Lang.getDataString(repDBStat) %></td>
            <td width="10%" <%=backcolor%>><a href="javascript: void parent.writeDelayMsg('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/<%= reportScript %>?email=<%= PersFile.repStr(ownersName,"'","\\'") %>&rcpt2=<%= Reporter.getPrintableEmailAddress()%>&reference=<%= reference%>&voucher=<%= voucher%>&ccode=<%= CCode%>&status=<%= repStat%>&database=<%= database%>')"><span class="ExpenseReturnLink"><%= Lang.getString("select")%></span></a></td>
            </tr>
     <%     xfound = true;
            newbackcolor = backcolor;
            backcolor = oldbackcolor;
            oldbackcolor = newbackcolor;
          }
        }
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] ajax/HistoryList.jsp java.lang exception possibly voucher: " + voucher);
    Log.println("[500] ajax/HistoryList.jsp exception toString : " + ex.toString());
    ex.printStackTrace();
%>
    <h2>Error in the SQL logic - contact support.<h2>
<%
  } //try
%>
  </table>

<% } else { %>
    <div class="ExpenseTag">
    <%=PersFile.name%>, <%= Lang.getString("REPORTS_NOT_FOUND") %>
    <% Log.println("[400] ajax/HistoryList.jsp No expense reports where found."); %>
    </div>
<% } //if (Reg.setResultSet(SQLCommand))
%>
</div>

<div id="expenseReportHidden1" class="reportSection">
	<a class="titleForm" href="javascript: void showDataFields('expenseReport1', showDataFields('expenseReportOptions1'), hideDataFields('expenseReportHidden1'))"><%= Lang.getString("HIS_WELCOME")%> (Click here to open/close details)<span id="reportUsersReference"></span></a>
    <div><a href="javascript: void showDataFields('expenseReport1', showDataFields('expenseReportOptions1'), hideDataFields('expenseReportHidden1'))">click here <span>to open claim history</span></a></div>
</div>
<hr/>
<%
//if(PersFile.depart.equalsIgnoreCase("TEST") || PersFile.depart.equalsIgnoreCase("MMT"))
{
   String SQLCommand_Leave = SystemDOM.getDOMTableValueFor("history","reporter_leave");
   SQLCommand_Leave = Reg.SQLReplace(SQLCommand_Leave,"$persnum$",persnumber);
%>
<div id="expenseReport2" class="reportSection" style="display: none">
	<a class="titleForm" href="javascript: void hideDataFields('expenseReport2', showDataFields('expenseReportHidden2'), hideDataFields('expenseReportOptions2'))">Leave History (Click here to open/close details)<span id="reportUsersReference2"></span></a>

<%if (Reg.setResultSet(SQLCommand_Leave)) {

     String persname;
     byte[] bArray;    //used for encrypted values
     String E;         //     ditto
     boolean xFlag;
     boolean xfound = false;
     String voucher = "";
     String pvoucher = "";
     String reference;
     String repdate;
     String repamt;
     String repStat;
     String repDBStat;
	 String reason;
	 String created;
	 String total;
     int adjustment = 0; //see status.xml
%>
     <script>
     //<%= SQLCommand %>//
     </script>

     <table id="previousTable" border="0" cellspacing="0" cellpadding="0">
     <thead>
         <tr>
             <th width="5%" <%=backcolor%>>&nbsp;</th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_CREATED") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TYPE") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_FROM") %></th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_FROM_AMPM") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TO") %></th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TO_AMPM") %></th>
             <th width="5%" <%=backcolor%>>Total</th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_STATUS") %></th>
             <th width="30%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_REASON") %></th>
             <th width="5%" <%=backcolor%>>Receipts</th>
         </tr>
     </thead>
<%
		backcolor = "class=\"offsetColor\"";
		oldbackcolor = "";
		newbackcolor = backcolor;

    try {
     do {
//SQL order RP_STAT, PERS_NUM, VOUCHER, PVOUCHER, SUB_DATE, NAME,RE_AMT
        total = PersFile.getTrim(Reg.myResult.getString(5));
         persname = PersFile.getTrim(Reg.myResult.getString(10));
        repStat = PersFile.getTrim(Reg.myResult.getString(12));
        reference = PersFile.getTrim(Reg.myResult.getString(1)); //used for subordinate lookup
        voucher = PersFile.getTrim(Reg.myResult.getString(7));
        pvoucher = PersFile.getTrim(Reg.myResult.getString(8));
        repdate = PersFile.getTrim(Reg.myResult.getString(9));
        repamt = PersFile.getTrim(Reg.myResult.getString(11));
		reason = PersFile.getTrim(Reg.myResult.getString(13));
		created = PersFile.getTrim(Reg.myResult.getString(6));
		leaveNum = PersFile.getTrim(Reg.myResult.getString(4));
        //Log.println("[000] HistoryList.jsp voucher: " + voucher + ", " + repdate);
		created = Dt.getUserDateStr(Dt.getSimpleDate(Dt.getDateFromXBase(created)),PersFile.getDateFormat());
		pvoucher = Dt.getUserDateStr(Dt.getSimpleDate(Dt.getDateFromXBase(pvoucher)),PersFile.getDateFormat());
		persname = Dt.getUserDateStr(Dt.getSimpleDate(Dt.getDateFromXBase(persname)),PersFile.getDateFormat());
        repDBStat = StatXlation(repStat, CompanyName, StatusDOM);

        // This is necessary due to Oracle
        if (repdate != null && !repdate.equals("")) {
           if (SQLType.equalsIgnoreCase("MM/DD/YYYY")) {
           } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
             repdate = Dt.getSQLDate(Dt.getOracleSQLDate(repdate));
           } else {    // s/b YYYY-MM-DD
           }
        } else {
           Log.println("[400] ajax/HistoryList.jsp repdate is null or blank - " + voucher);
        }
        if (repamt != null && !repamt.equals("")) {
           if (SQLType.equalsIgnoreCase("MM/DD/YYYY")) {
           } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
             repamt = Dt.getSQLDate(Dt.getOracleSQLDate(repamt));
           } else {    // s/b YYYY-MM-DD
           }
        } else {
           Log.println("[400] ajax/HistoryList.jsp repamt is null or blank - " + voucher);
        }
        if ((begDateStr == null) || (repdate != null && repdate.compareTo(begDateSQL) > -1  && repdate.compareTo(endDateSQL) < 1)) {
          xFlag = true;
          if (reporttype.equals("subordinates")) {
            if (xFlag = Reporter.setPersNumInfo(reference)) {;
               xFlag = CanApprove.canApprove(Reporter, approvalType, checkLevelsDown + adjustment);
            }
          }
          if (xFlag) {
     %>
            <tr>
			<td width="5%" <%=backcolor%>>&nbsp;</td>
            <td width="10%" <%=backcolor%>><%= created%></td>
            <td width="10%" <%=backcolor%>><%= voucher%></td>
            <td width="10%" <%=backcolor%>><%= pvoucher%></td>
            <td width="5%"  <%=backcolor%>><%= repdate%></td>
            <td width="10%" <%=backcolor%>><%= persname%></td>
            <td width="5%"  <%=backcolor%>><%= repamt%></td>
            <td width="5%" <%=backcolor%>><%= total %></td>
            <td width="5%" <%=backcolor%>><%= repStat %></td>
            <td width="30%" <%=backcolor%>><%= reason%></td>
<%
			String SQLCommand2 = "SELECT PERS_NUM FROM SCAN WHERE SCAN_REF =";
			SQLCommand2 += leaveNum + PersFile.getSQLTerminator();
			if (Reg2.setResultSet(SQLCommand2)) {
				if(PersFile.getTrim(Reg2.myResult.getString(1)).equalsIgnoreCase(reference)){
%>
            <td width="5%" <%=backcolor%>><a href="javascript: void window.open('<%= PersFile.getAppServer()%>/<%= PersFile.getAppFolder()%>/receipts/ReceiptView.jsp?image=<%= leaveNum%>','Receipt_<%= leaveNum%>','dependent=yes, width=700, height=540, screenX=580, screenY=420, resizable, titlebar=yes, menubar=yes, status=no, scrollbars=yes')"><%= leaveNum%></a></td>
			<%}
			else{
%>
            <td width="5%" <%=backcolor%>></td>
			<%}}else{
%>
            <td width="5%" <%=backcolor%>></td>
			<%}%>
            </tr>
     <%     xfound = true;
            newbackcolor = backcolor;
            backcolor = oldbackcolor;
            oldbackcolor = newbackcolor;
          }
        }
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] ajax/HistoryList.jsp java.lang exception possibly voucher: " + voucher);
    Log.println("[500] ajax/HistoryList.jsp exception toString : " + ex.toString());
    ex.printStackTrace();
%>
    <h2>Error in the SQL logic - contact support.<h2>
<%
  } //try
%>
  </table>

<% if (!xfound) { %>
<h2>
<%= Lang.getString("REPORTS_NOT_FOUND") %><br>
</h2>
<% } %>
<% } else { %>
    <div class="ExpenseTag">
    <%=PersFile.name%>, <%= Lang.getString("REPORTS_NOT_FOUND") %>
    <% Log.println("[400] ajax/HistoryList.jsp No expense reports where found."); %>
    </div>
<% } //if (Reg.setResultSet(SQLCommand))
%>

</div>

<div id="expenseReportHidden2" class="reportSection">
	<a class="titleForm" href="javascript: void showDataFields('expenseReport2', showDataFields('expenseReportOptions2'), hideDataFields('expenseReportHidden2'))">Leave History (Click here to open/close details)<span id="reportUsersReference2"></span></a>
    <div><a href="javascript: void showDataFields('expenseReport2', showDataFields('expenseReportOptions2'), hideDataFields('expenseReportHidden2'))">click here <span>to open leave history</span></a></div>
</div>

<div id="expenseReport3" class="reportSection">
	<a class="titleForm" href="javascript: void hideDataFields('expenseReport3', showDataFields('expenseReportHidden3'), hideDataFields('expenseReportOptions3'))">Leave Balance (Click here to open/close details)<span id="reportUsersReference3"></span></a>
<%
   String SQLCommand_Balance = SystemDOM.getDOMTableValueFor("history","reporter_balance");
   SQLCommand_Balance = Reg.SQLReplace(SQLCommand_Balance,"$persnum$",persnumber);

if (Reg.setResultSet(SQLCommand_Balance)) {
		ANNUAL_BAL=PersFile.getTrim(Reg.myResult.getString(1));
		ANNUAL_ENT=PersFile.getTrim(Reg.myResult.getString(2));
		MARRIAGE_BAL=PersFile.getTrim(Reg.myResult.getString(3));
		MARRIAGE_ENT=PersFile.getTrim(Reg.myResult.getString(4));
		CHILDCARE_BAL=PersFile.getTrim(Reg.myResult.getString(5));
		CHILDCARE_ENT=PersFile.getTrim(Reg.myResult.getString(6));
		MEDICAL_BAL=PersFile.getTrim(Reg.myResult.getString(7));
		MEDICAL_ENT=PersFile.getTrim(Reg.myResult.getString(8));
		HOSPITAL_BAL=PersFile.getTrim(Reg.myResult.getString(9));
		HOSPITAL_ENT=PersFile.getTrim(Reg.myResult.getString(10));
		PATERNITY_BAL=PersFile.getTrim(Reg.myResult.getString(11));
		PATERNITY_ENT=PersFile.getTrim(Reg.myResult.getString(12));
		MATERNITY_BAL=PersFile.getTrim(Reg.myResult.getString(13));
		MATERNITY_ENT=PersFile.getTrim(Reg.myResult.getString(14));
		COMP_BAL=PersFile.getTrim(Reg.myResult.getString(15));
		COMP_ENT=PersFile.getTrim(Reg.myResult.getString(16));
		COMP_NEXTOFKIN_BAL=PersFile.getTrim(Reg.myResult.getString(17));
		COMP_NEXTOFKIN_ENT=PersFile.getTrim(Reg.myResult.getString(18));
		OFINLIEU_BAL=PersFile.getTrim(Reg.myResult.getString(19));
		OFINLIEU_ENT=PersFile.getTrim(Reg.myResult.getString(20));
		RESERVIST_BAL=PersFile.getTrim(Reg.myResult.getString(21));
		RESERVIST_ENT=PersFile.getTrim(Reg.myResult.getString(22));
		UNPAID_BAL=PersFile.getTrim(Reg.myResult.getString(23));
		UNPAID_ENT=PersFile.getTrim(Reg.myResult.getString(24));
		BRING_FORWARD=PersFile.getTrim(Reg.myResult.getString(25));
		ADVANCE_LEAVE=PersFile.getTrim(Reg.myResult.getString(26));
		ADDED_LEAVE=PersFile.getTrim(Reg.myResult.getString(27));
    newbackcolor = backcolor;
    backcolor = oldbackcolor;
    oldbackcolor = newbackcolor;
%>
     <table id="previousTable" border="0" cellspacing="0" cellpadding="0">
     <thead>
         <tr>
			 <td class="ExpenseTag" width="5%" <%=backcolor%>>&nbsp;</td>
             <td class="ExpenseTag" width="5%" <%=backcolor%>>Annual</td>
             <td class="ExpenseTag" width="5%" <%=backcolor%>>Marriage</td>
             <td class="ExpenseTag" width="5%" <%=backcolor%>>Childcare</td>
             <td class="ExpenseTag" width="5%" <%=backcolor%>>Medical</td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>>Hospitalisation</td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>>Paternity</td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>>Maternity</td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>>Compassionate</td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>>Compassionate Next-of-kin</td>
             <td class="ExpenseTag" width="15%" <%=backcolor%>>Off In Lieu</td>
             <td class="ExpenseTag" width="5%" <%=backcolor%>>Reservist</td>
             <td class="ExpenseTag" width="5%" <%=backcolor%>>Unpaid</td>
         </tr>
     </thead>
<%
		backcolor = "class=\"offsetColor\"";
		oldbackcolor = "";
		newbackcolor = backcolor;
     %>
            <tr>
			 <td width="5%" <%=backcolor%>>BAL</td>
             <td width="5%" <%=backcolor%>><%=ANNUAL_BAL%></td>
             <td width="5%" <%=backcolor%>><%=MARRIAGE_BAL%></td>
             <td width="5%" <%=backcolor%>><%=CHILDCARE_BAL%></td>
             <td width="5%" <%=backcolor%>><%=MEDICAL_BAL%></td>
             <td width="10%" <%=backcolor%>><%=HOSPITAL_BAL%></td>
             <td width="10%" <%=backcolor%>><%=PATERNITY_BAL%></td>
             <td width="10%" <%=backcolor%>><%=MATERNITY_BAL%></td>
             <td width="10%" <%=backcolor%>><%=COMP_BAL%></td>
             <td width="10%" <%=backcolor%>><%=COMP_NEXTOFKIN_BAL%></td>
             <td width="15%" <%=backcolor%>><%=OFINLIEU_BAL%></td>
             <td width="5%" <%=backcolor%>><%=RESERVIST_BAL%></td>
             <td width="5%" <%=backcolor%>><%=UNPAID_BAL%></td>
            </tr>
     <%
            newbackcolor = backcolor;
            backcolor = oldbackcolor;
            oldbackcolor = newbackcolor;
	%>
            <tr>
			 <td width="5%" <%=backcolor%>>ENT</td>
             <td width="5%" <%=backcolor%>><%=ANNUAL_ENT%></td>
             <td width="5%" <%=backcolor%>><%=MARRIAGE_ENT%></td>
             <td width="5%" <%=backcolor%>><%=CHILDCARE_ENT%></td>
             <td width="5%" <%=backcolor%>><%=MEDICAL_ENT%></td>
             <td width="10%" <%=backcolor%>><%=HOSPITAL_ENT%></td>
             <td width="10%" <%=backcolor%>><%=PATERNITY_ENT%></td>
             <td width="10%" <%=backcolor%>><%=MATERNITY_ENT%></td>
             <td width="10%" <%=backcolor%>><%=COMP_ENT%></td>
             <td width="10%" <%=backcolor%>><%=COMP_NEXTOFKIN_ENT%></td>
             <td width="15%" <%=backcolor%>><%=OFINLIEU_ENT%></td>
             <td width="5%" <%=backcolor%>><%=RESERVIST_ENT%></td>
             <td width="5%" <%=backcolor%>><%=UNPAID_ENT%></td>
            </tr>
  </table>
<% }
   SQLCommand_Leave = SystemDOM.getDOMTableValueFor("history","reporter_leave_pending");
   SQLCommand_Leave = Reg.SQLReplace(SQLCommand_Leave,"$persnum$",persnumber);
   int nPendingLeave = 0;
	if (Reg.setResultSet(SQLCommand_Leave)) {
		try {
			 do {
				nPendingLeave = nPendingLeave + 1;
			} while (Reg.myResult.next());
		} catch (java.lang.Exception ex) {
			ex.printStackTrace();
%>
    <h2>Error in HistoryList.jsp line 565 - contact support.<h2>
<%
		} //try
	}
	PENDING_LEAVE = java.lang.Integer.toString(nPendingLeave);
%>

<div class="ExpenseTag">Bring Forward: <%= BRING_FORWARD %>
	<%
	if(Float.parseFloat(BRING_FORWARD) > 0){%>
	<span style="color:red">   !!!Applicable only during 1st Jan --- 30th June!!!<span>
	<%}
	%>
</div>
<!--<div class="ExpenseTag">Add on: <%= ADDED_LEAVE %></div>-->
<div class="ExpenseTag">Pending: <%= PENDING_LEAVE %></div>
</div>


<div id="expenseReportHidden3" class="reportSection" style="display: none">
	<a class="titleForm" href="javascript: void showDataFields('expenseReport3', showDataFields('expenseReportOptions3'), hideDataFields('expenseReportHidden3'))">Leave Balance (Click here to open/close details)<span id="reportUsersReference3"></span></a>
    <div><a href="javascript: void showDataFields('expenseReport3', showDataFields('expenseReportOptions3'), hideDataFields('expenseReportHidden3'))">click here <span>to open leave balance</span></a></div>
</div>

<%if(PersFile.getManager().equals("99990") || PersFile.getManager().equals("999") || persnumber.equals("10004")){
%>
<div id="expenseReport4" class="reportSection">
	<a class="titleForm" href="javascript: void hideDataFields('expenseReport4', showDataFields('expenseReportHidden4'), hideDataFields('expenseReportOptions4'))">Your Department Leave Details (Click here to open/close details)<span id="reportUsersReference4"></span></a>
<%
   SQLCommand_Balance = SystemDOM.getDOMTableValueFor("history","department_balance_all");
   SQLCommand_Balance = Reg.SQLReplace(SQLCommand_Balance,"$persnum$",persnumber);


	if (Reg.setResultSet(SQLCommand_Balance)) {

    try {
     do {
		ANNUAL_BAL=PersFile.getTrim(Reg.myResult.getString(1));
		ANNUAL_ENT=PersFile.getTrim(Reg.myResult.getString(2));
		MARRIAGE_BAL=PersFile.getTrim(Reg.myResult.getString(3));
		MARRIAGE_ENT=PersFile.getTrim(Reg.myResult.getString(4));
		CHILDCARE_BAL=PersFile.getTrim(Reg.myResult.getString(5));
		CHILDCARE_ENT=PersFile.getTrim(Reg.myResult.getString(6));
		MEDICAL_BAL=PersFile.getTrim(Reg.myResult.getString(7));
		MEDICAL_ENT=PersFile.getTrim(Reg.myResult.getString(8));
		HOSPITAL_BAL=PersFile.getTrim(Reg.myResult.getString(9));
		HOSPITAL_ENT=PersFile.getTrim(Reg.myResult.getString(10));
		PATERNITY_BAL=PersFile.getTrim(Reg.myResult.getString(11));
		PATERNITY_ENT=PersFile.getTrim(Reg.myResult.getString(12));
		MATERNITY_BAL=PersFile.getTrim(Reg.myResult.getString(13));
		MATERNITY_ENT=PersFile.getTrim(Reg.myResult.getString(14));
		COMP_BAL=PersFile.getTrim(Reg.myResult.getString(15));
		COMP_ENT=PersFile.getTrim(Reg.myResult.getString(16));
		COMP_NEXTOFKIN_BAL=PersFile.getTrim(Reg.myResult.getString(17));
		COMP_NEXTOFKIN_ENT=PersFile.getTrim(Reg.myResult.getString(18));
		OFINLIEU_BAL=PersFile.getTrim(Reg.myResult.getString(19));
		OFINLIEU_ENT=PersFile.getTrim(Reg.myResult.getString(20));
		RESERVIST_BAL=PersFile.getTrim(Reg.myResult.getString(21));
		RESERVIST_ENT=PersFile.getTrim(Reg.myResult.getString(22));
		UNPAID_BAL=PersFile.getTrim(Reg.myResult.getString(23));
		UNPAID_ENT=PersFile.getTrim(Reg.myResult.getString(24));
		BRING_FORWARD=PersFile.getTrim(Reg.myResult.getString(25));
		ADVANCE_LEAVE=PersFile.getTrim(Reg.myResult.getString(26));
		ADDED_LEAVE=PersFile.getTrim(Reg.myResult.getString(27));
		String PERS_NAME=PersFile.getTrim(Reg.myResult.getString(28));
			PERS_NAME += " " + PersFile.getTrim(Reg.myResult.getString(29));
		String reporter = PersFile.getTrim(Reg.myResult.getString(30));
		String divIDreporter = "Report" + reporter;
		String divHiddenreporter = "Hidden" + reporter;
		String divOptionreporter = "Option" + reporter;
		String divRefreporter = "Ref" + reporter;

		String divID = "Report" + PERS_NAME;
		String divHidden = "Hidden" + PERS_NAME;
		String divOption = "Option" + PERS_NAME;
		String divRef = "Ref" + PERS_NAME;
		backcolor = "class=\"offsetColor\"";
		oldbackcolor = "";
		newbackcolor = backcolor;
%>
<div id="<%=divID%>" class="reportSection" style="display: none">
	<a class="titleForm" href="javascript: void hideDataFields('<%=divID%>', showDataFields('<%=divHidden%>'), hideDataFields('<%=divOption%>'))"><%= PERS_NAME%><span id="<%=divRef%>"></span></a>
    <table id="previousTable" border="0" cellspacing="0" cellpadding="0">
     <thead>
         <tr>
			 <td class="ExpenseTag" width="5%" <%=backcolor%>>&nbsp;</td>
             <td class="ExpenseTag" width="5%" <%=backcolor%>>Annual</td>
             <td class="ExpenseTag" width="5%" <%=backcolor%>>Marriage</td>
             <td class="ExpenseTag" width="5%" <%=backcolor%>>Childcare</td>
             <td class="ExpenseTag" width="5%" <%=backcolor%>>Medical</td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>>Hospitalisation</td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>>Paternity</td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>>Maternity</td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>>Compassionate Next-of-kin</td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>>Compassionate</td>
             <td class="ExpenseTag" width="15%" <%=backcolor%>>Off In Lieu</td>
             <td class="ExpenseTag" width="5%" <%=backcolor%>>Reservist</td>
             <td class="ExpenseTag" width="5%" <%=backcolor%>>Unpaid</td>
         </tr>
     </thead>
            <tr>
			 <td width="5%" <%=backcolor%>>BAL</td>
             <td width="5%" <%=backcolor%>><%=ANNUAL_BAL%></td>
             <td width="5%" <%=backcolor%>><%=MARRIAGE_BAL%></td>
             <td width="5%" <%=backcolor%>><%=CHILDCARE_BAL%></td>
             <td width="5%" <%=backcolor%>><%=MEDICAL_BAL%></td>
             <td width="10%" <%=backcolor%>><%=HOSPITAL_BAL%></td>
             <td width="10%" <%=backcolor%>><%=PATERNITY_BAL%></td>
             <td width="10%" <%=backcolor%>><%=MATERNITY_BAL%></td>
             <td width="10%" <%=backcolor%>><%=COMP_BAL%></td>
             <td width="10%" <%=backcolor%>><%=COMP_NEXTOFKIN_BAL%></td>
             <td width="15%" <%=backcolor%>><%=OFINLIEU_BAL%></td>
             <td width="5%" <%=backcolor%>><%=RESERVIST_BAL%></td>
             <td width="5%" <%=backcolor%>><%=UNPAID_BAL%></td>
            </tr>
     <%
            newbackcolor = backcolor;
            backcolor = oldbackcolor;
            oldbackcolor = newbackcolor;
	%>
            <tr>
			 <td width="5%" <%=backcolor%>>ENT</td>
             <td width="5%" <%=backcolor%>><%=ANNUAL_ENT%></td>
             <td width="5%" <%=backcolor%>><%=MARRIAGE_ENT%></td>
             <td width="5%" <%=backcolor%>><%=CHILDCARE_ENT%></td>
             <td width="5%" <%=backcolor%>><%=MEDICAL_ENT%></td>
             <td width="10%" <%=backcolor%>><%=HOSPITAL_ENT%></td>
             <td width="10%" <%=backcolor%>><%=PATERNITY_ENT%></td>
             <td width="10%" <%=backcolor%>><%=MATERNITY_ENT%></td>
             <td width="10%" <%=backcolor%>><%=COMP_ENT%></td>
             <td width="10%" <%=backcolor%>><%=COMP_NEXTOFKIN_ENT%></td>
             <td width="15%" <%=backcolor%>><%=OFINLIEU_ENT%></td>
             <td width="5%" <%=backcolor%>><%=RESERVIST_ENT%></td>
             <td width="5%" <%=backcolor%>><%=UNPAID_ENT%></td>
            </tr>
  </table>
<div class="ExpenseTag">Bring Forward: <%= BRING_FORWARD %>
	<%
	if(Float.parseFloat(BRING_FORWARD) > 0){%>
	<span style="color:red">   !!!Applicable only during 1st Jan --- 30th June!!!<span>
	<%}
	%>
</div>
<!--<div class="ExpenseTag">Add on: <%= ADDED_LEAVE %></div>-->
<div class="ExpenseTag">Pending: <%= PENDING_LEAVE %></div>

<%
   String SQLCommand_Leave1 = SystemDOM.getDOMTableValueFor("history","reporter_leave");
   SQLCommand_Leave1 = Reg3.SQLReplace(SQLCommand_Leave1,"$persnum$",reporter);
%>
<div id="<%=divIDreporter%>" class="reportSection">
	<a class="titleForm" href="javascript: void hideDataFields('<%=divIDreporter%>', showDataFields('<%=divHiddenreporter%>'), hideDataFields('<%=divOptionreporter%>'))"><%= PERS_NAME%>'s Leave History<span id="<%=divRefreporter%>"></span></a>

<%if (Reg3.setResultSet(SQLCommand_Leave1)) {

     String persname;
     byte[] bArray;    //used for encrypted values
     String E;         //     ditto
     boolean xFlag;
     boolean xfound = false;
     String voucher = "";
     String pvoucher = "";
     String reference;
     String repdate;
     String repamt;
     String repStat;
     String repDBStat;
	 String reason;
	 String created;
	 String total;
     int adjustment = 0; //see status.xml
%>

     <table id="previousTable" border="0" cellspacing="0" cellpadding="0">
     <thead>
         <tr>
             <th width="5%" <%=backcolor%>>&nbsp;</th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_CREATED") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TYPE") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_FROM") %></th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_FROM_AMPM") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TO") %></th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TO_AMPM") %></th>
             <th width="5%" <%=backcolor%>>Total</th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_STATUS") %></th>
             <th width="30%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_REASON") %></th>
             <th width="5%" <%=backcolor%>>Receipts</th>
         </tr>
     </thead>
<%
		backcolor = "class=\"offsetColor\"";
		oldbackcolor = "";
		newbackcolor = backcolor;

    try {
     do {
        total = PersFile.getTrim(Reg3.myResult.getString(5));
         persname = PersFile.getTrim(Reg3.myResult.getString(10));
        repStat = PersFile.getTrim(Reg3.myResult.getString(12));
        reference = PersFile.getTrim(Reg3.myResult.getString(1)); //used for subordinate lookup
        voucher = PersFile.getTrim(Reg3.myResult.getString(7));
        pvoucher = PersFile.getTrim(Reg3.myResult.getString(8));
        repdate = PersFile.getTrim(Reg3.myResult.getString(9));
        repamt = PersFile.getTrim(Reg3.myResult.getString(11));
		reason = PersFile.getTrim(Reg3.myResult.getString(13));
		created = PersFile.getTrim(Reg3.myResult.getString(6));
		leaveNum = PersFile.getTrim(Reg3.myResult.getString(4));
		created = Dt.getUserDateStr(Dt.getSimpleDate(Dt.getDateFromXBase(created)),PersFile.getDateFormat());
		pvoucher = Dt.getUserDateStr(Dt.getSimpleDate(Dt.getDateFromXBase(pvoucher)),PersFile.getDateFormat());
		persname = Dt.getUserDateStr(Dt.getSimpleDate(Dt.getDateFromXBase(persname)),PersFile.getDateFormat());
        repDBStat = StatXlation(repStat, CompanyName, StatusDOM);
     %>
            <tr>
			<td width="5%" <%=backcolor%>>&nbsp;</td>
            <td width="10%" <%=backcolor%>><%= created%></td>
            <td width="10%" <%=backcolor%>><%= voucher%></td>
            <td width="10%" <%=backcolor%>><%= pvoucher%></td>
            <td width="5%"  <%=backcolor%>><%= repdate%></td>
            <td width="10%" <%=backcolor%>><%= persname%></td>
            <td width="5%"  <%=backcolor%>><%= repamt%></td>
            <td width="5%" <%=backcolor%>><%= total %></td>
            <td width="5%" <%=backcolor%>><%= repStat %></td>
            <td width="30%" <%=backcolor%>><%= reason%></td>
<%
			String SQLCommand12 = "SELECT PERS_NUM FROM SCAN WHERE SCAN_REF =";
			SQLCommand12 += leaveNum + PersFile.getSQLTerminator();
			if (Reg2.setResultSet(SQLCommand12)) {
				if(PersFile.getTrim(Reg2.myResult.getString(1)).equalsIgnoreCase(reference)){
%>
            <td width="5%" <%=backcolor%>><a href="javascript: void window.open('<%= PersFile.getAppServer()%>/<%= PersFile.getAppFolder()%>/receipts/ReceiptView.jsp?image=<%= leaveNum%>','Receipt_<%= leaveNum%>','dependent=yes, width=700, height=540, screenX=580, screenY=420, resizable, titlebar=yes, menubar=yes, status=no, scrollbars=yes')"><%= leaveNum%></a></td>
			<%}
			else{
%>
            <td width="5%" <%=backcolor%>></td>
			<%}}else{
%>
            <td width="5%" <%=backcolor%>></td>
			<%}%>
            </tr>
     <%     xfound = true;
            newbackcolor = backcolor;
            backcolor = oldbackcolor;
            oldbackcolor = newbackcolor;
     } while (Reg3.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] ajax/HistoryList.jsp exception toString : " + ex.toString());
    ex.printStackTrace();
%>
    <h2>Error in the SQL logic - contact support.<h2>
<%
  } //try
%>
  </table>

<% if (!xfound) { %>
<h2>
<%= Lang.getString("REPORTS_NOT_FOUND") %><br>
</h2>
<% } %>
<% } else { %>
    <div class="ExpenseTag">
    <%=PersFile.name%>, <%= Lang.getString("REPORTS_NOT_FOUND") %>
    <% Log.println("[400] ajax/HistoryList.jsp No expense reports where found."); %>
    </div>
<% } //if (Reg.setResultSet(SQLCommand))
%>

</div>
<div id="<%=divHiddenreporter%>" class="reportSection" style="display: none">
	<a class="titleForm" href="javascript: void showDataFields('<%=divIDreporter%>', showDataFields('<%=divOptionreporter%>'), hideDataFields('<%=divHiddenreporter%>'))"><%= PERS_NAME%>'s Leave History<span id="<%=divRefreporter%>"></span></a>
    <div><a href="javascript: void showDataFields('<%=divIDreporter%>', showDataFields('<%=divOptionreporter%>'), hideDataFields('<%=divHiddenreporter%>'))">click here <span>to open leave history</span></a></div>
</div>

</div>


<div id="<%=divHidden%>" class="reportSection">
	<a class="titleForm" href="javascript: void showDataFields('<%=divID%>', showDataFields('<%=divOption%>'), hideDataFields('<%=divHidden%>'))"><%= PERS_NAME%><span id="<%=divRef%>"></span></a>
    <div><a href="javascript: void showDataFields('<%=divID%>', showDataFields('<%=divOption%>'), hideDataFields('<%=divHidden%>'))">click here <span>to open leave balance</span></a></div>
</div>
<%
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    ex.printStackTrace();
%>
    <h2>Error in the SQL logic - contact support.<h2>
<%
  } //try
%>
  </table>
<% } else { %>
    <div class="ExpenseTag">
    <%=PersFile.name%>, <%= Lang.getString("REPORTS_NOT_FOUND") %>
    <% Log.println("[400] ajax/HistoryList.jsp No expense reports where found."); %>
    </div>
<% } //if (Reg.setResultSet(SQLCommand))
%>
</div>

<div id="expenseReportHidden4" class="reportSection" style="display: none">
	<a class="titleForm" href="javascript: void showDataFields('expenseReport4', showDataFields('expenseReportOptions4'), hideDataFields('expenseReportHidden4'))">Your Department Leave Balance (Click here to open/close details)<span id="reportUsersReference4"></span></a>
    <div><a href="javascript: void showDataFields('expenseReport4', showDataFields('expenseReportOptions4'), hideDataFields('expenseReportHidden4'))">click here <span>to open leave balance table for your department</span></a></div>
</div>
<%}//if VO
%>
<span language="Javascript" id="script" file="shared/history.js" ></span>

<%}//if TEST and PA department
} else { %>
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode))
%>
<%
Reg.close();      //cleaning up open connections
Reporter.close();
%>
<%@ include file="../UnScramble.jsp" %>
<%@ include file="../StatXlation.jsp" %>
