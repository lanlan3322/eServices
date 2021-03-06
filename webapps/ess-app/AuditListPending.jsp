<%--
AuditListPending.jsp - Audit List with a different SQL selection
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
   Reg.setConnection(PersFile.getConnection()); 
   Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

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
      Log.println("[000] AuditListPending.jsp - Audit access and personal database save for " + ownersName);
      SavePers.setConnection(PersFile.getConnection());
      SavePers.setSQLTerminator(PersFile.getSQLTerminator());
      SavePers.setFile(PData,ownersName); 
   } else {
      Log.println("[000] AuditListPending.jsp - Audit access by " + ownersName);
   }

   String NeedPassword = SystemDOM.getDOMTableValueFor("configuration", "pwd_audit","yes");
   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);
   String downlevel = request.getParameter("downlevel");
   int checkLevelsDown = java.lang.Integer.parseInt(downlevel);

   String SQLCommand = SystemDOM.getDOMTableValueFor("reporttable","selectpending",""); 
   if (SQLCommand.equals("")) {
     SQLCommand = "SELECT ";
     SQLCommand += "NAME, PERS_NUM, RC_AMT, RP_STAT, ";
     SQLCommand += "CUR_DATE, SIGN1, VOUCHER, PVOUCHER, SIGN2, DEPART, SIGN3, CURRENCY, COMPANY ";
     SQLCommand += "FROM REPORT ";
     SQLCommand += "WHERE RP_STAT = 'G2' ";
     SQLCommand += "ORDER BY RP_STAT" + PersFile.getSQLTerminator();
   }

   SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$", PersFile.getPersNum());
   SQLCommand = Reg.SQLReplace(SQLCommand,"$level$", PersFile.getSecurityLevel());

   if (Reg.setResultSet(SQLCommand)) {
      // Log.println("[---] AuditListPending.jsp - by " + ownersName + " with " + SQLCommand);//jh remove
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
     <h1>Reports that you can audit:</h1><br>
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
     String auditor;
     String company;
%>
 
     <script>
     //<%= SQLCommand %>//
     </script>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
     <tr>
     <td width="5%" <%=backcolor%> align='center'></td>
     <td width="10%" <%=backcolor%> align='center'><u>Central #</u></td>
     <td width="10%" <%=backcolor%> align='center'><u>User's #</u></td>
     <td width="9%" <%=backcolor%> align='center'><u>Cur Date</u></td>
     <td width="16%" <%=backcolor%> align='center'><u>Name</u></td>
     <td width="8%" <%=backcolor%> align='center'><u>Total</u></td>
     <td width="8%" <%=backcolor%> align='center'><u>Due</u></td>
     <td width="25%" <%=backcolor%> align='left'><u>Auditor</u></td>
     <td width="8%" <%=backcolor%>></td>
     </tr>
     <form>
<% try {
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
        depart = PersFile.getTrim(Reg.myResult.getString(10));
        dueamt = PersFile.getTrim(Reg.myResult.getString(11));
        auditor = PersFile.getTrim(Reg.myResult.getString(12));
        currency = PersFile.getTrim(Reg.myResult.getString(13));
        company = PersFile.getTrim(Reg.myResult.getString(14));

        subTable = getRoutingRuleName(DepartDOM, depart, PersFile.depart, Log);
        //repDBStat = StatXlation(repStat, CompanyName, StatusDOM);

        approvalType = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"approval");
        if (approvalType.equals("")) 
        {
          // Log.println("[---] 400 ApprovalList.jsp rule " + subTable + " not found - using default");  //jh - remove
          subTable = "default";
          approvalType = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"approval");
        }

        limitRequired = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"limitrequired");
        CEOLimit = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"ceolimit");
        dupAllowed = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"duplicatesignerallowed");
        signerColumn = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"updatesqlsigner");
        adjustment = StatusDOM.getDOMTableValueWhere(subTable,"translation",repStat,"leveladjustment");
 
        xFlag = Reporter.setPersNumInfo(reference); 

        //if (Reporter.getDepartment().equals("")) Reporter.depart = depart;  //jh 1-7-2003
        //if (Reporter.getDepartment().equals("")) xFlag = false;             //jh 1-7-2003

        // Log.println("[---] AuditListPending.jsp checking approval type: " + approvalType + " for " + Reporter.email + ",voucher " + voucher + " [" + ownersName + "]"); //jh remove
        if (xFlag && CanApprove.canApprove(Reporter, depart, company, approvalType, checkLevelsDown + java.lang.Integer.parseInt(adjustment))) { 
          // Log.println("[---] AuditListPending.jsp can Approve this report: "  + voucher + " [" + ownersName + "]"); //jh remove
          if (CheckLimit(PersFile,repamt,currency,limitRequired,CEOLimit, Currency, Log) && CheckDupSigner(PersFile, firstSigner, dupAllowed, signerColumn)){
%>          
            <tr>
            <td width="5%"  <%=backcolor%>><input type="checkbox" name="select_this_report" voucher="<%= voucher%>" value="<%= repStat%>"></td>
            <td width="10%" <%=backcolor%> align="center"><%= voucher%></td>
            <td width="10%" <%=backcolor%> align="center"><%= prefer%></td>
            <td width="9%" <%=backcolor%>><%= Dt.getSimpleDate(Dt.getDateFromXBase(curdate))%></td>
            <td width="16%" <%=backcolor%> align="center"><%= persname%></td>
            <td width="8%" <%=backcolor%> align="center"><%= money.format(money.parse(repamt))%></td>
            <td width="8%" <%=backcolor%> align="center"><%= money.format(money.parse(dueamt))%></td>
            <td width="25%" <%=backcolor%>><%= auditor%></td>
            <td width="8%" <%=backcolor%>><a href="javascript: void parent.contents.writeDelayMsg('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/AuditReport.jsp?email=<%= PersFile.repStr(ownersName,"'","\\'") %>&rcpt2=<%= Reporter.getPrintableEmailAddress()%>&reference=<%= reference%>&voucher=<%= voucher%>&ccode=<%= CCode%>&status=<%= repStat%>&database=<%= database%>')"><span class="ExpenseReturnLink">Select</span></a></td>
            </tr>
<%          xfound = true;
            newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;
          }  
        }
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] AuditListPending.jsp Language Error");
    Log.println("[500] AuditListPending.jsp - " + ex.toString());
    ex.printStackTrace();
%>
    <h1>Error in the SQL logic - contact support.<br></h1>
<%  
  } //try
%>
  </form>
  </table>
<% if (!xfound) { %>
<strong><em>
No reports pending your signoff at this level.<br>
</em></strong>
<% } %>
<%-- Below starts the forms for interaction --%>  
<br>
<div class="Expensetag">
<%= SystemDOM.getDOMTableValueFor("messages", "auditlist") %>
</div>                  
<table border="0" cellpadding="2" cellspacing="0" width="90%" class="offsetColor" style="border: 1px solid"><tr>
<tr><td width="100%">
<form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/AuditSave.jsp">
  <input type="hidden" name="email" value>
  <input type="hidden" name="ccode" value>
  <input type="hidden" name="company" value>
  <input type="hidden" name="database" value>
  <input type="hidden" name="voucher" value>
  <input type="hidden" name="reference" value>
  <input type="hidden" name="status" value>
  <input type="hidden" name="action" value="result">
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
     <td width="40%" align="right"><strong>Audited by:&nbsp;</strong></td>
     <td width="60%" align="left"><input type="text" name="name" size="20" readOnly=Yes></td>
   </tr>

<% if (!NeedPassword.equalsIgnoreCase("NO"))
   {
%> 
   <tr>
     <td width="40%" align="right"><strong>Password: &nbsp;</strong></td>
     <td width="60%" align="left"><input type="password" name="password" size="13"></td>
   </tr>
<% }
%>
   </table>
   <table border="0" cellpadding="0" cellspacing="0" width="100%" height="38">
   <tr>
   <td width="100%" align="center">
     <input type="button" value="Checked reports are OK for further processing" name="B2" onClick="Javascript: void Approve()">
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
    document.forms[1].action.value = "result";
    document.forms[1].rcpt2.value = "";
    document.forms[1].reply2.value = "";
    document.forms[1].msgdata.value = "";

    parent.contents.initStacks();
    parent.contents.setLastSQL("<%=SQLCommand %>"); 
    parent.contents.setLastDisplay("AuditListPending.jsp");

 }

 var submitSafetyFlag = true;
 function Approve(){

   var delim = "";
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
        if (confirm("'OK' to accept selected reports for further processing. 'Cancel' to abort.")) {
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
       alert("Must check report(s) that you wish to approve");
     }
   }
 }
</script>

  <form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/AuditListPending.jsp"">
    <h2>Audit levels to show:&nbsp;
    <input type="text" name="downlevel" size="3" value="<%=checkLevelsDown%>"> 
    <input type="button" value="Show" name="B1" onClick="Javascript: void SubmitLevel()"></h2>
    <input type="hidden" name="email" value>
    <input type="hidden" name="database" value>
    <input type="hidden" name="ccode" value>
    <input type="hidden" name="persdbase" value>
  </form>
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
      alert("'Audit levels to show' must be between 1 and 9 inclusive");
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
     <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
    </head>
    <body>
    <p><%=PersFile.name%>, No expense reports have been found.
    <% Log.println("[400] AuditListPending.jsp No expense reports where found."); %>
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
Log.println("[000] AuditListPending.jsp - Audit list finished for " + ownersName);
%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>
<%@ include file="LimitRequired.jsp" %>
<%@ include file="DupSigner.jsp" %>
<%@ include file="DepartRouteRule.jsp" %>



