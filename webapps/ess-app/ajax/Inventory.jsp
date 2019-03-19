<%--
ApprovalList.jsp - list out items this approver can approver/initiates batch approval
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
<jsp:useBean id = "SavePers"
     class="ess.SavePersData"
     scope="page" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Currency"
     class="ess.Currency"
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
boolean pFlag = PersFile.setPersInfo(ownersName); 

if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
}
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
//if (pFlag) {	
%>
<%@ include file="../StatusInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>
<%@ include file="../DepartInfo.jsp" %>
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

   if (!Currency.isAlreadyLoaded()) {
     Currency.setConnection(PersFile.getConnection());
     Currency.setSQLTerminator(PersFile.getSQLTerminator()); 
     Currency.setSQLStrings();
   }

   CanApprove.setConnection(PersFile.getConnection());
   CanApprove.setSQLTerminator(PersFile.getSQLTerminator()); 
   CanApprove.setUpFiles();
   CanApprove.setApprover(PersFile);
/*
   String PData =  request.getParameter("persdbase");
   if (PData != null) {
      Log.println("[000] ajax/ApproveList.jsp - Approval access and personal database save for " + ownersName);
      SavePers.setConnection(PersFile.getConnection());
      SavePers.setSQLTerminator(PersFile.getSQLTerminator());
      SavePers.setFile(PData,ownersName); 
   } else {
      Log.println("[000] ajax/ApproveList.jsp - Approval access by " + ownersName);
   }
*/
   String NeedPassword = SystemDOM.getDOMTableValueFor("configuration", "pwd_approval","yes");
   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);
   String downlevel = request.getParameter("downlevel");
   int checkLevelsDown = java.lang.Integer.parseInt(downlevel);
	String persname;
     byte[] bArray;    //used for encrypted values
     String E;         //     ditto
     boolean xFlag;
	 boolean xReAssign;
     boolean xfound = false;
	 boolean xfound_leave = false;
     String voucher;
     String reference;
     String curdate;
     String repamt;
     String repStat;
     String repDBStat;
     String backcolor = "class=\"TableData offsetColor\"";
     String oldbackcolor = "class=\"TableData\"";
     String newbackcolor;
     String approvalType; 
     String limitRequired; 
     String CEOLimit;
     String signAnyway;
     boolean atLeastOnce;     
     String firstSigner;
     String secondSigner;     
     String signerColumn;
     String dupAllowed; 
     String adjustment; 
     String subTable;
     String depart;
     String prefer;
//     String dueamt; - this was replaced with adminSigner below
     String adminSigner;
     String currency;
     String company;
	 String xcheck;
     boolean xDup;
     boolean xLimit;
   String reportScript = SystemDOM.getDOMTableValueFor("reporttable","ajaxapprovescript","ajax/ApproveReportV2.jsp");
   

   /*if (SQLCommand.equals("")) {
     SQLCommand = "SELECT ";
     SQLCommand += "NAME, PERS_NUM, RC_AMT, RP_STAT, ";
     SQLCommand += "CUR_DATE, SIGN1, VOUCHER, PVOUCHER, SIGN2, DEPART, ADMIN1, CURRENCY, COMPANY, XCHECK ";
     SQLCommand += "FROM REPORT ";
     SQLCommand += "WHERE RP_STAT = 'B1' OR RP_STAT = 'C1' OR RP_STAT = 'D1' OR RP_STAT = 'D2' ";
     SQLCommand += "ORDER BY RP_STAT" + PersFile.getSQLTerminator();
   }*/

   //SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",PersFile.getPersNum());
   
   //stock checking by me available start
     String SQLCommand = "SELECT STOCKCHECK_ID FROM DB_STOCKCHECK WHERE STOCKCHECK_STATUS = '0' AND STOCKCHECK_BY = '" + PersFile.getPersNum() + "'";
     SQLCommand += PersFile.getSQLTerminator();
   if(Reg3.setResultSet(SQLCommand)){
			SQLCommand = SystemDOM.getDOMTableValueFor("reporttable","selectitems",""); 
			if (Reg.setResultSet(SQLCommand)) {
		%>
			  <form action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/edit/InventoryConfirm.jsp">
				<input type="hidden" name="email" value="<%= ownersName %>">
				<input type="hidden" name="database" value="<%= database %>">
				<input type="hidden" name="company" value="ess">
				<input type="hidden" name="ccode" value="<%= CCode %>">
				<input type="hidden" name="reference" value>
				<input type="hidden" name="xaction" value="Update">
				<h1>Stock checking update:</h1>
				<h2>Stock checking comments:  <input type="text" name="reason" maxlength="100" value="Balance tally" onfocus="this.select();"></h2>
					
				<table border="0" cellspacing="0" cellpadding="0" id="approveTable">
				<thead>
					<tr>
						<th width="20%" <%=backcolor%>>Name</th>
						<th width="10%" <%=backcolor%>>Category</th>
						<th width="40%" <%=backcolor%>>Description</th>
						<th width="10%" <%=backcolor%>>Holding Stock</th>
						<th width="10%" <%=backcolor%>>Physical Stock</th>
						<th width="10%" <%=backcolor%>></th>
					</tr>
				</thead>
		  <!--   <form>  -->
		<% 
			backcolor = "class=\"TableData offsetColor\"";
			oldbackcolor = "class=\"TableData\"";
			newbackcolor = backcolor;
		   try {
			 do { 
				/*if (encrypt.equalsIgnoreCase("YES")) {
				  bArray = Reg.myResult.getBytes(1);
				  E = new String(bArray);
				  persname = unScramble(E,encrypt,encryptKey);   
				} else {
				  persname = PersFile.getTrim(Reg.myResult.getString(1));
				}*/
				persname = PersFile.getTrim(Reg.myResult.getString(1));
				reference = PersFile.getTrim(Reg.myResult.getString(2));
				repamt = PersFile.getTrim(Reg.myResult.getString(3)); 
				repStat = PersFile.getTrim(Reg.myResult.getString(4));  
				curdate = "";//PersFile.getTrim(Reg.myResult.getString(5)); 
				firstSigner = "";//PersFile.getTrim(Reg.myResult.getString(6));  //need variable name for column later to check for dup sign
				voucher = PersFile.getTrim(Reg.myResult.getString(5));
				prefer = "";//PersFile.getTrim(Reg.myResult.getString(8));
				secondSigner = "";//PersFile.getTrim(Reg.myResult.getString(9));  //need variable name for column later to check for dup sign
				depart = "";//PersFile.getTrim(Reg.myResult.getString(10));
				adminSigner = "";//PersFile.getTrim(Reg.myResult.getString(11));
				currency = "";//PersFile.getTrim(Reg.myResult.getString(12));
				company = "";//PersFile.getTrim(Reg.myResult.getString(13));
				xcheck = "";//PersFile.getTrim(Reg.myResult.getString(14));

				subTable = getRoutingRuleName(DepartDOM, depart, PersFile.depart, Log);
				repDBStat = StatXlation(repStat, CompanyName, StatusDOM);

				approvalType = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"approval");
				if (approvalType.equals("")) 
				{
				  subTable = "default";
				  approvalType = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"approval");
				}

				limitRequired = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"limitrequired");
				CEOLimit = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"ceolimit");
				signAnyway = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"signwithoutlimit");
				atLeastOnce = signAnyway.equalsIgnoreCase("yes");
				dupAllowed = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"duplicatesignerallowed");
				signerColumn = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"updatesqlsigner");
				adjustment = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"leveladjustment");
		 
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

				//xFlag = Reporter.setPersNumInfo(reference); 
				//if (!xFlag) Log.println("[500] ajax/ApproveList.jsp reporter not found: " + reference);

				xDup = dupAllowed.toUpperCase().equals("YES");
				//xLimit = CheckLimit(PersFile,repamt, currency,limitRequired,CEOLimit, Currency, Log); 

				xReAssign = false;

				Log.println("[000] ajax/ApproveList.jsp checking approval type: " + approvalType + " for " + Reporter.email + ",voucher " + voucher + " [" + ownersName + "]"); //jh remove
				if (true)//xFlag && (xReAssign || CanApprove.canApprove(Reporter, depart, company, approvalType, checkLevelsDown + java.lang.Integer.parseInt(adjustment)))) 
				{ 
				  Log.println("[000] ajax/ApproveList.jsp can Approve this report: "  + voucher + " [" + ownersName + "]"); //jh remove
				  if (true)// ifSeemsOK(PersFile, xDup, atLeastOnce, adminSigner, firstSigner, secondSigner, xLimit) )
				  {
					  //Dt.getSimpleDate(Dt.getDateFromXBase(curdate))
					  
		%>       
					<tr>
					<td width="20%" <%=backcolor%>><%= persname%></td>
					<td width="10%" <%=backcolor%>><%= reference%></td>
					<td width="40%" <%=backcolor%>><%= repamt%></td>
					<td width="10%" <%=backcolor%>><%= repStat%></td>
					<td width="10%" <%=backcolor%>><input id="<%=voucher%>" type="text" name="name" value="<%= repStat%>" onChange="ChangeStock('<%=voucher%>',<%= repStat%>,this.value);" onfocus="this.select();"></td>
					<td width="10%" <%=backcolor%>></td>
					<td width="5%"  <%=backcolor%>>
						<input type="checkbox" id="<%=voucher%>select_this_item" style="display: none" value="">
					</td>            
					</tr>
		<%          xfound = true;
					newbackcolor = backcolor;
					backcolor = oldbackcolor; 
					oldbackcolor = newbackcolor;
				  }  
				}
			 } while (Reg.myResult.next());
		  } catch (java.lang.Exception ex) {
			Log.println("[500] ajax/ApproveList.jsp Language Error");
			Log.println("[500] ajax/ApproveList.jsp - " + ex.toString());
			ex.printStackTrace();
		%>
			<h1><%= Lang.getString("APP_SQL_ERROR")%><br></h1>
		<%  
		  } //try
		%>
		 <!-- </form>  -->

			</table>
			  <input id="btSave" type="button" name="Stock" value="Confirm (to send stock update)"  onClick="Javascript: void SetNewValues('<%=PersFile.getTrim(Reg3.myResult.getString(1))%>')">
			</form>



		<% if (!xfound) { %>
		<strong><em>
		<%= Lang.getString("APP_NO_REPORT") %><br>
		</em></strong>
		<% } %>
		<% } 
		%>
		  <script language=JavaScript id="script" folder="<%= PersFile.getWebServer() + "/" + PersFile.getWebFolder() %>" file="<%=PersFile.getLanguage() %>/InventoryRequestList.js" />
<%   
   }//stock checking by me available end
   else{
		SQLCommand = "SELECT * FROM DB_STOCKCHECK WHERE STOCKCHECK_STATUS = '0' AND STOCKCHECK_BY <> '" + PersFile.getPersNum() + "'";
		SQLCommand += PersFile.getSQLTerminator();
		if(Reg2.setResultSet(SQLCommand)){
%>
			<h1>Pending stock checking.</h1>
			<h1>Inventory operation not availible now.</h1>
			<h1>Please contact HR for urgent request.</h1>
<%      
		}//stock checking by others available end
		else{
%>   
     <h1>Pending Requests:</h1>
<div id="expenseReport5" class="reportSection" style="display: none">
	<a class="titleForm" href="javascript: void hideDataFields('expenseReport5', showDataFields('expenseReportHidden5'), hideDataFields('expenseReportOptions5'))">Requests for Sign/Cancel (Click here to open/close details)<span id="reportUsersReference5"></span></a>
<%
	String persnumber = PersFile.persnum;
   String SQLInv = SystemDOM.getDOMTableValueFor("history","inventory_request_prepared");
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
		String buttonName = "Sign Out";
		if(OPERATION_STATUS.equalsIgnoreCase("Submitted")){
			buttonName = "Cancel";
		}
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
	<a class="titleForm" href="javascript: void hideDataFields('<%=divIDreporter%>', showDataFields('<%=divHiddenreporter%>'), hideDataFields('<%=divOptionreporter%>'))"><%=OPERATION_STATUS%> on <%= PERS_NAME%><span id="<%=divRefreporter%>"></span></a>

<%if (Reg3.setResultSet(SQLCommand_Leave1)) {

%>

     <table id="previousTable" border="0" cellspacing="0" cellpadding="0">
     <thead>
         <tr>
			 <td class="ExpenseTag" width="5%" <%=backcolor%>>&nbsp;</td>
             <td class="ExpenseTag" width="20%" <%=backcolor%>>Name</td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>>Category</td>
             <td class="ExpenseTag" width="40%" <%=backcolor%>>Description</td>
             <td class="ExpenseTag" width="5%" <%=backcolor%>>Amount</td>
			 <td class="ExpenseTag" width="20%" <%=backcolor%>>&nbsp;</td>
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
            <td width="20%" <%=backcolor%>><%= sName%></td>
            <td width="10%" <%=backcolor%>><%= sCat%></td>
            <td width="40%" <%=backcolor%>><%= sDesc%></td>
            <td width="5%"  <%=backcolor%>><%= sAmount%></td>
	<%	if(buttonName.equalsIgnoreCase("Cancel")){
	%>
            <td width="20%"  <%=backcolor%>><input id="btEnter2" type="button" name="B1" value="Remove"  onClick="Javascript: void RemoveItems('<%=OPERATION_ID%>','Remove','<%= sName%>','<%= sCat%>','<%= sAmount%>')"></td>
	<%	}
		else{
	%>
            <td width="20%"  <%=backcolor%>>&nbsp;</td>
	<%	}
	%>
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
	  <input id="btSave" type="button" name="B1" value="<%=buttonName%>"  onClick="Javascript: void SignRequest('<%=OPERATION_ID%>','<%=buttonName%>')">
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
	<a class="titleForm" href="javascript: void showDataFields('<%=divIDreporter%>', showDataFields('<%=divOptionreporter%>'), hideDataFields('<%=divHiddenreporter%>'))"><%=OPERATION_STATUS%> on <%= PERS_NAME%><span id="<%=divRefreporter%>"></span></a>
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
	<a class="titleForm" href="javascript: void showDataFields('expenseReport5', showDataFields('expenseReportOptions5'), hideDataFields('expenseReportHidden5'))">Requests for Sign/Cancel (Click here to open/close details)<span id="reportUsersReference5"></span></a>
    <div><a href="javascript: void showDataFields('expenseReport5', showDataFields('expenseReportOptions5'), hideDataFields('expenseReportHidden5'))">click here <span>to open inventory details</span></a></div>
</div>	 
<%   
	SQLCommand = SystemDOM.getDOMTableValueFor("reporttable","selectitems",""); 
	if (Reg.setResultSet(SQLCommand)) {
%>
      <form action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/edit/InventoryConfirm.jsp">
        <input type="hidden" name="email" value="<%= ownersName %>">
        <input type="hidden" name="database" value="<%= database %>">
        <input type="hidden" name="company" value="ess">
        <input type="hidden" name="ccode" value="<%= CCode %>">
        <input type="hidden" name="reference" value>
        <input type="hidden" name="xaction" value="apply">
		<h1>New Request:</h1>
		<h2>Reason:  <input type="text" name="reason" maxlength="100" value="New request" onfocus="this.select();"></h2>
			
		<table border="0" cellspacing="0" cellpadding="0" id="approveTable">
     	<thead>
     		<tr>
				<th width="20%" <%=backcolor%>>Name</th>
				<th width="10%" <%=backcolor%>>Category</th>
				<th width="45%" <%=backcolor%>>Description</th>
				<th width="10%" <%=backcolor%>>Available</th>
				<th width="10%" <%=backcolor%>>Requested</th>
				<th width="5%" <%=backcolor%>></th>
			</tr>
		</thead>
  <!--   <form>  -->
<% 
    backcolor = "class=\"TableData offsetColor\"";
    oldbackcolor = "class=\"TableData\"";
    newbackcolor = backcolor;
   try {
     do { 
        /*if (encrypt.equalsIgnoreCase("YES")) {
          bArray = Reg.myResult.getBytes(1);
          E = new String(bArray);
          persname = unScramble(E,encrypt,encryptKey);   
        } else {
          persname = PersFile.getTrim(Reg.myResult.getString(1));
        }*/
		persname = PersFile.getTrim(Reg.myResult.getString(1));
        reference = PersFile.getTrim(Reg.myResult.getString(2));
        repamt = PersFile.getTrim(Reg.myResult.getString(3)); 
        repStat = PersFile.getTrim(Reg.myResult.getString(4));  
        curdate = "";//PersFile.getTrim(Reg.myResult.getString(5)); 
        firstSigner = "";//PersFile.getTrim(Reg.myResult.getString(6));  //need variable name for column later to check for dup sign
        voucher = PersFile.getTrim(Reg.myResult.getString(5));
        prefer = "";//PersFile.getTrim(Reg.myResult.getString(8));
        secondSigner = "";//PersFile.getTrim(Reg.myResult.getString(9));  //need variable name for column later to check for dup sign
        depart = "";//PersFile.getTrim(Reg.myResult.getString(10));
        adminSigner = "";//PersFile.getTrim(Reg.myResult.getString(11));
        currency = "";//PersFile.getTrim(Reg.myResult.getString(12));
        company = "";//PersFile.getTrim(Reg.myResult.getString(13));
		xcheck = PersFile.getTrim(Reg.myResult.getString(6));

        subTable = getRoutingRuleName(DepartDOM, depart, PersFile.depart, Log);
        repDBStat = StatXlation(repStat, CompanyName, StatusDOM);

        approvalType = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"approval");
        if (approvalType.equals("")) 
        {
          subTable = "default";
          approvalType = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"approval");
        }

        limitRequired = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"limitrequired");
        CEOLimit = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"ceolimit");
        signAnyway = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"signwithoutlimit");
        atLeastOnce = signAnyway.equalsIgnoreCase("yes");
        dupAllowed = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"duplicatesignerallowed");
        signerColumn = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"updatesqlsigner");
        adjustment = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"leveladjustment");
 
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

        //xFlag = Reporter.setPersNumInfo(reference); 
        //if (!xFlag) Log.println("[500] ajax/ApproveList.jsp reporter not found: " + reference);

        xDup = dupAllowed.toUpperCase().equals("YES");
        //xLimit = CheckLimit(PersFile,repamt, currency,limitRequired,CEOLimit, Currency, Log); 

		xReAssign = false;
		/*String SQLCommand9 = "SELECT MANAGER FROM DEPART WHERE DEPART ='";
		String ManagerAssigned = "";
		if(xcheck.equalsIgnoreCase("1")){
			SQLCommand9 += depart + "'" + PersFile.getSQLTerminator();
			if (Reg2.setResultSet(SQLCommand9)) {
				ManagerAssigned = PersFile.getTrim(Reg2.myResult.getString(1)); 
			}
			if(ManagerAssigned.equalsIgnoreCase(PersFile.getPersNum())){
				xReAssign = true;
			}
			else{
				xFlag = false;
			}
		}*/
        Log.println("[000] ajax/ApproveList.jsp checking approval type: " + approvalType + " for " + Reporter.email + ",voucher " + voucher + " [" + ownersName + "]"); //jh remove
        if (true)//xFlag && (xReAssign || CanApprove.canApprove(Reporter, depart, company, approvalType, checkLevelsDown + java.lang.Integer.parseInt(adjustment)))) 
		{ 
          Log.println("[000] ajax/ApproveList.jsp can Approve this report: "  + voucher + " [" + ownersName + "]"); //jh remove
          if (true)// ifSeemsOK(PersFile, xDup, atLeastOnce, adminSigner, firstSigner, secondSigner, xLimit) )
		  {
        	  //Dt.getSimpleDate(Dt.getDateFromXBase(curdate))
        	  String image = PersFile.getAppServer() + "/" + PersFile.getAppFolder() + "/inventory/images/" + xcheck + ".jpeg";
%>       
            <tr>
            <td width="20%" <%=backcolor%>><a href="javascript: void window.open('<%= image%>','dependent=yes, width=700, height=540, screenX=580, screenY=420, resizable, titlebar=yes, menubar=yes, status=no, scrollbars=yes')"><u><%= persname%></u></a></td>
            <td width="10%" <%=backcolor%>><%= reference%></td>
            <td width="45%" <%=backcolor%>><%= repamt%></td>
            <td width="10%" <%=backcolor%>><%= repStat%></td>
            <td width="10%" <%=backcolor%>><input id="<%=voucher%>" type="text" name="name" value="0" onChange="Change('<%=voucher%>',<%= repStat%>,this.value);" onfocus="this.select();"></td>
            <td width="5%"  <%=backcolor%>>
				<input type="checkbox" id="<%=voucher%>select_this_item" style="display: none" value="">
			</td>            
			</tr>
<%          xfound = true;
            newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;
          }  
        }
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] ajax/ApproveList.jsp Language Error");
    Log.println("[500] ajax/ApproveList.jsp - " + ex.toString());
    ex.printStackTrace();
%>
    <h1><%= Lang.getString("APP_SQL_ERROR")%><br></h1>
<%  
  } //try
%>
 <!-- </form>  -->

	</table>
	  <input id="btSave" type="button" name="B1" value="Confirm (to send request)"  onClick="Javascript: void SetNewValues('0')">
	</form>



<% if (!xfound) { %>
<strong><em>
<%= Lang.getString("APP_NO_REPORT") %><br>
</em></strong>
<% } %>
<% } 
%>
  <script language=JavaScript id="script" folder="<%= PersFile.getWebServer() + "/" + PersFile.getWebFolder() %>" file="<%=PersFile.getLanguage() %>/InventoryRequestList.js" />

<%
			}//stock checking not by others
		}//stock checking not me
	} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
	else { %>
		<%@ include file="ReloginRedirectMsg.jsp" %>
<%
	} 
%>
<%
Reg.close();      //cleaning up open connections 
Reporter.close();
Log.println("[000] ajax/ApproveList.jsp - Approval list finished for " + ownersName);
%>
<%@ include file="../UnScramble.jsp" %>
<%@ include file="../StatXlation.jsp" %>
<%@ include file="../LimitRequired.jsp" %>
<%@ include file="../DupSigner.jsp" %>
<%@ include file="../DepartRouteRule.jsp" %>



