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
   Log.println("[000] AuditList.jsp - start: " + ownersName); 

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

   String SQLCommand = SystemDOM.getDOMTableValueFor("reporttable","selecthr_leave",""); 
   if (SQLCommand.equals("")) {
     SQLCommand = "SELECT LEAVE_STATUS, PERS_NUM, LEAVE_TYPE, LEAVE_FROM, LEAVE_FROM_AMPM, LEAVE_TO, LEAVE_TO_AMPM, LEAVE_REASON, LEAVE_CREATED, LEAVE_VO, LEAVE_NUM, LEAVE_TOTAL FROM LEAVERECORD WHERE LEAVE_STATUS = 'Verified' ORDER BY LEAVE_CREATED";
     SQLCommand += "ORDER BY RP_STAT" + PersFile.getSQLTerminator();
   }

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
     <h1>Leave list:</h1><br>
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
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_CREATED") %></th>
			 <th width="5%" <%=backcolor%>>UsreID</th>
			 <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("name") %></th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TYPE") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_FROM") %></th>
             <th width="2.5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_FROM_AMPM") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TO") %></th>
             <th width="2.5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TO_AMPM") %></th>
             <th width="5%" align="center" <%=backcolor%>>Total</th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_STATUS") %></th>
             <th width="30%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_REASON") %></th>
             <th width="5%" <%=backcolor%>>Receipts</th>
     </tr>
     <form>
<% 
    newbackcolor = backcolor;
    backcolor = oldbackcolor; 
    oldbackcolor = newbackcolor;
    try {
     do { 
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
		String name = reference;
		repDBStat = PersFile.getTrim(Reg.myResult.getString(12));
		xFlag = true;
        if (xFlag){//xFlag && CanApprove.canApprove(Reporter, depart, company, approvalType, checkLevelsDown + java.lang.Integer.parseInt(adjustment))) { 
			String SQLCommand2 = "SELECT FNAME FROM USER WHERE PERS_NUM =";
			SQLCommand2 += reference + PersFile.getSQLTerminator();
			if (Reg2.setResultSet(SQLCommand2)) {
				name = PersFile.getTrim(Reg2.myResult.getString(1)); 
			}
          if (true){//CheckLimit(PersFile,repamt,currency, limitRequired,CEOLimit, Currency, Log) && CheckDupSigner(PersFile, firstSigner, dupAllowed, signerColumn)){
%>          
            <tr>
            <td width="5%" <%=backcolor%>><%= created%></td>
            <td width="5%" align="center" <%=backcolor%>><%= reference%></td>
            <td width="10%" align="center" <%=backcolor%>><%= name%></td>
            <td width="5%" <%=backcolor%>><%= voucher%></td>
            <td width="10%"  align="center" <%=backcolor%>><%= pvoucher%></td>
            <td width="2.5%"  <%=backcolor%>><%= repdate%></td>
            <td width="10%"  align="center" <%=backcolor%>><%= persname%></td>
            <td width="2.5%"  <%=backcolor%>><%= repamt%></td>
            <td width="5%" align="center" <%=backcolor%>><%= repDBStat%></td>
            <td width="5%"  align="center" <%=backcolor%>><%= repStat %></td>
            <td width="30%" align="center" <%=backcolor%>><%= reason%></td>
<%
			SQLCommand2 = "SELECT PERS_NUM FROM SCAN WHERE SCAN_REF =";
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
<%          xfound = true;
            newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;
          }  
        }
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

<form method="POST" action="<%= PersFile.getAppServer()%>/<%= PersFile.getAppFolder()%>/AuditSavehr_leave.jsp">
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

</form>


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
    parent.contents.setLastDisplay("AuditList.jsp");

 }

 var submitSafetyFlag = true;
 function Approve(){

   var delim = "";
   document.forms[1].voucher.value = "";
   document.forms[1].status.value = "";
   document.forms[1].msgdata.value = "";
   document.forms[1].reply2.value = "";
   document.forms[1].rcpt2.value = "";
   
   if (submitSafetyFlag) {
     for (var i = 0; i < document.forms[0].length; i++) {
       if (document.forms[0].elements[i].name == "select_this_report" && document.forms[0].elements[i].checked == true) {
         document.forms[1].voucher.value += delim + parent.contents.getVoucherValue(document.forms[0].elements[i]);
         document.forms[1].status.value += delim + document.forms[0].elements[i].value;
		 document.forms[1].msgdata.value += delim + parent.contents.getMsgdataValue(document.forms[0].elements[i]);
		 document.forms[1].reply2.value += delim + parent.contents.getReply2Value(document.forms[0].elements[i]);
		 document.forms[1].rcpt2.value += delim + parent.contents.getRcpt2Value(document.forms[0].elements[i]);
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
  </form>-->
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