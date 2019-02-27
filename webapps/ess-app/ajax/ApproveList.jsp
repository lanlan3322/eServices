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

   String PData =  request.getParameter("persdbase");
   if (PData != null) {
      Log.println("[000] ajax/ApproveList.jsp - Approval access and personal database save for " + ownersName);
      SavePers.setConnection(PersFile.getConnection());
      SavePers.setSQLTerminator(PersFile.getSQLTerminator());
      SavePers.setFile(PData,ownersName); 
   } else {
      Log.println("[000] ajax/ApproveList.jsp - Approval access by " + ownersName);
   }

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
   
   String SQLCommand = SystemDOM.getDOMTableValueFor("reporttable","selectapprove",""); 

   if (SQLCommand.equals("")) {
     SQLCommand = "SELECT ";
     SQLCommand += "NAME, PERS_NUM, RC_AMT, RP_STAT, ";
     SQLCommand += "CUR_DATE, SIGN1, VOUCHER, PVOUCHER, SIGN2, DEPART, ADMIN1, CURRENCY, COMPANY, XCHECK ";
     SQLCommand += "FROM REPORT ";
     SQLCommand += "WHERE RP_STAT = 'B1' OR RP_STAT = 'C1' OR RP_STAT = 'D1' OR RP_STAT = 'D2' ";
     SQLCommand += "ORDER BY RP_STAT" + PersFile.getSQLTerminator();
   }

   SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",PersFile.getPersNum());
%>   
     <h1><%=Lang.getString("APP_WELCOME") %></h1><br>

<%   if (Reg.setResultSet(SQLCommand)) {
%>
     <table border="0" cellspacing="0" cellpadding="0" id="approveTable">
     	<thead>
     		<tr>
				<th width="15%" <%=backcolor%>><%= Lang.getColumnTitle("reportReferenceName") %></th>
				<th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("date") %></th>
				<th width="30%" <%=backcolor%>><%= Lang.getColumnTitle("name") %></th>
				<th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("amount") %></th>
				<th width="25%" <%=backcolor%>><%= Lang.getColumnTitle("paymentStatus") %></th>
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
        if (encrypt.equalsIgnoreCase("YES")) {
          bArray = Reg.myResult.getBytes(1);
          E = new String(bArray);
          persname = unScramble(E,encrypt,encryptKey);   
        } else {
          persname = PersFile.getTrim(Reg.myResult.getString(1));
        }
        reference = PersFile.getTrim(Reg.myResult.getString(2));
        repamt = PersFile.getTrim(Reg.myResult.getString(3)); 
        repStat = PersFile.getTrim(Reg.myResult.getString(4));  
        curdate = PersFile.getTrim(Reg.myResult.getString(5)); 
        firstSigner = PersFile.getTrim(Reg.myResult.getString(6));  //need variable name for column later to check for dup sign
        voucher = PersFile.getTrim(Reg.myResult.getString(7));
        prefer = PersFile.getTrim(Reg.myResult.getString(8));
        secondSigner = PersFile.getTrim(Reg.myResult.getString(9));  //need variable name for column later to check for dup sign
        depart = PersFile.getTrim(Reg.myResult.getString(10));
        adminSigner = PersFile.getTrim(Reg.myResult.getString(11));
        currency = PersFile.getTrim(Reg.myResult.getString(12));
        company = PersFile.getTrim(Reg.myResult.getString(13));
		xcheck = PersFile.getTrim(Reg.myResult.getString(14));

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

        xFlag = Reporter.setPersNumInfo(reference); 
        if (!xFlag) Log.println("[500] ajax/ApproveList.jsp reporter not found: " + reference);

        xDup = dupAllowed.toUpperCase().equals("YES");
        xLimit = CheckLimit(PersFile,repamt, currency,limitRequired,CEOLimit, Currency, Log); 

		xReAssign = false;
		String SQLCommand9 = "SELECT MANAGER FROM DEPART WHERE DEPART ='";
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
		}
        
        Log.println("[000] ajax/ApproveList.jsp checking approval type: " + approvalType + " for " + Reporter.email + ",voucher " + voucher + " [" + ownersName + "]"); //jh remove
        if (xFlag && (xReAssign || CanApprove.canApprove(Reporter, depart, company, approvalType, checkLevelsDown + java.lang.Integer.parseInt(adjustment)))) { 
          Log.println("[000] ajax/ApproveList.jsp can Approve this report: "  + voucher + " [" + ownersName + "]"); //jh remove
          if ( ifSeemsOK(PersFile, xDup, atLeastOnce, adminSigner, firstSigner, secondSigner, xLimit) ){
        	  //Dt.getSimpleDate(Dt.getDateFromXBase(curdate))
        	  
%>       
            <tr>
            <td width="15%" <%=backcolor%>><%= voucher%></td>
            <td width="10%" <%=backcolor%>><%= Dt.getUserDateStr(Dt.getSimpleDate(Dt.getDateFromXBase(curdate)),PersFile.getDateFormat())%></td>
            <td width="30%" <%=backcolor%>><%= persname%></td>
            <td width="10%" <%=backcolor%>><%= money.format(money.parse(repamt))%></td>
            <td width="25%" <%=backcolor%>><%= Lang.getDataString(repDBStat) %></td>
            <td width="10%" <%=backcolor%>><a href="javascript: void parent.writeDelayMsg('<%= PersFile.getAppServer()%>/<%= PersFile.getAppFolder()%>/<%= reportScript %>?email=<%= PersFile.repStr(ownersName,"'","\\'") %>&rcpt2=<%= Reporter.getPrintableEmailAddress()%>&reference=<%= reference%>&voucher=<%= voucher%>&ccode=<%= CCode%>&status=<%= repStat%>&database=<%= database%>')"><span class="ExpenseReturnLink"><%= Lang.getString("select")%></span></a></td>
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
<% if (!xfound) { %>
<strong><em>
<%= Lang.getString("APP_NO_REPORT") %><br>
</em></strong>
<% } %>
<% } 
//if(PersFile.depart.equalsIgnoreCase("TEST"))
{
%>
  <br>
     <h1>Pending leaves to be approved:</h1><br>
     <table border="0" cellspacing="0" cellpadding="0" id="approveTable">
     	<thead>
     		<tr>
             <!--<th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_CREATED") %></th>-->
			 <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("name") %></th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TYPE") %></th>
             <th width="15%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_FROM") %></th>
             <th width="2.5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_FROM_AMPM") %></th>
             <th width="15%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TO") %></th>
             <th width="2.5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TO_AMPM") %></th>
             <th width="5%" <%=backcolor%>>Total</th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_STATUS") %></th>
             <th width="25%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_REASON") %></th>
             <th width="5%" <%=backcolor%>>Receipts</th>
			<th width="5%" <%=backcolor%>>&nbsp;</th>
			<th width="5%" <%=backcolor%>>&nbsp;</th>
			</tr>
		</thead>

  <!--   <form>  -->
<% 
   String SQLCommand_leave = SystemDOM.getDOMTableValueFor("reporttable","selectapprove_leave",""); 
   if (Reg.setResultSet(SQLCommand_leave)) {
    backcolor = "class=\"TableData offsetColor\"";
    oldbackcolor = "class=\"TableData\"";
    newbackcolor = backcolor;
   try {
     do { 
		String total = PersFile.getTrim(Reg.myResult.getString(12)); 
        repStat = PersFile.getTrim(Reg.myResult.getString(1)); 
        reference = PersFile.getTrim(Reg.myResult.getString(2)); //used for subordinate lookup
        voucher = PersFile.getTrim(Reg.myResult.getString(3));
        String pvoucher = PersFile.getTrim(Reg.myResult.getString(4));
        String repdate = PersFile.getTrim(Reg.myResult.getString(5));  
        persname = PersFile.getTrim(Reg.myResult.getString(6));
        depart = PersFile.depart;
		company = PersFile.company;
        repamt = PersFile.getTrim(Reg.myResult.getString(7)); 
		String reason = PersFile.getTrim(Reg.myResult.getString(8)); 
		String created = PersFile.getTrim(Reg.myResult.getString(9)); 
		String manager = PersFile.getTrim(Reg.myResult.getString(10)); 
		String leaveNum = PersFile.getTrim(Reg.myResult.getString(11)); 
		xFlag = false;
        xFlag = manager.equalsIgnoreCase(PersFile.getPersNum());
		String approved = "Approved";
		String rejected = "Rejected";
		String name = reference;
        if (xFlag){
			String SQLCommand3 = "SELECT FNAME FROM USER WHERE PERS_NUM =";
			SQLCommand3 += reference + PersFile.getSQLTerminator();
			if (Reg2.setResultSet(SQLCommand3)) {
				name = PersFile.getTrim(Reg2.myResult.getString(1)); 
			}
			if (true){
        	  //Dt.getSimpleDate(Dt.getDateFromXBase(curdate))        	  
%>          
            <tr>
            <!--<td width="10%" <%=backcolor%>><%= created%></td>-->
            <td width="10%" <%=backcolor%>><%= name%></td>
            <td width="5%" <%=backcolor%>><%= voucher%></td>
            <td width="15%" <%=backcolor%>><%= pvoucher%></td>
            <td width="2.5%"  <%=backcolor%>><%= repdate%></td>
            <td width="15%" <%=backcolor%>><%= persname%></td>
            <td width="2.5%"  <%=backcolor%>><%= repamt%></td>
            <td width="5%" <%=backcolor%>><%= total %></td>
            <td width="5%" <%=backcolor%>><%= repStat %></td>
            <td width="25%" <%=backcolor%>><%= reason%></td>
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
            <td width="5%" <%=backcolor%>><a href="javascript: void parent.writeDelayMsg('<%= PersFile.getAppServer()%>/<%= PersFile.getAppFolder()%>/ajax/ApproveSave_leave.jsp?email=<%= PersFile.repStr(ownersName,"'","\\'") %>&reply2=<%= ownersName%>&rcpt2=<%= Reporter.getPrintableEmailAddress()%>&reference=<%= reference%>&voucher=<%= approved%>&ccode=<%= CCode%>&status=<%= leaveNum%>&database=<%= database%>')"><span class="ExpenseReturnLink">Approve</span></a></td>
            <td width="5%" <%=backcolor%>><a href="javascript: void parent.writeDelayMsg('<%= PersFile.getAppServer()%>/<%= PersFile.getAppFolder()%>/ajax/Reject_LeaveV2.jsp?email=<%= PersFile.repStr(ownersName,"'","\\'") %>&reply2=<%= ownersName%>&rcpt2=<%= Reporter.getPrintableEmailAddress()%>&reference=<%= reference%>&voucher=<%= rejected%>&ccode=<%= CCode%>&status=<%= leaveNum%>&database=<%= database%>')"><span class="ExpenseReturnLink">Reject</span></a></td>
            </tr>
<%          xfound_leave = true;
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
<% } %>
 <!-- </form>  -->
  </table>

<% if (!xfound_leave) { %>
<strong><em>
<%= Lang.getString("APP_NO_REPORT") %><br>
</em></strong>
<% } 
}//if TEST or PA department
%>
  <script language=JavaScript id="script" folder="<%= PersFile.getWebServer() + "/" + PersFile.getWebFolder() %>" file="<%=PersFile.getLanguage() %>/ApproveList.js" />

<%} else { %>
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
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



