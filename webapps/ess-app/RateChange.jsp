<%--
RateChange.jsp - Prints out a conversion form if required - used by AuditReport.jsp
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
<jsp:useBean id = "SystemDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "SysTable"
     class="ess.ServerSystemTable"
     scope="page" />
<jsp:useBean id = "ESS"
     class="ess.DB2Audit"
     scope="session" />
<jsp:useBean id = "Currency"
     class="ess.Currency"
     scope="session" />
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="page" />    


<%@ include file="DBAccessInfo.jsp" %>

<%

String securityContext3 = config.getServletContext().getInitParameter("ESSSecurity"); //JH 9-19-2003
if (securityContext3 == null) securityContext3 = "APPLICATION";

String ownersName = request.getParameter("email");
String CCode = "";
String NeedPassword = "NO";

boolean pFlag = PersFile.setPersInfo(ownersName); 

if (pFlag) {
   SysTable.setConnection(PersFile.getConnection());   //SystemInfo.jsp handled differently here
   SysTable.setSQLTerminator(PersFile.getSQLTerminator());
   if (!SystemDOM.getDOMProcessed()) {
     String system_file = SysTable.getSystemString("XMLSYSTEM","C:\\WORK\\"); 
     java.io.File SystemFile = new java.io.File(system_file);
     SystemDOM.setDOM(SystemFile);
   }
   NeedPassword = SystemDOM.getDOMTableValueFor("configuration", "pwd_approval","yes");

   if(PersFile.getChallengeCode().equals("")) {
     PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
   }
   CCode = request.getParameter("ccode"); 
}

if (pFlag  && PersFile.active.equals("1") && PersFile.getChallengeCode().equals(CCode)) { 

%>
  <%@ include file="StatusInfo.jsp" %>
  <%@ include file="DepartInfo.jsp" %>
<%

  session.putValue("loginAttempts", new java.lang.Integer(0));

  String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
  String database = request.getParameter("database");

  String status = SystemDOM.getDOMTableValueFor("configuration","historycopy","ST_HISTORY");
  String physicalStatus = StatusDOM.getDOMTableValueWhere("default","status",status,"translation");
  String signerColumn = StatusDOM.getDOMTableValueWhere("default","status",status,"updatesqlsigner"); 
  String dateColumn = StatusDOM.getDOMTableValueWhere("default","status",status,"updatesqldate");

  String voucher = request.getParameter("voucher");

  Reg.setConnection(PersFile.getConnection()); 
  Reg.setSQLTerminator(PersFile.getSQLTerminator());

  if (ESS.isSameReport(voucher)) {

     String originalStatus = ESS.getReportStatus();
     String originalVoucher = ESS.getVoucherNumber();
     ESS.setReportStatus(physicalStatus);

     String newAsOfDate = Dt.xBaseDate.format(Dt.date);
     String SQLDate = SystemDOM.getDOMTableValueFor("sql","datesql");
     String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");

     if (SQLType.equalsIgnoreCase("MM/DD/YYYY")) { 
       SQLDate = Reg.SQLReplace(SQLDate,"$date$",Dt.getSimpleDate(Dt.date));
     } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
       SQLDate = Reg.SQLReplace(SQLDate,"$date$",Dt.getOracleDate(Dt.date));
     } else { //generate YYYY-MM-DD
       SQLDate = Reg.SQLReplace(SQLDate,"$date$",newAsOfDate);
     } 

     String SQLCommand = "UPDATE REPORT SET ";
     SQLCommand += "RP_STAT = '"+ physicalStatus + "', ";  //if adding signer need to add comma
     SQLCommand += signerColumn + " = '"+ PersFile.persnum + "', ";
     SQLCommand += dateColumn + " = " + SQLDate + " ";
     SQLCommand += "WHERE VOUCHER = '" + originalVoucher + "'" + PersFile.getSQLTerminator();

     int updateStatus = Reg.doSQLExecute(SQLCommand);

     // boolean updateStatus = ESS.setUpdate((ess.ReportElementAPI) ESS.getReportObject(), "REPORT");
     if (updateStatus == 1)  //should find one record.
     {
        ESS.setReportStatus(originalStatus);
        ESS.setHistory(originalVoucher);
        String xrate = request.getParameter("xrate");
        String ratedivisor = request.getParameter("ratedivisor");
        String xdate = request.getParameter("xdate");
        String xsource = request.getParameter("xsource");
        if (ESS.setConvertReport(xrate, ratedivisor, xdate, xsource))
        {
           ESS.setPersistance();
           if (ESS.isPersistanceOK())
           {

%>
<HTML>
<%= ESS.getVoucherNumber() %> has been created based on <%= voucher %> (<%= status %>,<%= physicalStatus %>).
<script>
parent.contents.setNameValue(parent.PersDBase,"last_report","<%= ESS.getVoucherNumber() %>");
setTimeout("parent.banner.Memory()",2000);
</script>
</HTML>
<% 
           } else { //persistance OK
Log.println("[500] RateChange.jsp - persistance failure on new report: " + ESS.getVoucherNumber() + ".");
%>
<HTML>
Failed to save new voucher <%= ESS.getVoucherNumber() %>.  Contact support.
</HTML>
<%
           }   //persistance OK 
        } else {  //convert OK
%>
<HTML>
No receipts were converted.
</HTML>
<% 

        } //convert OK

      } else { // header write OK
Log.println("[500] RateChange.jsp - Header update failed.");
%>
<HTML>
Information for report <%= voucher %> was not updated correctly.  Try again.  If problem persists contact support.
</HTML>
<% 
      } // header write
   } else {  // same report
Log.println("[400] RateChange.jsp - back button navigation error.");
%>
<HTML>
<%= voucher %> is not the current report. <%= voucher %> is the current report being processed.
<br>In the future, please avoid the use of the back button to navigate.
</HTML>
<% 

   } //same report

   
} else { 

   java.lang.Integer xLoginTrys = (java.lang.Integer) session.getValue("loginAttempts");
   java.lang.Integer loginAttempts = new java.lang.Integer(4);
   if (xLoginTrys != null) {
      loginAttempts = xLoginTrys;
   }
   int numTrys;
   numTrys = loginAttempts.intValue() + 1;
   if (numTrys > 3 || securityContext3.equalsIgnoreCase("HOST")) {
     Log.println("[400] AuditSave.jsp Invalid password (3X) for " + ownersName); %>
     <%@ include file="ReloginRedirectMsg.jsp" %>
<% } else {
      session.putValue("loginAttempts", new java.lang.Integer(numTrys));
%>
     <%@ include file="InvalidPasswordMsg.jsp" %>
<% } 

}
%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>
<%@ include file="LimitRequired.jsp" %>
<%@ include file="DupSigner.jsp" %>
<%@ include file="NotAuditor.jsp" %>
<%@ include file="SendAnEmail.jsp" %>
<%@ include file="DepartRouteRule.jsp" %>
<%@ include file="ReceiptCheckUpdate.jsp" %>


