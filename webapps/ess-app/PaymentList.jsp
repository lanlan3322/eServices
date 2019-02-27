<%--
PaymentList.jsp - Approval follow-ups list - creates delinquent list
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
   
   Notify.setConnection(PersFile.getConnection()); 
   Notify.setSQLTerminator(PersFile.getSQLTerminator()); 
   Notify.setSQLStrings();
   
   Log.println("[000] Delinquentlist.jsp - Send message for " + ownersName);

   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);

   String resendDaysStr = SystemDOM.getDOMTableValueFor("delinquentmessages","resendafterdays","7");
   int resendDays = Integer.parseInt(resendDaysStr);

   String notifyDaysStr = SystemDOM.getDOMTableValueFor("delinquentmessages","notifymanagerdays","15");
   int notifyDays = Integer.parseInt(notifyDaysStr);

   String DateStr = request.getParameter("update");
   java.util.Date nDate = new java.util.Date();     //holds escalate date
   if (DateStr == null || DateStr.equals("")) {
      Dt.date = Dt.addDays(Dt.date,resendDays * -1);
      DateStr = Dt.getSimpleDate(Dt.date);
      nDate = Dt.addDays(Dt.date, -1 * (notifyDays - resendDays));
   } else { 
      nDate = Dt.addDays(Dt.date, -1 * (notifyDays - resendDays));
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

   String SelfNotifyStr = SystemDOM.getDOMTableValueFor("delinquentmessages","sendtoreporter","15");
   
   String SQLCommand = SystemDOM.getDOMTableValueFor("delinquentmessages","messagelistsql","");
   
   if (SQLCommand.equals("")) {
     SQLCommand = "SELECT ";
     SQLCommand += "NAME, PERS_NUM, RE_AMT, RP_STAT, CUR_DATE, ";
     SQLCommand += "SUB_DATE, VOUCHER, PVOUCHER, MANAGER, DEPART ";
     SQLCommand += "FROM REPORT ";
     SQLCommand += "WHERE ((RP_STAT = 'B1' OR RP_STAT = 'C1' OR RP_STAT = 'D1') ";
     SQLCommand += "AND CUR_DATE < CTOD('$update$')) ";
     SQLCommand += "OR RP_STAT = 'F1' ";
     SQLCommand += "ORDER BY RP_STAT ASC, VOUCHER ASC" + PersFile.getSQLTerminator();
   }

   SQLCommand = Reg.SQLReplace(SQLCommand,"$update$",DateXB);

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
     <h1>Checked reports will have approval notifications resent:</h1>
     <h2>Cutoff date: <%= DateXB %>, Escalate date: <%= Dt.getSimpleDate(nDate) %></h2>
<%   String persname;
     byte[] bArray;    //used for encrypted values
     String E;         //     ditto
     String voucher;
     String reference;
     String curdate;
     String repamt;
     String repStat;
     String repDBStat;
     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
     String newbackcolor;
     String subTable;
     String depart;
     String manager;     
     String routeto;
     String nextrouteto;
     String escalate = "N";
     java.util.Date cDate = new java.util.Date();
%>
 
     <script>
     //<%= SQLCommand %>//
     </script>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">

     <tr>
     <td width="5%" align="center"></td>
     <td width="10%" align="center"><u>Report</u></td>
     <td width="15%" align="center"><u>Last Submit</u></td>
     <td width="20%" align="center"><u>Reporter</u></td>
     <td width="20%" align="center"><u>Approver</u></td>
     <td width="20%" align="center"><u>Escalate</u></td>
     <td width="20%" align="center"><u>Status</u></td>
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
        manager = PersFile.getTrim(Reg.myResult.getString(9));        
        depart = PersFile.getTrim(Reg.myResult.getString(10));
 
        subTable = getRoutingRuleName(DepartDOM, depart, PersFile.depart, Log);
        repDBStat = StatXlation(repStat, CompanyName, StatusDOM);

        //if (SQLType.equals("MM/DD/YYYY")) { 
          cDate = Dt.getDateFromXBase(curdate);
        //} else {    // s/b YYYY-MM-DD
        // cDate = Dt.getDateFromSQL(curdate);
        //}

        escalate = "A";
        if (SelfNotifyStr.indexOf(";" + repStat + ";") > -1) {
           routeto = "";
           nextrouteto = "";
           escalate = "S";
        } else {
           if (Notify.setPersNumInfo(manager)) {    //might want to change to a dynamic routing
               routeto = Notify.setRightName(Notify.name);
               if ( cDate.before(nDate) ) {
               //if (true) {   
                  if (Notify.setPersNumInfo(Notify.getManager())) {
                    nextrouteto = Notify.setRightName(Notify.name);
                    escalate = "E";
                  } else {
                    nextrouteto = "";
                  }
               } else {
                  nextrouteto = "";
               }  
           } else {
             routeto = "";
             nextrouteto = "";
           } 
        }
%>          
        <tr>
        <td width="5%"  <%=backcolor%>><input type="checkbox" name="select_this_report" voucher="<%= voucher%>" value="<%= escalate%>" checked="Yes"></td>
        <td width="10%" <%=backcolor%> align="center"><%= voucher%></td>
        <td width="15%" <%=backcolor%> align="center"><%= Dt.getSimpleDate(Dt.getDateFromXBase(curdate))%></td>
        <td width="20%" <%=backcolor%> align="center"><%= persname%></td>
        <td width="20%" <%=backcolor%> align="center"><%= routeto%></td>
        <td width="20%" <%=backcolor%> align="center"><%= nextrouteto%></td>
        <td width="20%" <%=backcolor%>><%= repDBStat%></td>
        </tr>
<%      newbackcolor = backcolor;
        backcolor = oldbackcolor; 
        oldbackcolor = newbackcolor;
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] DelinquentList.jsp Language Error");
    Log.println("[500] DelinquentList.jsp - " + ex.toString());
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
<%= SystemDOM.getDOMTableValueFor("delinquentmessages", "messagelistmsg") %>
</div>                  
<table border="0" cellpadding="2" cellspacing="0" width="90%" class="offsetColor" style="border: 1px solid"><tr>
<tr><td width="100%">
<form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/DelinquentSend.jsp">
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
     <input type="button" value="Send automatic followup email messages for these reports" name="B2" onClick="Javascript: void Approve()">
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

   var delim = "";
   if (submitSafetyFlag) {
     for (var i = 0; i < document.forms[0].length; i++) {
       if (document.forms[0].elements[i].name == "select_this_report" && document.forms[0].elements[i].checked == true) {
         document.forms[1].voucher.value += delim + document.forms[0].elements[i].voucher;
         document.forms[1].status.value += delim + document.forms[0].elements[i].value;
         delim = ";";   
       }
     }
     if (delim == ";") {
        if (confirm("'OK' to send messages. 'Cancel' to abort approval.")) {
            document.forms[1].submit();
            submitSafetyFlag = false;
        }
     } else {
       alert("Must check report(s) that you wish to send");
     }
   }
 }

  </script>
  <script LANGUAGE="JavaScript" SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.js"></script>

  <form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/DelinquentList.jsp"">
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
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 
Log.println("[000] Messagelist.jsp - Message list finished for " + ownersName);
%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>
<%@ include file="LimitRequired.jsp" %>
<%@ include file="DupSigner.jsp" %>
<%@ include file="DepartRouteRule.jsp" %>



