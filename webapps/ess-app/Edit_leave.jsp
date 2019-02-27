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
<jsp:useBean id = "Reg3"
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

<%@ include file="SystemInfo.jsp" %>
<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="NumericSetup.jsp" %>
<% 
Log.println("[000] ReportAuditList.jsp started");
String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String CCode = "";
String database = request.getParameter("database");
String action = request.getParameter("xaction");
int SQLResult = 0;
String sTitle = "Following leave updated:";
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
	Reg2.setConnection(PersFile.getConnection()); 
	Reg3.setConnection(PersFile.getConnection()); 

%>
<%@ include file="StatusInfo.jsp" %>
<%
Log.println("[000] ReportList.jsp 2");
%>
<%@ include file="../SendAnEmail.jsp" %>
<%
		String persnumber = request.getParameter("newLeavePer");
		String newLeaveStatus = request.getParameter("newLeaveStatus");
		String newLeaveNum = request.getParameter("newLeaveNum");
		String newLeaveType = request.getParameter("newLeaveType");
		String oldLeaveType = request.getParameter("oldLeaveType");
		String newLeaveFrom = request.getParameter("newLeaveFrom");
		String newLeaveFromAMPM = request.getParameter("newLeaveFromAMPM");
		String newLeaveTo = request.getParameter("newLeaveTo");
		String newLeaveToAMPM = request.getParameter("newLeaveToAMPM");
		String newLeaveTotal = request.getParameter("newLeaveTotal");
		String newLeaveReason = request.getParameter("newLeaveReason");
		String newLeaveReasonSQL = newLeaveReason.replaceAll("'","\\\\'");
		String SQLCommand = "UPDATE LEAVERECORD SET LEAVE_REASON = '" + newLeaveReasonSQL + "'";
		if(action.equals("DELETE")){
			sTitle = "Following leave deleted:";
			SQLCommand = "DELETE FROM LEAVERECORD WHERE LEAVE_NUM = '" + newLeaveNum + "'" + PersFile.getSQLTerminator();
			SQLResult = Reg.doSQLExecute(SQLCommand);
Log.println("[000] ReportAuditList.jsp sql: " + SQLCommand);
		}
		else{
		   if (newLeaveFrom != null && !newLeaveFrom.equals("")) newLeaveFrom = Dt.getSQLDate(Dt.getDateFromStr(newLeaveFrom,PersFile.getDateFormat()));
		   if (newLeaveTo != null && !newLeaveTo.equals("")) newLeaveTo = Dt.getSQLDate(Dt.getDateFromStr(newLeaveTo,PersFile.getDateFormat()));

			String SQLCommand4 = "SELECT " + oldLeaveType + "_BAL FROM LEAVEINFO WHERE PERS_NUM = '" + persnumber + "'" + PersFile.getSQLTerminator();
			String oldAnnual = "0";
			String newAnnual = "0";
			float oldValue = 0;
			float newValue = 0;
			if (Reg2.setResultSet(SQLCommand4)) {
				oldAnnual = PersFile.getTrim(Reg2.myResult.getString(1));
				newValue = Float.parseFloat(oldAnnual) + Float.parseFloat(newLeaveTotal);
			}
			newAnnual = String.valueOf(newValue);
			boolean bVerified = false;
			boolean bApproved = false;
			if(newLeaveType.equals("Cancelled")){
				if(newLeaveStatus.equals("Approved")){
					bApproved = true;
					SQLCommand4 = "UPDATE LEAVEINFO SET " + oldLeaveType + "_BAL ='"+ newAnnual + "' WHERE PERS_NUM ='" + persnumber + "'" + PersFile.getSQLTerminator();
					SQLResult = Reg3.doSQLExecute(SQLCommand4);
Log.println("[000] ReportAuditList.jsp sql: " + SQLCommand4);
				}
				else if(newLeaveStatus.equals("Verified")){
					bVerified = true;
				}
				newLeaveStatus = newLeaveType;
				SQLCommand += ", LEAVE_STATUS = '" + newLeaveStatus + "'";
			}
			else{
				SQLCommand += ", LEAVE_TYPE = '" + newLeaveType + "'";
				SQLCommand += ", LEAVE_TOTAL = '" + newLeaveTotal + "'";
				SQLCommand += ", LEAVE_FROM = '" + newLeaveFrom + "'";
				SQLCommand += ", LEAVE_FROM_AMPM = '" + newLeaveFromAMPM + "'";
				SQLCommand += ", LEAVE_TO = '" + newLeaveTo + "'";
				SQLCommand += ", LEAVE_TO_AMPM = '" + newLeaveToAMPM + "'";
			}
			SQLCommand += " WHERE LEAVE_NUM = '" + newLeaveNum + "' AND PERS_NUM = '" + persnumber + "'" + PersFile.getSQLTerminator();
			SQLResult = Reg.doSQLExecute(SQLCommand);
Log.println("[000] ReportAuditList.jsp sql: " + SQLCommand);
		

		   String SQLCommand2 = "SELECT EMAIL,FNAME,MANAGER FROM USER WHERE PERS_NUM = '" + persnumber + "'" + PersFile.getSQLTerminator();
		   if (Reg.setResultSet(SQLCommand2)) {
				String pal_address = "services@elc.com.sg";
			   String email = PersFile.getTrim(Reg.myResult.getString(1));
			   String name = PersFile.getTrim(Reg.myResult.getString(2));
			   String vo = PersFile.getTrim(Reg.myResult.getString(3));
			   String subject = "HR updated leave record: Reason-" + newLeaveReason;
			   String msg = "There is leave updated by HR: \n";
			String sEmailMsg = "\n  Leave Details:\n";
				sEmailMsg += "    Name:            " + name + "\n";
				sEmailMsg += "    From:             " + newLeaveFrom;
				sEmailMsg += " " + newLeaveFromAMPM + "\n";
				sEmailMsg += "    To:                  " + newLeaveTo;
				sEmailMsg += " " + newLeaveToAMPM + "\n";
				sEmailMsg += "    Total:              " + newLeaveTotal + "\n";
				sEmailMsg += "    Type:              " + newLeaveType + "\n";
				sEmailMsg += "    Reason:          " + newLeaveReason + "\n";
			   SendAnEmail(email, pal_address, subject, msg+sEmailMsg, SendInfo);
				String eMailHR = SystemDOM.getDOMTableValueFor("configuration", "hr_mail", "ivy@elc.com.sg");
				SendAnEmail(eMailHR, pal_address, subject, msg+sEmailMsg, SendInfo);
				if(bApproved || bVerified){
					String SQLCommand3 = "SELECT EMAIL FROM USER WHERE PERS_NUM = '" + vo + "'" + PersFile.getSQLTerminator();
					if (Reg.setResultSet(SQLCommand3)) {
						String emailVO = PersFile.getTrim(Reg.myResult.getString(1));
						SendAnEmail(emailVO, pal_address, subject, msg+sEmailMsg, SendInfo);
					}
					if(bApproved){
						SendAnEmail("william@elc.com.sg", pal_address, subject, msg+sEmailMsg, SendInfo);
					}
				}
		   }
		}
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
     <title>Leave changed</title>
	<style>
	td {
		padding: 10px;
	}
	</style>
	</head>
     <body>
		<p><big><em><strong><font face="Arial"><%= sTitle%></font></strong></em></big></p>
	<table border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="25%" align="right"><em><strong><font face="Arial"><span>User ID</span>: </font></strong></em></td>
      <td width="75%" align="left<span"><%= persnumber%></span></td>
    </tr>
    <tr>
      <td width="25%" align="right"><em><strong><font face="Arial"><span>Leave ID</span>: </font></strong></em></td>
      <td width="75%" align="left<span"><%= newLeaveNum%></span></td>
    </tr>
    <tr>
      <td width="25%" align="right"><em><strong><font face="Arial"><span>Leave status</span>: </font></strong></em></td>
      <td width="75%" align="left<span"><%= newLeaveStatus%></span></td>
    </tr>
    <tr>
      <td width="25%" align="right"><em><strong><font face="Arial"><span>Leave Type</span>: </font></strong></em></td>
      <td width="75%" align="left<span"><%= newLeaveType%></span></td>
    </tr>
    <tr>
      <td width="25%" align="right"><em><strong><font face="Arial"><span>Leave From</span>: </font></strong></em></td>
      <td width="75%" align="left<span"><%= newLeaveFrom%></span>:<span><%= newLeaveFromAMPM%></span></td>
    </tr>
    <tr>
      <td width="25%" align="right"><em><strong><font face="Arial"><span>Leave To</span>: </font></strong></em></td>
      <td width="75%" align="left<span"><%= newLeaveTo%></span><span>:<%= newLeaveToAMPM%></span></td>
    </tr>
    <tr>
      <td width="25%" align="right"><em><strong><font face="Arial"><span>Leave Total</span>: </font></strong></em></td>
      <td width="75%" align="left<span"><%= newLeaveTotal%></span></td>
    </tr>
    <tr>
      <td width="25%" align="right"><em><strong><font face="Arial"><span>Leave Reason</span>: </font></strong></em></td>
      <td width="75%" align="left<span"><%= newLeaveReason%></span></td>
    </tr>
  </table>

</body>
</html>
<%
} else { %>
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 

%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>

