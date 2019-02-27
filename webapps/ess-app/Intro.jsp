<%--
Intro.jsp - if no reports in register, it displays welcome message, otherwise displays users reports 
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
<!-- <%@ page isThreadSafe="false" %> 
Consider this and then letting the
Reg bean below having a session scope
-->
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="page" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="NumericSetup.jsp" %>
<% 

String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String CCode = "";
String database = request.getParameter("database");
String ownersName = request.getParameter("email");

   //String dummy = request.getParameter("dummy");
   //Log.println("[---] Intro.jsp dummy: " + dummy);
   //Log.println("[---] Intro.jsp database: " + database);
   //Log.println("[---] Intro.jsp email: " + ownersName);
   //Log.println("[---] Intro.jsp ip: " + request.getRemoteAddr());
   //Log.println("[---] Intro.jsp session ID: " + session.getId());

boolean pFlag = PersFile.setPersInfo(ownersName); 
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
}

if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
   Reg.setConnection(PersFile.getConnection()); 
   %>
   <%@ include file="SystemInfo.jsp" %>
   <%@ include file="StatusInfo.jsp" %>
   <%
   String persnumber = PersFile.persnum.toUpperCase(); 
   String SQLCommand = "SELECT ";
   SQLCommand += "REGISTER.STATUS, REGISTER.REFERENCE, REGISTER.MESSAGE, REPORT.RP_STAT, ";
   SQLCommand += "REPORT.ACT_DATE, REPORT.ACT_TIME, REGISTER.REPDATE, REPORT.PERS_NUM, REPORT.RC_AMT ";
   SQLCommand += "FROM REGISTER LEFT JOIN REPORT ON RTRIM(REGISTER.THEIR_REF) = RTRIM(REPORT.VOUCHER) ";
   SQLCommand += "AND RTRIM(REPORT.VOUCHER) <> '' ";
   SQLCommand += "WHERE RTRIM(REGISTER.OWNER) = '" + Reg.repStr(ownersName.toUpperCase()) + "' "; 
   SQLCommand += "AND RTRIM(REGISTER.STATUS) <> 'Copy' AND RTRIM(REGISTER.STATUS) <> 'Remove' ";
   SQLCommand += "AND RTRIM(REGISTER.STATUS) <> 'Delete' AND RTRIM(REGISTER.STATUS) <> 'Problem' ";
   SQLCommand += "ORDER BY REGISTER.THEIR_REF DESC, REGISTER.XREF DESC" + PersFile.getSQLTerminator();
 
   SQLCommand = SystemDOM.getDOMTableValueFor("registertable","listreports",SQLCommand);
   if (SQLCommand != null && !SQLCommand.equals("")) {
      SQLCommand = Reg.SQLReplace(SQLCommand,"$owner$",Reg.repStr(ownersName.toUpperCase()));
   } 
  
   Log.println("[000] Intro.jsp SQL Start");
   if (Reg.setResultSet(SQLCommand)) { 
     Log.println("[000] Intro.jsp SQL Finish"); 
%>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <title>Report Selection:</title>
     <link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     <script type="text/javascript">
     if (screen.width < 1024) {
       var link = document.getElementsByTagName( "link" )[ 0 ];
       link.href = "<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense800.css";
     }
     </script>
     </head>
     <body onLoad="initForm()">
     <h1>These are your expense reports:</h1><br>
<%   String status; 
     String reference;
     String oldReference = "";
     String REPORT_PERS_NUM;
     String descrip;
     String repStat;
     String repEdit;
     String repDBStat;
     String reportdate = null;
     String workdate = null;
     String reporttime = null;
     String rcAmount;
     String backcolor = "class=\"TableData OffsetColor\"";
     String oldbackcolor = "class=\"TableData\"";
     String newbackcolor; %>

     <script>
     //<%= SQLCommand %>//
     </script>
     <form>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
     <tr>
     <td width="5%"  <%=backcolor%>></td> 
     <td width="10%" <%=backcolor%>><u>Your #</u></td>
     <td width="15%" <%=backcolor%>><u>Date</u></td>
     <td width="30%" <%=backcolor%>><u>Description</u></td>
     <td width="10%" <%=backcolor%>><u>Local Status</u></td>
     <td width="10%" <%=backcolor%>><u>Report Amount</u></td>
     <td width="20%" <%=backcolor%>><u>Payment Status</u></td>
     <td width="10%" <%=backcolor%>></td>
     </tr>

<%   try {

     newbackcolor = backcolor;
     backcolor = oldbackcolor; 
     oldbackcolor = newbackcolor;

     do { 
      status = PersFile.getTrim(Reg.myResult.getString(1));
      reference = PersFile.getTrim(Reg.myResult.getString(2));
      repStat = Reg.myResult.getString(4); 
      REPORT_PERS_NUM = PersFile.getTrim(Reg.myResult.getString(8));

      //Consider using remove.xml for the following  - remove.xml will replace status.xml !need new name!
      if (!status.equals("Copy") && !status.equals("Problem") && !status.equals("Remove")&& !status.equals("Delete") && !status.equals("")) {

      
        rcAmount = Reg.myResult.getString(9);
      
        if (rcAmount == null || rcAmount.equals("")  || repStat.equals("")) {
          rcAmount = "";
        } else {
          rcAmount = money.format(money.parse(rcAmount));
        }
        descrip = PersFile.getTrim(Reg.myResult.getString(3));
        if (descrip == null) descrip = "";
        repDBStat = StatXlation(repStat, CompanyName, StatusDOM);
        repEdit = StatEditable(repStat, CompanyName, StatusDOM);
        reportdate = PersFile.getTrim(Reg.myResult.getString(7));  //REGISTER.REPDATE
        if (reportdate == null || reportdate.equals("")) {
           reportdate = Reg.myResult.getString(5);   //REPORT.ACT_DATE
           if (reportdate == null || reportdate.equals("")) { 
               reportdate = "";
           } else {
               try {  //JH 2010-01-12
               //Dt.getSimpleDate(Dt.getDateFromXBase(actdate))
                   reporttime = Reg.myResult.getString(6);
                   workdate = Dt.getLongDateFromXBase(reportdate, reporttime).toGMTString();
               //reportdate = workdate;
                   reportdate = Dt.getSimpleDate(Dt.getDateFromGMTDate(workdate));
               } catch (java.lang.Exception ex) {
                   Log.println("[500] Intro.jsp error (1): " + ex.toString());
                   Log.println("[500] Intro.jsp reportdate (1): " + reportdate);
                   Log.println("[500] Intro.jsp reportdate (1): " + reporttime);
                   Log.println("[500] Intro.jsp workdate (1): " + workdate);
                   ex.printStackTrace();
                   reportdate = "";
               }
           }
        } else {
         //put a try and a catch here for a java.lang.NullPointerException
            try {  //JH 2010-01-12
               workdate = reportdate;
               reportdate = Dt.getSimpleDate(Dt.getDateFromGMTDate(workdate));
            } catch (java.lang.Exception ex) {
                Log.println("[500] Intro.jsp error (2): " + ex.toString());
                Log.println("[500] Intro.jsp workdate (2): " + workdate);
                Log.println("[500] Intro.jsp reportdate (2): " + reportdate);
                ex.printStackTrace();
                reportdate = "";
            }

        } 
        if (repStat == null || AlwaysShowReport(repStat) || !reference.equals(oldReference)) { %>
          <tr>
          <td width="5%"  <%=backcolor%>><input type="checkbox" name="select_this_report" reference="<%= reference%>" value="<%= status%>"></td> 
          <td width="10%" <%=backcolor%>><%= reference%></td>
          <td width="15%" <%=backcolor%>><%= reportdate%></td>
          <td width="30%" <%=backcolor%>><%= descrip%></td>
          <td width="10%" <%=backcolor%>><%= status%></td>
          <td width="10%" <%=backcolor%>><%= rcAmount%></td>
          <td width="20%" <%=backcolor%>><%= repDBStat%></td>
     <%   if (reference.equals(oldReference)) {     %>
            <td width="10%" <%=backcolor%>></td>
     <%   } else {  %>
            <td width="10%" <%=backcolor%>><a href="JavaScript: void parent.contents.NewieIfNotSaved('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/getReport.jsp?email=<%= ownersName%>&reference=<%= reference.trim()%>&ccode=<%= CCode%>&status=<%= status%>&edit=<%= repEdit%>&database=<%= database%>')"><span class="ExpenseReturnLink">Select</span></a></td>
     <%   }         %>
          </tr>

     <%   newbackcolor = backcolor;
          backcolor = oldbackcolor; 
          oldbackcolor = newbackcolor;
          oldReference = reference;
        }
      } //status check
    } while (Reg.myResult.next());
    Log.println("[000] Intro.jsp Display Finish"); 
%>
      </table>
      </form>
      <!-- <form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/parameterList.jsp"> -->
      <form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/RemoveSave.jsp">
        <input type="hidden" name="email" value>
        <input type="hidden" name="database" value>
        <input type="hidden" name="company" value>
        <input type="hidden" name="ccode" value>
        <input type="hidden" name="reference" value>
        <input type="hidden" name="status" value>
        <input type="hidden" name="action" value="remove">

      <p><input type="button" value="Remove" name="B1"onClick="Javascript: void Remove()">&nbsp; <span class="ExpenseTag">Click &quot;Remove&quot; to remove checked items from your list</span></p>
      </form>

      <script language="Javascript">

      function initForm() {
        if (parent.contents.getDBValue) {
          document.forms[1].name.value = parent.contents.getDBValue(parent.Header,"name");
          //reference was here
          document.forms[1].reference.value = "";
          document.forms[1].email.value = parent.contents.getDBValue(parent.Header,"email");
          document.forms[1].company.value = parent.company;
          document.forms[1].database.value = parent.database;
          document.forms[1].ccode.value = parent.CCode;
          document.forms[1].status.value = "";
          document.forms[1].action.value = "remove";
        } else {
          setTimeout("parent.main.initForm()",1000);
        }    
      }

      function Remove(){
        var delim = "";
        for (var i = 0; i < document.forms[0].length; i++) {
          if (document.forms[0].elements[i].name == "select_this_report" && document.forms[0].elements[i].checked == true) {
            //document.forms[1].reference.value += delim + document.forms[0].elements[i].reference;
            document.forms[1].reference.value += delim + getReferenceValue(document.forms[0].elements[i]); //jh 2010-01-05 from voucher
            document.forms[1].status.value += delim + document.forms[0].elements[i].value;
            delim = ";";   
          }
        }
        if (delim == ";") {
          if (confirm("Checked reports will be permanently removed from your list.  Is it 'OK' to proceed?")) {
            document.forms[1].submit();
          }
        } else {
          alert("Must check report(s) that you wish to remove");
        }
      }
      function getReferenceValue(eleObj) {
         var retVal = "";
         if (navigator.appVersion.indexOf("MSIE") > -1) {
             if (eleObj.reference) retVal = eleObj.reference;
         } else if (navigator.userAgent.indexOf("Mozilla") > -1) {
             if (eleObj.attributes.getNamedItem("reference")) retVal = eleObj.attributes.getNamedItem("reference").value;
         } else {
             alert("Invalid Browser is being used.  You should use either\nMS IE or a Mozilla-based browser.");
         }
         return retVal;
      } 
      </script>
<%
  } catch (java.lang.Exception ex) {
      Log.println("[500] Intro.jsp Error in the result set");
      Log.println("[500] Intro.jsp " + ex.toString());
      ex.printStackTrace();
%>
     <br><big><strong>Error in data returned by server - retry option<br>
     If problem persists - contact support!</strong></big>
     <script language="Javascript">
      function initForm() {
      }
     </script>
<%
  }
%>
  </body>
  </html>
<% } else { 
    
     CreateRegister(PersFile,Log);
%>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <title>Introduction Page</title>
     <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     </head>
     <!-- New user logic -->
     <!-- <%= SQLCommand %> -->
     <body>

     <%= SystemDOM.getDOMTableValueFor("messages", "introduction") %>
 
     </body>
     </html>
<%  //Logic for checking on the existence of the users personal data (xmlu). 

   } 

   Reg.closeMyState();  //closing the above SQL statement

} else { 
      Log.println("[000] Intro.jsp Relogin request"); %>
 <%@ include file="ReloginRedirectMsg.jsp" %>
<%
}
%>

<%@ include file="CreateRegister.jsp" %>
<%@ include file="StatXlation.jsp" %>
<%@ include file="StatEditable.jsp" %>

<%!
// This should be replaced with the Status.xml check
public boolean AlwaysShowReport(String StatusCode) {
  boolean retVal = false;
  if (StatusCode == null) retVal = true;
  if (StatusCode.equals("A0")) retVal = true;
  if (StatusCode.equals("B1")) retVal = true;
  if (StatusCode.equals("C1")) retVal = true;
  if (StatusCode.equals("D1")) retVal = true;
  if (StatusCode.equals("E2")) retVal = true;
  if (StatusCode.equals("G3")) retVal = true;
  if (StatusCode.equals("G4")) retVal = true;
  if (StatusCode.equals("G5")) retVal = true;
  if (StatusCode.equals("H4")) retVal = true;
  if (StatusCode.equals("L4")) retVal = true;
  return retVal;
}
%>

