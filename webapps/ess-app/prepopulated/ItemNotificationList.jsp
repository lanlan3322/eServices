<%--
DelinquentList.jsp - list out reports that should have been approved by now 
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
   
   Notify.setConnection(PersFile.getConnection()); 
   Notify.setSQLTerminator(PersFile.getSQLTerminator()); 
   Notify.setSQLStrings();
   
   Log.println("[000] ItemNotificationList.jsp - Sending messages by " + ownersName);

   String sendDaysStr = SystemDOM.getDOMTableValueFor("prepopulatedmessages","sendafterdays","7");
   int sendDays = Integer.parseInt(sendDaysStr);

   String DateStr = request.getParameter("update");
   java.util.Date nDate = new java.util.Date();     //holds escalate date
   if (DateStr == null || DateStr.equals("")) {
      Dt.date = Dt.addDays(Dt.date,sendDays * -1);
      DateStr = Dt.getSimpleDate(Dt.date);
   }
   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   String DateSQL = Dt.getSQLDate(Dt.getDateFromStr(DateStr));

   String DateXB;
   if (SQLType.equalsIgnoreCase("MM/DD/YYYY")) { 
     DateXB = DateStr;
   } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
     DateXB = Dt.getOracleDate(Dt.getDateFromStr(DateStr));
   } else {    // s/b YYYY-MM-DD
     DateXB = DateSQL;
   }

   String SQLCommand = SystemDOM.getDOMTableValueFor("prepopulatedmessages","messagelistsql","");
   
   if (SQLCommand.equals("")) {
     SQLCommand = "SELECT XREF, EMPLOYEE, CHARGE, CARD, TDATE,REFERENCE, AMOUNT, STATUS, SDATE, '' FROM STATEMNT WHERE STATUS = 'NW' AND TDATE &lt;= '$date$' ORDER BY EMPLOYEE" + PersFile.getSQLTerminator();
   }

   SQLCommand = Reg.SQLReplace(SQLCommand,"$date$",DateXB);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$update$",DateXB);  //deprecated

   boolean xFound = Reg.setResultSet(SQLCommand); %>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <meta http-equiv="Pragma" content="no-cache">
     <meta http-equiv="Expires" content="-1">

     <title>Message Selection:</title>
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
     <h1>Checked items will have an email notification sent:</h1>
     <h2>Cutoff date: <%= DateXB %></h2>
<%   String xref;
     String persname;
     String card;
	 String transdate; 
	 String reference;
	 String amount; 
	 String status;
	 String statedate;
	 java.util.Date sDate;
     String backcolor = "class=\"TableData offsetColor\"";
     String oldbackcolor = "class=\"TableData\"";
     String newbackcolor;
     String subTable;
     String email;     
%>
 
     <script>
     //<%= SQLCommand %>//
     </script>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">

     <tr>
     <td width="5%" align="center"></td>
     <td width="30%" align="center"><u>Employee</u></td>
     <td width="20%" align="center"><u>Card</u></td>
     <td width="15%" align="center"><u>Date</u></td>
     <td width="20%" align="center"><u>Reference</u></td>
     <td width="20%" align="center"><u>Amount</u></td>
     <td width="5%" align="center"><u>Status</u></td>
     </tr>

     <form>
   
<% if (xFound) {
   try {
     do { 
    	 
        xref = PersFile.getTrim(Reg.myResult.getString(1)); 
        persname = PersFile.getTrim(Reg.myResult.getString(2));
        card = PersFile.getTrim(Reg.myResult.getString(4));
        transdate = PersFile.getTrim(Reg.myResult.getString(5)); 
        reference = PersFile.getTrim(Reg.myResult.getString(6));
        amount = money.format(money.parse(PersFile.getTrim(Reg.myResult.getString(7))));
        status = PersFile.getTrim(Reg.myResult.getString(8));
        statedate = PersFile.getTrim(Reg.myResult.getString(9));
        email = PersFile.getTrim(Reg.myResult.getString(10)); 
   
        sDate = Dt.getDateFromXBase(statedate);

  %>          
        <tr>
        <td width="5%"  <%=backcolor%>><input type="checkbox" name="select_this_item" xref="<%= xref %>" status="<%= status %>" checked="Yes"></td>
        <td width="30%" <%=backcolor%> align="center"><%= persname%></td>
        <td width="20%" <%=backcolor%> align="center"><%= card %></td>
        <td width="15%" <%=backcolor%> align="center"><%= Dt.getSimpleDate(Dt.getDateFromXBase(transdate))%></td>
        <td width="20%" <%=backcolor%> align="center"><%= reference%></td>
        <td width="20%" <%=backcolor%> align="center"><%= amount %></td>
        <td width="5%" <%=backcolor%>><%= status %></td>
        </tr>
<%      newbackcolor = backcolor;
        backcolor = oldbackcolor; 
        oldbackcolor = newbackcolor;
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] ItemNotificationList.jsp Language Error");
    Log.println("[500] ItemNotificationList.jsp - " + ex.toString());
    ex.printStackTrace();
%>
    <h1>Error in the SQL logic - contact support.<br></h1>
<%  
  } //try
  } // if(xFound)
%>
  </form>
  </table>

<%-- Below starts the forms for interaction --%>  
<br>
<div class="Expensetag">
<%= SystemDOM.getDOMTableValueFor("prepopulatedmessages", "messagelistmsg") %>
</div>                  
<table border="0" cellpadding="2" cellspacing="0" width="90%" class="offsetColor" style="border: 1px solid"><tr>
<tr><td width="100%">
<form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/prepopulated/ItemNotificationSend.jsp">
  <input type="hidden" name="email" value>
  <input type="hidden" name="company" value>
  <input type="hidden" name="database" value>
  <input type="hidden" name="xref" value>
  <input type="hidden" name="reference" value>
  <input type="hidden" name="status" value>
  <input type="hidden" name="action" value="result">
  <input type="hidden" name="rcpt2" value="">
  <input type="hidden" name="reply2" value="">
  <input type="hidden" name="msgdata" value="">

   <table border="0" cellpadding="0" cellspacing="0" width="100%" height="38">
   <tr>
   <td width="100%" align="center">
     <input type="button" value="Send email messages for these items" name="B2" onClick="Javascript: void Approve()">
   </td>
   </tr> 
   </table>
</form>
</td></tr>
</table>

<script language="Javascript">

  function initForm() {
    document.forms[1].xref.value = "";
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
// check below logic on other browsers than IE???
   var delim = "";
   if (submitSafetyFlag) {
     for (var i = 0; i < document.forms[0].length; i++) {
       if (document.forms[0].elements[i].name == "select_this_item" && document.forms[0].elements[i].checked == true) {
         document.forms[1].xref.value += delim + document.forms[0].elements[i].xref;
         document.forms[1].status.value += delim + document.forms[0].elements[i].status;
         delim = ";";   
       }
     }
     if (delim == ";") {
        if (confirm("'OK' to send messages. 'Cancel' to abort approval.")) {
            document.forms[1].submit();
            submitSafetyFlag = false;
        }
     } else {
       alert("Must check items(s) that you wish to send");
     }
   }
 }

  </script>
  <script LANGUAGE="JavaScript" SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.js"></script>

  <form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/prepopulated/ItemNotificationList.jsp"">
    <h2>Cutoff date:&nbsp;
    <input type="text" name="update" size="12" value="<%=DateStr%>"> 
    <a HREF="javascript:doNothing()" tabindex="2" onClick="setDateField(document.forms[2].update,'<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.html')"><img SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.gif" BORDER="0" WIDTH="16" HEIGHT="16"></a>
    <input type="button" value="Select cutoff date" name="B1" onClick="Javascript: void SubmitBatch()"></h2>
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
Log.println("[000] ItemNotificationList - Message list finished for " + ownersName);
%>




