<%--
AuditList.jsp - List out reports to be audited - allows batch auditing
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


<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="NumericSetup.jsp" %>
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
%>
<%@ include file="StatusInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<%@ include file="DepartInfo.jsp" %>
<%
   Log.println("[000] inventoryApproveList.jsp - start: " + ownersName); 

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
      Log.println("[000] AuditList.jsp - Audit access and personal database save for " + ownersName);
      SavePers.setConnection(PersFile.getConnection());
      SavePers.setSQLTerminator(PersFile.getSQLTerminator());
      SavePers.setFile(PData,ownersName); 
   } else {
      Log.println("[000] AuditList.jsp - Audit access by " + ownersName);
   }

   String NeedPassword = SystemDOM.getDOMTableValueFor("configuration", "pwd_audit","yes");
   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);
   String downlevel = request.getParameter("downlevel");
   int checkLevelsDown = java.lang.Integer.parseInt(downlevel);

   /*String SQLCommand = SystemDOM.getDOMTableValueFor("reporttable","selectaudit",""); 
   if (SQLCommand.equals("")) {
     SQLCommand = "SELECT ";
     SQLCommand += "NAME, PERS_NUM, RC_AMT, RP_STAT, ";
     SQLCommand += "CUR_DATE, SIGN1, VOUCHER, PVOUCHER, SIGN2, DEPART, RE_AMT, CURRENCY, COMPANY ";
     SQLCommand += "FROM REPORT ";
     SQLCommand += "WHERE RP_STAT = 'E2' ";
     SQLCommand += "ORDER BY RP_STAT" + PersFile.getSQLTerminator();
   }

   SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",PersFile.getPersNum());
   SQLCommand = Reg.SQLReplace(SQLCommand,"$level$", PersFile.getSecurityLevel());
	*/
	String SQLCommand = "SELECT * FROM DB_OPERATION WHERE OPERATION_STATUS = 'Signed' AND OPERATION_TYPE = 'Request' ORDER BY OPERATION_CREATED DESC;";
   if (Reg.setResultSet(SQLCommand)) {
      Log.println("[000] AuditList.jsp - SQL: " + SQLCommand);
  %>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <meta http-equiv="Pragma" content="no-cache">
     <meta http-equiv="Expires" content="-1">

     <title>Report Selection:</title>
     <link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     <script type="text/javascript">
     if (screen.width < 1024) {
       var link = document.getElementsByTagName( "link" )[ 0 ];
       link.href = "<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense800.css";
     }
     </script>
     <link rel="stylesheet" media="print" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/print.css" type="text/css">
     </head>
     <body onLoad="initForm()">
     <h1>Inventory Requests waiting for process:</h1><br>
<%   String persname;
     byte[] bArray;    //used for encrypted values
     String E;         //     ditto
     boolean xFlag;
     boolean xfound = false;
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
     String firstSigner;
     String signerColumn;
     String dupAllowed; 
     String adjustment; 
     String subTable;
     String depart;
     String prefer;
     String dueamt;
     String currency;
     String company;
%>
 
     <script>
     //<%= SQLCommand %>//
     </script>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
		<tr>
			<td width="5%"><input type="checkbox" name="select_all_item" onclick="onCheckAll(this);">All</td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>><u>Name</u></td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>><u>Date</u></td>
             <td class="ExpenseTag" width="50%" <%=backcolor%>><u>Reason</u></td>
             <td class="ExpenseTag" width="10%" <%=backcolor%>><u>Status</u></td>
             <td class="ExpenseTag" width="5%" <%=backcolor%>><u>Type</u></td>
		</tr>
		<form>
<% 
    newbackcolor = backcolor;
    backcolor = oldbackcolor; 
    oldbackcolor = newbackcolor;
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
        repStat = PersFile.getTrim(Reg.myResult.getString(4));  
        repamt = PersFile.getTrim(Reg.myResult.getString(3)); 
        curdate = PersFile.getTrim(Reg.myResult.getString(5));
        firstSigner = PersFile.getTrim(Reg.myResult.getString(6));  //need variable name for column later to check for dup sign
        voucher = PersFile.getTrim(Reg.myResult.getString(7));
        prefer = PersFile.getTrim(Reg.myResult.getString(8));
        depart = "";//PersFile.getTrim(Reg.myResult.getString(10));
        dueamt = "";//PersFile.getTrim(Reg.myResult.getString(11));
        currency = "";//PersFile.getTrim(Reg.myResult.getString(12));
        company = "";//PersFile.getTrim(Reg.myResult.getString(13));
		
		String OPERATION_ID=PersFile.getTrim(Reg.myResult.getString(1));
		String OPERATION_BY=PersFile.getTrim(Reg.myResult.getString(2));
		String OPERATION_CREATED=PersFile.getTrim(Reg.myResult.getString(3));
		String OPERATION_DELIVERED=PersFile.getTrim(Reg.myResult.getString(4));
		String OPERATION_PREPARED=PersFile.getTrim(Reg.myResult.getString(5));
		String OPERATION_SIGNED=PersFile.getTrim(Reg.myResult.getString(6));
		String OPERATION_REASON=PersFile.getTrim(Reg.myResult.getString(7));
		String OPERATION_STATUS=PersFile.getTrim(Reg.myResult.getString(8));
		String OPERATION_TYPE=PersFile.getTrim(Reg.myResult.getString(9));

        subTable = getRoutingRuleName(DepartDOM, depart, PersFile.depart, Log);
        repDBStat = StatXlation(repStat, CompanyName, StatusDOM);

        approvalType = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"approval");
        if (approvalType.equals("")) 
        {
          Log.println("[400] ApprovalList.jsp rule " + subTable + " not found - using default");  //jh - remove
          subTable = "default";
          approvalType = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"approval");
        }

        limitRequired = "No";
        CEOLimit = "No";
        dupAllowed = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"duplicatesignerallowed");
        signerColumn = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"updatesqlsigner");
        adjustment = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"leveladjustment");
 
        xFlag = Reporter.setPersNumInfo(reference); 
        if (true)//xFlag && CanApprove.canApprove(Reporter, depart, company, approvalType, checkLevelsDown + java.lang.Integer.parseInt(adjustment))) 
		{ 
          if (true)//CheckLimit(PersFile,repamt,currency, limitRequired,CEOLimit, Currency, Log) && CheckDupSigner(PersFile, firstSigner, dupAllowed, signerColumn))
		  {
%>          
            <tr>
				<td width="5%" bgcolor="#42c5f4"><input type="checkbox" name="select_this_report" voucher="<%= OPERATION_ID%>" value="<%= OPERATION_BY%>"></td>
				<td width="10%" bgcolor="#42c5f4"><%= OPERATION_BY%></td>
				<td width="10%" bgcolor="#42c5f4"><%= OPERATION_CREATED%></td>
				<td width="50%" bgcolor="#42c5f4"><%= OPERATION_REASON%></td>
				<td width="10%" bgcolor="#42c5f4"><%= OPERATION_STATUS%></td>
				<td width="5%" bgcolor="#42c5f4"><%= OPERATION_TYPE%></td>
            </tr>
<!--            <tr>
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
				-->
	 <%          xfound = true;
				newbackcolor = backcolor;
				backcolor = oldbackcolor; 
				oldbackcolor = newbackcolor;
				//starting of getting items
				String dinnerDate = "";
				String SQLGetDinnerDate;
				String bgcolor = backcolor;
				SQLGetDinnerDate = "SELECT ";
				SQLGetDinnerDate += "EXP_DATE ";
				SQLGetDinnerDate += "FROM EXPENSE ";
				SQLGetDinnerDate += "WHERE VOUCHER = '" + voucher + "'";
				SQLGetDinnerDate += " AND (EXPENSE = 'DINNER' OR EXPENSE = 'LUNCH')";
				SQLGetDinnerDate += PersFile.getSQLTerminator();
		
				SQLGetDinnerDate = "SELECT DB_ITEM.ITEM_NAME, DB_ITEM.ITEM_CATEGORY, DB_ITEM.ITEM_DESC, DB_OPERATED_ITEM.REF_AMOUNT_ITEM FROM DB_ITEM JOIN DB_OPERATED_ITEM ON DB_ITEM.ITEM_ID = DB_OPERATED_ITEM.REF_ID_ITEM WHERE TRIM(DB_OPERATED_ITEM.REF_ID_OPERATION) = " + OPERATION_ID;
				SQLGetDinnerDate += PersFile.getSQLTerminator();
				if (Reg2.setResultSet(SQLGetDinnerDate)) {
				try {
					do { 
						String sName = PersFile.getTrim(Reg2.myResult.getString(1));
						String sCat = PersFile.getTrim(Reg2.myResult.getString(2));
						String sDesc = PersFile.getTrim(Reg2.myResult.getString(3));
						String sAmount = PersFile.getTrim(Reg2.myResult.getString(4));

     %>
					<tr>
					<td width="5%">&nbsp;</td>
					<td width="10%" <%=backcolor%>><%= sName%></td>
					<td width="10%" <%=backcolor%> align="center"><%= sCat%></td>
					<td width="50%" <%=backcolor%>><%= sDesc%></td>
					<td width="5%"  <%=backcolor%>><%= sAmount%></td>
					<td width="5%" <%=backcolor%>>&nbsp;</td>
					</tr>
     <%     			xfound = true;
						newbackcolor = backcolor;
						backcolor = oldbackcolor;
						oldbackcolor = newbackcolor;
					} while (Reg2.myResult.next());
				} catch (java.lang.Exception ex) {
						Log.println("[500] AuditList.jsp SQLGetDinnerDate Error");
						Log.println("[500] AuditList.jsp - " + ex.toString());
						ex.printStackTrace();
			%>
						<h1>Error in the SQLGetDinnerDate - contact support.<br></h1>
			<%  
				} //try
%>
<!--					</table>
				</tr>
-->
<%				}
				//end of getting dinner items
		
			}  
        }
		newbackcolor = backcolor;
		backcolor = oldbackcolor; 
		oldbackcolor = newbackcolor;
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] AuditList.jsp Language Error");
    Log.println("[500] AuditList.jsp - " + ex.toString());
    ex.printStackTrace();
%>
    <h1>Error in the SQL logic - contact support.<br></h1>
<%  
  } //try
%>
  </form>
  </table>
<% if (!xfound) { %>
<strong><em><%= Lang.getString("noRepPen")%><br></em></strong>
<% } %>
<%-- Below starts the forms for interaction --%>  
<br>
                  
<table border="0" cellpadding="2" cellspacing="0" width="90%" class="offsetColor" style="border: 1px solid"><tr>
<tr><td width="100%">
<form method="POST" action="<%= PersFile.getAppServer()%>/<%= PersFile.getAppFolder()%>/inventorySave.jsp">
  <input type="hidden" name="email" value>
  <input type="hidden" name="ccode" value>
  <input type="hidden" name="company" value>
  <input type="hidden" name="database" value>
  <input type="hidden" name="voucher" value>
  <input type="hidden" name="reference" value>
  <input type="hidden" name="status" value>
  <input type="hidden" name="action" value="delivered">
  <input type="hidden" name="rcpt2" value="">
  <input type="hidden" name="reply2" value="">
  <input type="hidden" name="msgdata" value="">
<% if (NeedPassword.equalsIgnoreCase("NO"))
   {
%> 
  <input type="hidden" name="password" value="">
<% }
%>

  <table border="0" cellpadding="0" cellspacing="0" width="100%" height="38">
   <tr>
     <td width="40%" align="right"><strong><%= Lang.getString("auditBy")%></strong></td>
     <td width="60%" align="left"><input type="text" name="name" size="20" readOnly=Yes></td>
   </tr>

<% if (!NeedPassword.equalsIgnoreCase("NO"))
   {
%> 
   <tr>
     <td width="40%" align="right"><strong><%= Lang.getString("password")%></strong></td>
     <td width="60%" align="left"><input type="password" name="password" size="13"></td>
   </tr>
<% }
%>
   </table>
   <table border="0" cellpadding="0" cellspacing="0" width="100%" height="38">
   <tr>
   <td width="100%" align="center">
     <input type="button" value="Checked requests are delivered" name="B2" onClick="Javascript: void Approve()">
   </td>
   </tr> 
   </table>
</form>
</td></tr>
</table>

<script language="Javascript">

  function initForm() {
    document.forms[1].name.value = parent.contents.getDBValue(parent.Header,"name");
    //reference was here
    document.forms[1].voucher.value = "";
    document.forms[1].email.value = parent.contents.getDBValue(parent.Header,"email");
    document.forms[1].ccode.value = parent.CCode;
    document.forms[1].company.value = parent.company;
    document.forms[1].database.value = parent.database;
    document.forms[1].status.value = "";
    document.forms[1].action.value = "delivered";
    document.forms[1].rcpt2.value = "";
    document.forms[1].reply2.value = "";
    document.forms[1].msgdata.value = "";
	

    parent.contents.initStacks();
    parent.contents.setLastSQL("<%=SQLCommand %>"); 
    parent.contents.setLastDisplay("AuditList.jsp");

 }
      function onCheckAll(obj){
        for (var i = 0; i < document.forms[0].length; i++) {
          //if (isIE) {
             if (document.forms[0].elements[i].name == "select_this_report") {
				 if(obj.checked){
					document.forms[0].elements[i].checked = true;   
				 }
				 else{
					document.forms[0].elements[i].checked = false;   
				 }
             }
        }
	  }

 var submitSafetyFlag = true;
 function Approve(){

   var delim = "";
   document.forms[1].voucher.value = "";
   document.forms[1].status.value = "";
   
   if (submitSafetyFlag) {
     for (var i = 0; i < document.forms[0].length; i++) {
       if (document.forms[0].elements[i].name == "select_this_report" && document.forms[0].elements[i].checked == true) {
         document.forms[1].voucher.value += delim + parent.contents.getVoucherValue(document.forms[0].elements[i]);
         document.forms[1].status.value += delim + document.forms[0].elements[i].value;
         delim = ";";   
       }
     }
     if (delim == ";") {
     <% if (NeedPassword.equalsIgnoreCase("NO")){
     %>
        if (confirm("<%= Lang.getString("okAccRep")%>")) {
     <% }
     %>
            document.forms[1].submit();
            submitSafetyFlag = false;
     <% if (NeedPassword.equalsIgnoreCase("NO")){
     %>
        }
     <% }
     %>
     } else {
       alert("<%= Lang.getString("checkRep")%>");
     }
   }
 }
</script>
<!--
  <form method="POST" action="<%= PersFile.getAppServer()%>/<%= PersFile.getAppFolder()%>/AuditList.jsp"">
    <h2><%= Lang.getString("auditLevSho")%>
    <input type="text" name="downlevel" size="3" value="<%=checkLevelsDown%>"> 
    <input type="button" value="<%= Lang.getString("butSho")%>" name="B1" onClick="Javascript: void SubmitLevel()"></h2>
    <input type="hidden" name="email" value>
    <input type="hidden" name="database" value>
    <input type="hidden" name="ccode" value>
    <input type="hidden" name="persdbase" value>
  </form>
  -->
  <script language=JavaScript>
  function SubmitLevel() {
    with(document.forms[2]) {
    if (downlevel.value >= "1" && downlevel.value <= "9" && downlevel.value.length == 1) {
       parent.contents.setDBPair(parent.PersDBase,"approvallevel",downlevel.value);
       email.value = parent.contents.getNameValue(parent.Header, "email");
       database.value = parent.database;
       persdbase.value = parent.contents.CreatePersDBXML(parent.PersDBase);
       ccode.value = parent.CCode;
       submit();  

    } else {
      alert("<%= Lang.getString("auditLevMusInc") %>");
    }
    }
  }
  </script>
  </body>
     <head>
     <meta http-equiv="Pragma" content="no-cache">
     <meta http-equiv="Expires" content="-1">
     </head>
  </html>
<% } else { %>
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>Introduction Page</title>
     <link rel="stylesheet" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder()%>/expense.css" type="text/css">
    </head>
    <body>
    <p><%=PersFile.name%>, <%= Lang.getString("noRepFou") %>
    <% Log.println("[400] AuditList.jsp No expense reports where found."); %>
     </p>
    </body>
     <head>
     <meta http-equiv="Pragma" content="no-cache">
     <meta http-equiv="Expires" content="-1">
     </head>
    </html>
<% } //if (Reg.setResultSet(SQLCommand)) 

} else { %>
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 
Reporter.close();
Log.println("[000] AuditList.jsp - Done: " + ownersName);
%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>
<%@ include file="LimitRequired.jsp" %>
<%@ include file="DupSigner.jsp" %>
<%@ include file="DepartRouteRule.jsp" %>