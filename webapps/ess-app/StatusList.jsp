<%--
StatusList.jsp - List the status (i.e., number of days since prenote) of prenoted items and allows clearing of the hold status
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
     scope="page" />
<%@ include file="../DBAccessInfo.jsp" %>
<% 
java.text.DecimalFormat money = new java.text.DecimalFormat("0.00");
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
<%@ include file="../SystemInfo.jsp" %>
<%
   Reg.setConnection(PersFile.getConnection()); 
   Reg.setSQLTerminator(PersFile.getSQLTerminator()); 
   
   Log.println("[000] StatusList.jsp - run by " + ownersName);

   String SQLCommand = SystemDOM.getDOMTableValueFor("achprenote","listsqlstatus","");
   
   if (SQLCommand.equals("")) {

     SQLCommand = "SELECT ";
     SQLCommand += "PERS_NUM, LNAME, FNAME, CASH, PRE_DATE, BANKCODE, BANKACCT FROM USER ";
     SQLCommand += "WHERE RTRIM(CASH) = 'VERIFYING' AND ACTIVE" + PersFile.getSQLTerminator();
   }

   boolean xFound = Reg.setResultSet(SQLCommand); %>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <meta http-equiv="Pragma" content="no-cache">
     <meta http-equiv="Expires" content="-1">

     <title>Prenote Selection:</title>
     <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     </head>
     <body onLoad="initForm()">
     <h1>OK prenotes for payment usage:</h1>
<%   String persnum;
     String persname;
     String paymentMethod;
     String predate;
     String bankcode;
     String bankacct;
     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
     String newbackcolor;
     String subTable;
     String depart;
     String recamt;   
     String checked;  

     java.util.Date today = new java.util.Date();
     java.util.Date cDate ;
     int difference_in_dates;

%>
 
     <script>
     //<%= SQLCommand %>//
     </script>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">

     <tr>
     <td width="5%" align="center"></td>
     <td width="10%" align="center"><u>Pers #</u></td>
     <td width="25%" align="center"><u>Name</u></td>
     <td width="15%" align="center"><u>Method</u></td>
     <td width="15%" align="center"><u>Prenote Date</u></td>
     <td width="15%" align="center"><u>Routing Code</u></td>
     <td width="15%" align="center"><u>Account</u></td>
     </tr>

     <form>
   
<% if (xFound) {
   try {
     do { 
        persnum = PersFile.getTrim(Reg.myResult.getString(1));
        persname = PersFile.getTrim(Reg.myResult.getString(2)) + " " + PersFile.getTrim(Reg.myResult.getString(3));
        paymentMethod = PersFile.getTrim(Reg.myResult.getString(4));
        predate = PersFile.getTrim(Reg.myResult.getString(5)); 
        bankcode = PersFile.getTrim(Reg.myResult.getString(6));
        bankacct = PersFile.getTrim(Reg.myResult.getString(7));        

        cDate = Dt.getDateFromXBase(predate);
        difference_in_dates = ess.Utilities.days(today,cDate); 
        if (difference_in_dates > 9) {
          checked = "checked";
        } else {
          checked = "";
        }     
%>          
        <tr>
        <td width="5%"  <%=backcolor%>><input type="checkbox" name="select_this_report" persnum="<%= persnum%>" <%= checked %>></td>
        <td width="10%" <%=backcolor%> align="center"><%= persnum%></td>
        <td width="25%" <%=backcolor%> align="center"><%= persname%></td>
        <td width="15%" <%=backcolor%> align="center"><%= paymentMethod%></td>
        <td width="15%" <%=backcolor%> align="center"><%= Dt.getSimpleDate(Dt.getDateFromXBase(predate))%></td>
        <td width="15%" <%=backcolor%> align="center"><%= bankcode%></td>
        <td width="15%" <%=backcolor%> align="center"><%= bankacct%></td>
        </tr>
<%      newbackcolor = backcolor;
        backcolor = oldbackcolor; 
        oldbackcolor = newbackcolor;
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] StatusList.jsp Language Error");
    Log.println("[500] StatusList.jsp - " + ex.toString());
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
<%= SystemDOM.getDOMTableValueFor("achprenote", "screenmessagestatus") %>
</div>                  
<table border="0" cellpadding="2" cellspacing="0" width="90%" class="offsetColor" style="border: 1px solid"><tr>
<tr><td width="100%">
<form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/nacha/StatusSave.jsp">
  <input type="hidden" name="email" value>
  <input type="hidden" name="company" value>
  <input type="hidden" name="database" value>
  <input type="hidden" name="prenote" value>
  <input type="hidden" name="action" value="result">
  <input type="hidden" name="rcpt2" value="">
  <input type="hidden" name="reply2" value="">
  <input type="hidden" name="msgdata" value="">

   <table border="0" cellpadding="0" cellspacing="0" width="100%" height="38">
   <tr>
   <td width="100%" align="center">
     <input type="button" value="Allow checked users to be paid with prenoted information" name="B2" onClick="Javascript: void Approve()">
   </td>
   </tr> 
   </table>
</form>
</td></tr>
</table>

<script language="Javascript">

  function initForm() {
    document.forms[1].name.value = parent.frames[1].getDBValue(parent.Header,"name");
    //reference was here
    document.forms[1].prenote.value = "";
    document.forms[1].email.value = parent.frames[1].getDBValue(parent.Header,"email");
    document.forms[1].company.value = parent.company;
    document.forms[1].database.value = parent.database;
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
         document.forms[1].prenote.value += delim + document.forms[0].elements[i].persnum;
         delim = ";";   
       }
     }
     if (delim == ";") {
       document.forms[1].submit();
       submitSafetyFlag = false;
     } else {
       alert("Must check user(s) that you wish to prenote");
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
  <%@ include file="../ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 
Log.println("[000] StatusList.jsp - selection finished for " + ownersName);
%>




