<%--
ReleaseList.jsp - Lists reports for the EOD process 
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
<jsp:useBean id = "Notify"
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
     scope="page" />
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
   Reg.setConnection(PersFile.getConnection()); 
   Reg.setSQLTerminator(PersFile.getSQLTerminator()); 
   
   Reporter.setConnection(PersFile.getConnection());
   Reporter.setSQLTerminator(PersFile.getSQLTerminator());
   Reporter.setSQLStrings();

   Notify.setConnection(PersFile.getConnection()); 
   Notify.setSQLTerminator(PersFile.getSQLTerminator()); 
   Notify.setSQLStrings();
   
   Log.println("[000] ReleaseList.jsp - run by " + ownersName);

   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);
   
   String SQLCommand = SystemDOM.getDOMTableValueFor("releasepayments","listsql","");
   String checkedoff = SystemDOM.getDOMTableValueFor("releasepayments","checkedoff","no");
   
   if (SQLCommand.equals("")) {
     SQLCommand = "SELECT ";
     SQLCommand += "NAME, REPORT.PERS_NUM, RE_AMT, RP_STAT, CUR_DATE, ";
     SQLCommand += "SUB_DATE, VOUCHER, PVOUCHER, RC_AMT, REPORT.DEPART, USER.CASH ";
     SQLCommand += "FROM REPORT LEFT JOIN USER ON USER.PERS_NUM = REPORT.PERS_NUM ";
     SQLCommand += "WHERE RP_STAT = 'G3' AND USER.CASH <> 'VERIFYING' AND USER.CASH <> 'HOLD' ";
     SQLCommand += "AND USER.ACTIVE ORDER BY RP_STAT ASC, VOUCHER ASC" + PersFile.getSQLTerminator();
   }

   boolean xFound = Reg.setResultSet(SQLCommand); %>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <meta http-equiv="Pragma" content="no-cache">
     <meta http-equiv="Expires" content="-1">

     <title>Message Selection:</title>
     <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     </head>
     <body onLoad="initForm()">
     <h1><span id="checkedRepPro">Checked reports will be released for processing:</span></h1>
<%   String persname;
     byte[] bArray;    //used for encrypted values
     String E;         //     ditto
     String voucher;
     String pvoucher;
     String reference;
     String curdate;
     String repamt;
     String repStat;
     String repDBStat;
     String backcolor = "class=\"TableData offsetColor\"";
     String oldbackcolor = "class=\"TableData\"";
     String newbackcolor;
     String subTable;
     String depart;
     String recamt;
     String method;
     String checked;  
	 String oldName = "";
	 String newName = "";
	 String totalAmount = "0.0";
     int reportCount = 0;
   
     java.util.Date cDate = new java.util.Date();
%>
 
     <script>
     //<%= SQLCommand %>//
     </script>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">

     <tr>
     <td width="5%" align="center"></td>
     <td width="10%" align="center"><u><%= Lang.getString("thReport")%></u></td>
     <!--<td width="10%" align="center"><u><%= Lang.getString("usersNum")%></u></td>-->
     <td width="15%" align="center"><u><%= Lang.getString("thLastSub")%></u></td>
     <td width="15%" align="center"><u><%= Lang.getString("thReporter")%></u></td>
     <td width="15%" align="center"><u><%= Lang.getString("thDepartement")%></u></td>
     <td width="15%" align="center"><u><%= Lang.getString("thAmount")%></u></td>
     <td width="15%" align="center"><u><%= Lang.getString("thStatus")%></u></td>
     <!--<td width="5%" align="center"><u><%= Lang.getString("thPayMet")%></u></td>-->
     <td width="5%"><u>Payment</u></td>
     <td width="5%"></td>
     </tr>

     <form>
   
<% if (xFound) {
   try {
     do { 
        if (encrypt.equalsIgnoreCase("YES")) {
          bArray = Reg.myResult.getBytes(1);
          E = new String(bArray);
          persname = unScramble(E,encrypt,encryptKey);   
        } else {
          persname = PersFile.getTrim(Reg.myResult.getString(1));
        }
        persname = PersFile.setRightName(persname);
        reference = PersFile.getTrim(Reg.myResult.getString(2));
        repamt = PersFile.getTrim(Reg.myResult.getString(3)); 
        repStat = PersFile.getTrim(Reg.myResult.getString(4));  
        curdate = PersFile.getTrim(Reg.myResult.getString(5)); 
        voucher = PersFile.getTrim(Reg.myResult.getString(7));
        pvoucher = PersFile.getTrim(Reg.myResult.getString(8));
        recamt = PersFile.getTrim(Reg.myResult.getString(9));        
        depart = PersFile.getTrim(Reg.myResult.getString(10));
        method = PersFile.getTrim(Reg.myResult.getString(11));
		newName = persname;
 
        subTable = getRoutingRuleName(DepartDOM, depart, PersFile.depart, Log);
        repDBStat = StatXlation(repStat, CompanyName, StatusDOM);

        //if (SQLType.equals("MM/DD/YYYY")) { 
          cDate = Dt.getDateFromXBase(curdate);
        //} else {    // s/b YYYY-MM-DD
        // cDate = Dt.getDateFromSQL(curdate);
        //}

        if (method.equalsIgnoreCase("HOLD") || method.equalsIgnoreCase("VERIFYING") || checkedoff.equalsIgnoreCase("yes"))
        {
          checked = "";
        } else {
          checked = "checked";
        }     
		if(false){//!oldName.equals("") && !oldName.equalsIgnoreCase(newName)){
%>          
        <tr>
        <td width="10%"  colspan="3" <%=backcolor%> align="right"><strong>PAY TO:</strong></td>
        <td width="30%" colspan="3" <%=backcolor%> align="left"><strong><%= oldName%></strong></td>
        <td width="15%" <%=backcolor%> align="right"><strong>TOTAL:</strong></td>
        <td width="15%" <%=backcolor%> align="left"><strong><%= money.format(money.parse(totalAmount))%></strong></td>
        </tr>
<%		
			newbackcolor = backcolor;
			backcolor = oldbackcolor; 
			oldbackcolor = newbackcolor;
			totalAmount = "0.0";
		}
		oldName = newName;
%>          
        <tr>
        <td width="5%"  <%=backcolor%>><input type="checkbox" name="select_this_report" voucher="<%= voucher%>" value="<%= repStat%>" <%= checked %>></td>
        <td width="10%" <%=backcolor%> align="center"><%= voucher%></td>
        <!--<td width="10%" <%=backcolor%> align="center"><%= pvoucher%></td>-->
        <td width="15%" <%=backcolor%> align="center"><%= Dt.getSimpleDate(Dt.getDateFromXBase(curdate))%></td>
        <td width="15%" <%=backcolor%> align="center"><%= persname%></td>
        <td width="15%" <%=backcolor%> align="center"><%= depart%></td>
        <td width="15%" <%=backcolor%> align="center"><%= money.format(money.parse(recamt))%></td>
        <td width="15%" <%=backcolor%> align="center"><%= Lang.getDataString(repDBStat)%></td>
        <!--<td width="5%" <%=backcolor%> align="center"><%= method%></td>-->
        <td width="5%"  <%=backcolor%>><input type="text" <%=backcolor%> name="payment" value="GIRO"></td>
        <td width="5%" <%=backcolor%>><a href="javascript: void parent.contents.writeDelayMsg('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/AuditReport.jsp?email=<%= PersFile.repStr(ownersName,"'","\\'") %>&rcpt2=<%= Reporter.getPrintableEmailAddress()%>&reference=<%= reference%>&voucher=<%= voucher%>&ccode=<%= CCode%>&status=<%= repStat%>&database=<%= database%>')"><span class="ExpenseReturnLink"><%= Lang.getString("select")%></span></a></td>
        </tr>
<%      newbackcolor = backcolor;
        backcolor = oldbackcolor; 
        oldbackcolor = newbackcolor;
        reportCount = reportCount + 1; 
		totalAmount = String.format("%.2f",java.lang.Float.parseFloat(PersFile.getTrim(totalAmount)) + java.lang.Float.parseFloat(PersFile.getTrim(recamt)));
     } while (Reg.myResult.next());
%>          
    <!--    <tr>
        <td width="10%"  colspan="3" <%=backcolor%> align="right"><strong>PAY TO:</strong></td>
        <td width="30%" colspan="3" <%=backcolor%> align="left"><strong><%= oldName%></strong></td>
        <td width="15%" <%=backcolor%> align="right"><strong>TOTAL:</strong></td>
        <td width="15%" <%=backcolor%> align="left"><strong><%= money.format(money.parse(totalAmount))%></strong></td>
        </tr>-->
<%  } catch (java.lang.Exception ex) {
    Log.println("[500] ReleaseList.jsp Language Error");
    Log.println("[500] ReleaseList.jsp - " + ex.toString());
    ex.printStackTrace();
%>
    <h1>Error in the SQL logic - contact support.<br></h1>
<%  
  } //try
  } // if(xFound)
%>
  </form>
<!--  <tr>
  <td width="5%" <%=backcolor%>></td>
  <td width="10%" <%=backcolor%>></td>
  <td width="10%" <%=backcolor%>></td>
  <td width="15%" <%=backcolor%>></td>
  <td width="15%" <%=backcolor%>></td>
  <td width="15%" <%=backcolor%>></td>
  <td width="15%" <%=backcolor%>></td>
  <td width="20%" <%=backcolor%> align="right">Reports:</td>
  <td width="10%" <%=backcolor%> align="right"><%= Integer.toString(reportCount) %></td>
  </tr>-->
  </table>

<%-- Below starts the forms for interaction --%>  
<br>           
<table border="0" cellpadding="2" cellspacing="0" width="90%" class="offsetColor" style="border: 1px solid"><tr>
<tr><td width="100%">
<form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ReleaseSave.jsp">
  <input type="hidden" name="email" value>
  <input type="hidden" name="company" value>
  <input type="hidden" name="database" value>
  <input type="hidden" name="voucher" value>
  <input type="hidden" name="reference" value>
  <input type="hidden" name="status" value>
  <input type="hidden" name="action" value="result">
  <input type="hidden" name="rcpt2" value="">
  <input type="hidden" name="reply2" value="">
  <input type="hidden" name="msgdata" value="">
  <input type="hidden" name="payment" value="">

   <table border="0" cellpadding="0" cellspacing="0" width="100%" height="38">
   <tr>
   <td width="100%" align="center">
     	<input type="button" value="<%= Lang.getString("butRelRepPro")%>" name="B2" onClick="Javascript: void Approve()">
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
    document.forms[1].company.value = parent.company;
    document.forms[1].database.value = parent.database;
    document.forms[1].status.value = "";
    document.forms[1].action.value = "result";
    document.forms[1].rcpt2.value = "";
    document.forms[1].reply2.value = "";
    document.forms[1].msgdata.value = "";
    document.forms[1].payment.value = "";
 }

 var submitSafetyFlag = true;
 function Approve(){

   var delim = "";
   if (submitSafetyFlag) {
     for (var i = 0; i < document.forms[0].length; i++) {
       if (document.forms[0].elements[i].name == "select_this_report" && document.forms[0].elements[i].checked == true) {
         //  document.forms[1].voucher.value += delim + document.forms[0].elements[i].voucher;
         document.forms[1].voucher.value += delim + parent.contents.getVoucherValue(document.forms[0].elements[i]);
         document.forms[1].status.value += delim + document.forms[0].elements[i].value;
         document.forms[1].payment.value += delim + document.forms[0].elements[i+1].value;
         delim = ";";   
       }
     }
     if (delim == ";") {
       document.forms[1].submit();
       submitSafetyFlag = false;
     } else {
       alert("Must check report(s) that you wish to release");
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
<%
} else { %>
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 
Log.println("[000] Releaselist.jsp - selection finished for " + ownersName);
%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>
<%@ include file="LimitRequired.jsp" %>
<%@ include file="DupSigner.jsp" %>
<%@ include file="DepartRouteRule.jsp" %>



