<%--
ReportList.jsp - List reports in the central database for editing, viewing or removal
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
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" /> 
<jsp:useBean id = "SendInfo"
     class="ess.ServerSystemTable"
     scope="page" />
<jsp:useBean id = "TableDOM"
     class="ess.AdisoftDOM"
     scope="page" />

<%@ include file="SystemInfo.jsp" %>
<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="NumericSetup.jsp" %>
<%@ include file="edit/EditInfo.jsp" %>
<% 
Log.println("[000] ReportAuditList.jsp started");
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
Reg.setConnection(PersFile.getConnection()); 
%>
<%@ include file="StatusInfo.jsp" %>
<%
Log.println("[000] ReportList.jsp 2");
%>
<%@ include file="../SendAnEmail.jsp" %>
<%
		String persnumber = request.getParameter("newLeavePer");
		String newLeaveFrom = request.getParameter("newLeaveFrom");
		String newLeaveTo = request.getParameter("newLeaveTo");
		String newLeaveTotal = request.getParameter("newLeaveTotal");
		String newLeaveReason = request.getParameter("newLeaveReason");
		String newLeaveLocation = request.getParameter("newLeaveLocation");
		newLeaveFrom = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(newLeaveFrom,PersFile.getDateFormat())));
		newLeaveTo = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(newLeaveTo,PersFile.getDateFormat())));
		String SQLCommand = "INSERT INTO leaveHolidays (HOLIDAY_NAME,HOLIDAY_FROM,HOLIDAY_TO,HOLIDAY_TOTAL,HOLIDAY_COMMENT,COMPANY) VALUES ('";
		SQLCommand += persnumber + "','";
		SQLCommand += newLeaveFrom + "','";
		SQLCommand += newLeaveTo + "','";
		SQLCommand += newLeaveTotal + "','";
		SQLCommand += newLeaveReason + "','";
		SQLCommand += newLeaveLocation + "'";
		SQLCommand += ")" + PersFile.getSQLTerminator();
		int SQLResult = Reg.doSQLExecute(SQLCommand);

%>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
<script type="text/javascript">
     if (screen.width < 1024) {
       var link = document.getElementsByTagName( "link" )[ 0 ];
       link.href = "<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense800.css";
     }
</script>     
<link rel="stylesheet" media="print" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/print.css" type="text/css">
	<style>
	td {
		padding: 10px;
	}
	</style>
	<title>New holiday created:</title>
     </head>
     <body>
		<p><big><em><strong><font face="Arial">New holiday created:</font></strong></em></big></p>
	<table border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span>Holiday name</span>: </font></strong></em></td>
      <td width="85%" align="left<span"><%= persnumber%></span></td>
    </tr>
    <tr>
      <td width="5%" align="right"><em><strong><font face="Arial"><span>From</span>: </font></strong></em></td>
      <td width="95%" align="left<span"><%= newLeaveFrom%></span></td>
    </tr>
    <tr>
      <td width="5%" align="right"><em><strong><font face="Arial"><span>To</span>: </font></strong></em></td>
      <td width="95%" align="left<span"><%= newLeaveTo%></span></td>
    </tr>
    <tr>
      <td width="5%" align="right"><em><strong><font face="Arial"><span>Total</span>: </font></strong></em></td>
      <td width="95%" align="left<span"><%= newLeaveTotal%></span></td>
    </tr>
    <tr>
      <td width="5%" align="right"><em><strong><font face="Arial"><span>Comments</span>: </font></strong></em></td>
      <td width="95%" align="left<span"><%= newLeaveReason%></span></td>
    </tr>
    <tr>
      <td width="5%" align="right"><em><strong><font face="Arial"><span>Location</span>: </font></strong></em></td>
      <td width="95%" align="left<span"><%= newLeaveLocation%></span></td>
    </tr>
  </table>

</body>
</html>

<% }else { %>
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 

%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>



