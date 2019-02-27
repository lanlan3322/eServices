<%--
SubmitwithGuide.jsp - runs guidecheck and provides link the SubmitDbase.jsp
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

<!-- Copyright (c) 2003 Adisoft, Inc., All rights reserved -->
<%@ page contentType="text/html" %>

<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "GL"
     class="ess.Guideline"
     scope="page" />
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="page" />
<jsp:useBean id = "Enh"
     class="ess.Enhancement"
     scope="page" />
<jsp:useBean id = "SaveXML"
     class="ess.ReportContainer"
     scope="page" />
<jsp:useBean id = "SavePers"
     class="ess.SavePersData"
     scope="page" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />   
<jsp:useBean id = "CheckDup"
	class="ess.XML2ESS"
	scope="page" />
<jsp:useBean id = "SendInfo"
     class="ess.ServerSystemTable"
     scope="page" />

<%@ include file="../DBAccessInfo.jsp" %>

<%
String ownersName = request.getParameter("email");

boolean pFlag = PersFile.setPersInfo(ownersName); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 

if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
// if (pFlag) { 
	
  Log.println("[005] Start SubmitwithGuide: " + ownersName);
%> 

<%@ include file="../SystemInfo.jsp" %>
<%@ include file="../../SendAnEmail.jsp" %>
<% String database = request.getParameter("database");
   String submitMethod = "ajax/HistoryList.jsp";
   String leaveNum = request.getParameter("reference");
   Reg.setConnection(PersFile.getConnection());
   Reg.setSQLTerminator(PersFile.getSQLTerminator());
	String SQLCommand_Leave = "UPDATE LEAVERECORD SET LEAVE_STATUS='New' WHERE LEAVE_NUM='" + leaveNum + "'";
	int SQLResult = Reg.doSQLExecute(SQLCommand_Leave);
	String sEmailMsg = "\n  Leave Details:\n";
	String SQLCommand2 = "SELECT * FROM LEAVERECORD WHERE LEAVE_NUM='" + leaveNum + "'" + PersFile.getSQLTerminator();
	if (Reg.setResultSet(SQLCommand2)) {
		sEmailMsg += "    User Name:   " + PersFile.name + "\n";
		sEmailMsg += "    User ID:         " + PersFile.getTrim(Reg.myResult.getString(1)) + "\n";
		sEmailMsg += "    Department:  " + PersFile.getTrim(Reg.myResult.getString(2)) + "\n";
		sEmailMsg += "    From:             " + PersFile.getTrim(Reg.myResult.getString(8));
		sEmailMsg += " " + PersFile.getTrim(Reg.myResult.getString(9)) + "\n";
		sEmailMsg += "    To:                  " + PersFile.getTrim(Reg.myResult.getString(10));
		sEmailMsg += " " + PersFile.getTrim(Reg.myResult.getString(11)) + "\n";
		sEmailMsg += "    Total:             " + PersFile.getTrim(Reg.myResult.getString(5)) + "\n";
		sEmailMsg += "    Type:              " + PersFile.getTrim(Reg.myResult.getString(7)) + "\n";
		sEmailMsg += "    Reason:          " + PersFile.getTrim(Reg.myResult.getString(13)) + "\n";
		sEmailMsg += "    Created on:    " + PersFile.getTrim(Reg.myResult.getString(6));
	}
	SQLCommand2 = "SELECT USER.EMAIL FROM USER JOIN LEAVERECORD ON USER.PERS_NUM = LEAVERECORD.LEAVE_VO WHERE LEAVERECORD.LEAVE_NUM = '" + leaveNum + "'" + PersFile.getSQLTerminator();
	if (Reg.setResultSet(SQLCommand2)) {
		String email = PersFile.getTrim(Reg.myResult.getString(1));
		String pal_address = SendInfo.getSystemString("PAL_EMAIL_ADDRESS","services@elc.com.sg");
		String subject = "New leave application from: " + PersFile.name;
		String msg = "There is a new leave application for you to approve.\nPlease verify it from http://services.elc.com.sg \n";
		if(!email.equals(ownersName)){
			if(email.equals("william@elc.com.sg") || email.equals("tester_ao@elc.com.sg")){
				msg = "There is new leave from BU head.\nWaiting for your approval from: http://203.125.11.73/ess/ess/Audit.html \n";
			}
			SendAnEmail(email, pal_address, subject, msg+sEmailMsg, SendInfo);
		}
		String msg2 = "Your new leave application is sent for your VO to approve.\n";
		SendAnEmail(ownersName, pal_address, subject, msg2+sEmailMsg, SendInfo);
		String eMailHR = SystemDOM.getDOMTableValueFor("configuration", "hr_mail", "ivy@elc.com.sg");
		String msg3 = "There is a new leave application created and sent to VO for approval.\n";
		SendAnEmail(eMailHR, pal_address, subject, msg3+sEmailMsg, SendInfo);
%>
<script language="javascript" id="script" folder="<%= PersFile.getAppServer() + "/" + PersFile.getAppFolder() %>" file="ajax/SubmitwithGuideJS_leave.jsp?screen=<%= submitMethod%>"/>

<% } else {
     Log.println("[500] ajax/SubmitwithGuide.jsp Register access failure for: " + PersFile.getEmailAddress()); 
%>
     <%= Lang.getString("ERROR_ACCESSING_PERSONAL_DATA") %>
<% }
} else { %>

   <%@ include file="ReloginRedirectMsg.jsp" %>

<% } %>
<% Log.println("[000] SubmitwithGuide.jsp finished");
%>

