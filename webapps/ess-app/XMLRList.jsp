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
	Reg.setConnection(PersFile.getConnection()); 
   %>
   <%@ include file="../SystemInfo.jsp" %>
   <%@ include file="../StatusInfo.jsp" %>
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
 
   SQLCommand = SystemDOM.getDOMTableValueFor("registertable","attention",SQLCommand);
   if (SQLCommand != null && !SQLCommand.equals("")) {
      SQLCommand = Reg.SQLReplace(SQLCommand,"$owner$",Reg.repStr(ownersName.toUpperCase()));
   } 
  
   Log.println("[000] XMLRList.jsp SQL Start");
   if (Reg.setResultSet(SQLCommand)) { 
     Log.println("[000] XMLRList.jsp SQL Finish"); 
%>
     <h1><%= Lang.getLabel("REPORTS_BEING_PROCESSED") %></h1><br>
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
     <table cellspacing="0" cellpadding="0" id="processingTable">
     <thead>
         <tr>
             <th width="5%"  <%=backcolor%>></th> 
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("reportUserReference") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("date") %></th>
             <th width="25%" <%=backcolor%>><%= Lang.getColumnTitle("description") %></th>
             <th width="15%" <%=backcolor%>><%= Lang.getColumnTitle("localStatus") %></th>
             <th width="8%" <%=backcolor%>><%= Lang.getColumnTitle("amount") %></th>
             <th width="16%" <%=backcolor%>><%= Lang.getColumnTitle("paymentStatus") %></th>
             <th width="6%" <%=backcolor%>></th>
     	</tr>
     </thead>

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
                   Log.println("[500] XMLRList.jsp error (1): " + ex.toString());
                   Log.println("[500] XMLRList.jsp reportdate (1): " + reportdate);
                   Log.println("[500] XMLRList.jsp reportdate (1): " + reporttime);
                   Log.println("[500] XMLRList.jsp workdate (1): " + workdate);
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
                Log.println("[500] XMLRList.jsp error (2): " + ex.toString());
                Log.println("[500] XMLRList.jsp workdate (2): " + workdate);
                Log.println("[500] XMLRList.jsp reportdate (2): " + reportdate);
                ex.printStackTrace();
                reportdate = "";
            }

        } 
		if(!Lang.getDataTranslation(status).equals("Sent") || Lang.getDataString(repDBStat).equals("Rejected"))
        if (repStat == null || AlwaysShowReport(repStat) || !reference.equals(oldReference)) { %>
          <tr>
          <td width="5%"  <%=backcolor%>><input type="checkbox" name="select_this_report" reference="<%= reference%>" value="<%= status%>"></td> 
          <td width="10%" <%=backcolor%>><%= reference%></td>
          <td width="10%" <%=backcolor%>><%= Dt.getUserDateStr(reportdate,PersFile.getDateFormat())%></td>
          <td width="25%" <%=backcolor%>><%= descrip%></td>
          <td width="15%" <%=backcolor%>><%= Lang.getDataTranslation(status)%></td>
          <td width="8%" <%=backcolor%>><%= rcAmount%>&nbsp;</td>
          <td width="16%" <%=backcolor%>><%= Lang.getDataString(repDBStat) %>&nbsp;</td>
     <%   if (reference.equals(oldReference)) {     %>
            <td width="6%" <%=backcolor%>>&nbsp;</td>
     <%   } else {  %>
            <td width="6%" <%=backcolor%>><a href="JavaScript: void parent.NewieIfNotSaved('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ajax/getReport.jsp?email=<%= ownersName%>&reference=<%= reference.trim()%>&ccode=<%= CCode%>&status=<%= status%>&edit=<%= repEdit%>&database=<%= database%>')"><span class="ExpenseReturnLink"><%= Lang.getString("select") %></span></a></td>
     <%   }         %>
          </tr>

     <%   newbackcolor = backcolor;
          backcolor = oldbackcolor; 
          oldbackcolor = newbackcolor;
          oldReference = reference;
        }
      } //status check
    } while (Reg.myResult.next());
    Log.println("[000] XMLRList.jsp Display Finish"); 
%>
      </table>
      </form>
      <!-- <form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/parameterList.jsp"> -->
	<form method="POST">
		<input type="hidden" name="email" value>
		<input type="hidden" name="database" value>
		<input type="hidden" name="company" value>
		<input type="hidden" name="ccode" value>
		<input type="hidden" name="reference" value>
		<input type="hidden" name="status" value>
		<input type="hidden" name="action" value="remove">

		<input id="btRemove" type="button" value="<%= Lang.getButton("remove") %>" name="B1"onClick="Javascript: void Remove()">
	</form>

      <script language="Javascript" id="script" file="shared/XMLRList.js" ></script>

<%
  } catch (java.lang.Exception ex) {
      Log.println("[500] XMLRList.jsp Error in the result set");
      Log.println("[500] XMLRList.jsp " + ex.toString());
      ex.printStackTrace();
%>
     <br><big><strong><%= Lang.getString("ERROR_INVALID_DATA_RETURNED") %><br>
     <%= Lang.getString("ERROR_IF_PERSISTS") %></strong></big>
     <script language="Javascript">
      function initForm() {
      }
<%
  }
%>
<% } else { 
    
     CreateRegister(PersFile,Log);
%>

     <%= Lang.getString("NO_REPORTS_MESSAGE") %>
  
<%  //Logic for checking on the existence of the users personal data (xmlu). 

   } 

   Reg.closeMyState();  //closing the above SQL statement

} else { 
      Log.println("[000] XMLRList.jsp Relogin request"); %>
 <%@ include file="ReloginRedirectMsg.jsp" %>
<%
}
%>

<%@ include file="../CreateRegister.jsp" %>
<%@ include file="../StatXlation.jsp" %>
<%@ include file="../StatEditable.jsp" %>

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

