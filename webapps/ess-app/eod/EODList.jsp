<%--
EODList.jsp - list reports for the EOD process that match the selected EOD date
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
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
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
%>
<%@ include file="../StatusInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>
<%@ include file="../DepartInfo.jsp" %>
<%
   Reg.setConnection(PersFile.getConnection()); 
   Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

   Log.println("[000] EODList.jsp - Send message access for " + ownersName);

   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);

   String DateStr = request.getParameter("update");
   if (DateStr == null || DateStr.equals("")) DateStr = Dt.getStrFromDate(Dt.date, PersFile.getDateFormat()); 

   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   String DateSQL = Dt.getSQLDate(Dt.getDateFromStr(DateStr, PersFile.getDateFormat()));

   String DateXB;
   if (SQLType.equalsIgnoreCase("MM/DD/YYYY")) { 
     DateXB = DateStr;
   } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
     DateXB = Dt.getOracleDate(Dt.getDateFromStr(DateStr));
   } else {    // s/b YYYY-MM-DD
     DateXB = DateSQL;
   }

   String SQLCommand = SystemDOM.getDOMTableValueFor("endofday","listsql","");
   
   if (SQLCommand.equals("")) {
      SQLCommand = "SELECT ";
      SQLCommand += "NAME, PERS_NUM, RE_AMT, RP_STAT, ";
      SQLCommand += "CUR_DATE, UP_DATE, VOUCHER, PVOUCHER, DEPART ";
      SQLCommand += "FROM REPORT ";
      SQLCommand += "WHERE UP_DATE = CTOD('$update$') ";
      SQLCommand += "ORDER BY VOUCHER" + PersFile.getSQLTerminator();
   }

   SQLCommand = Reg.SQLReplace(SQLCommand,"$update$",DateXB);

   boolean xFound = Reg.setResultSet(SQLCommand); %>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <meta http-equiv="Pragma" content="no-cache">
     <meta http-equiv="Expires" content="-1">

     <title>EOD Selection:</title>
     <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     </head>
     <body onLoad="initForm()">
     <h1>These reports will be included in the feed creation process:</h1>
<%   String persname;
     byte[] bArray;    //used for encrypted values
     String E;         //     ditto
     String voucher;
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

     int reportCount = 0;
%>
 
     <script>
     //<%= SQLCommand %>//
     </script>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
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
        repStat = PersFile.getTrim(Reg.myResult.getString(4));  
        reference = PersFile.getTrim(Reg.myResult.getString(2));
        curdate = PersFile.getTrim(Reg.myResult.getString(5)); 
        repamt = PersFile.getTrim(Reg.myResult.getString(3)); 
        voucher = PersFile.getTrim(Reg.myResult.getString(7));
        depart = PersFile.getTrim(Reg.myResult.getString(9));

        subTable = getRoutingRuleName(DepartDOM, depart, PersFile.depart, Log);
        repDBStat = StatXlation(repStat, CompanyName, StatusDOM);
        reportCount = reportCount + 1;
        Log.println("[305] EODList.jsp - voucher listed: " + voucher + " (" + repStat + ") #" + Integer.toString(reportCount));
%>          
        <tr>
        <input type="hidden" name="select_this_report" voucher="<%= voucher%>" value="<%= repStat%>">
        <td width="15%" <%=backcolor%> align="center"><%= voucher%></td>
        <td width="15%" <%=backcolor%>><%= Dt.getStrFromDate(Dt.getDateFromXBase(curdate), PersFile.getDateFormat())%></td>
        <td width="25%" <%=backcolor%> align="center"><%= persname%></td>
        <td width="15%" <%=backcolor%> align="center"><%= money.format(money.parse(repamt))%></td>
        <td width="30%" <%=backcolor%>><%= repDBStat%></td>
        </tr>
<%      newbackcolor = backcolor;
        backcolor = oldbackcolor; 
        oldbackcolor = newbackcolor;
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] EODList.jsp Language Error");
    Log.println("[500] EODList.jsp - " + ex.toString());
    ex.printStackTrace();
%>
    <h1>Error in the SQL logic - contact support.<br></h1>
<%  
  } //try
  } // if(xFound)
%>
  </form>
  <tr>
  <td width="15%" <%=backcolor%> align="center"></td>
  <td width="15%" <%=backcolor%> align="center"></td>
  <td width="25%" <%=backcolor%> align="center"></td>
  <td width="15%" <%=backcolor%> align="center">Reports:</td>
  <td width="30%" <%=backcolor%> align="right"><%= Integer.toString(reportCount) %></td>
  </tr>
  </table>

<%-- Below starts the forms for interaction --%>  
<br>
<div class="Expensetag">
<%-- was sendmessages.EODListMsg --%>
<%= SystemDOM.getDOMTableValueFor("endofday", "screenmessage") %>
</div>                  
<table border="0" cellpadding="2" cellspacing="0" width="90%" class="offsetColor" style="border: 1px solid"><tr>
<tr><td width="100%">
<form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/eod/EODLaunch.jsp">
  <!-- Was EODSave.jsp now EODLaunch.jsp -->
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

   <table border="0" cellpadding="0" cellspacing="0" width="100%" height="38">
   <tr>
   <td width="100%" align="center">
     <input type="button" value="Create feeds for these reports" name="B2" onClick="Javascript: void Approve()">
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
 }

 var submitSafetyFlag = true;  
 function Approve(){
   // forms[1].B2.disabled = true;
   if (submitSafetyFlag) {
     submitSafetyFlag = false;
     var delim = "";
     document.forms[1].voucher.value = "";
     document.forms[1].status.value = "";
     if (confirm("'OK' to create feeds. 'Cancel' to abort process.")) {
    	 for (var i = 0; i < document.forms[0].length; i++) {
    		 if (document.forms[0].elements[i].name == "select_this_report") {
    			 document.forms[1].voucher.value += delim + getVoucherValue(document.forms[0].elements[i]);
    			 document.forms[1].status.value += delim + document.forms[0].elements[i].value;
    			 delim = ";";   
    		 }
    	 }
    	 if (delim == ";") {
            document.forms[1].submit();
    	 } else {
    		 alert("Cannot process without any reports");
    		 submitSafetyFlag = true;
    	 }
     } else {
         submitSafetyFlag = true;
     }
   }
   // forms[1].B2.disabled = false;
 }

 function getVoucherValue(eleObj) {
   var retVal = "";
   if (navigator.appVersion.indexOf("MSIE") > -1) {
     if (eleObj.voucher) retVal = eleObj.voucher;
   } else if (navigator.userAgent.indexOf("Mozilla") > -1) {
     if (eleObj.attributes.getNamedItem("voucher")) retVal = eleObj.attributes.getNamedItem("voucher").value;
   } else {
     alert("Invalid Browser is being used.  You should use either\nMS IE or a Mozilla-based browser.");
   }
   return retVal;
 } 

  </script>
  <script LANGUAGE="JavaScript" SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.js"></script>

  <form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/eod/EODList.jsp"">
    <h2>Batch update date:&nbsp;
    <input type="text" name="update" size="12" value="<%=DateStr%>"> 
    <a HREF="javascript:doNothing()" tabindex="2" onClick="setDateField(document.forms[2].update,'<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.html')"><img SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.gif" BORDER="0" WIDTH="16" HEIGHT="16"></a>
    <input type="button" value="Select batch" name="B1" onClick="Javascript: void SubmitBatch()"></h2>
    <input type="hidden" name="email" value>
    <input type="hidden" name="database" value>
    <input type="hidden" name="ccode" value>
  </form>
  <script language=JavaScript>
  function SubmitBatch() {
    with(document.forms[2]) {
       email.value = parent.contents.getNameValue(parent.contents.Header, "email");
       database.value = parent.database;
       ccode.value = parent.CCode;
       submit();  
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
  <%@ include file="../ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 
Log.println("[000] EODList.jsp - Message list finished for " + ownersName);
%>
<%@ include file="../UnScramble.jsp" %>
<%@ include file="../StatXlation.jsp" %>
<%@ include file="../LimitRequired.jsp" %>
<%@ include file="../DupSigner.jsp" %>
<%@ include file="../DepartRouteRule.jsp" %>



