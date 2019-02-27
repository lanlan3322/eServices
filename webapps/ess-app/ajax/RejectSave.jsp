<%--
ApproveSave.jsp - Saves approval to database, sends out e-mail, and handles dup signer 
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
<jsp:useBean id = "SendInfo"
     class="ess.ServerSystemTable"
     scope="page" />
<jsp:useBean id = "SystemDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "SysTable"
     class="ess.ServerSystemTable"
     scope="page" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" /> 
<jsp:useBean id = "Unescape"
     class="org.apache.commons.lang.StringEscapeUtils"
     scope="page" />               
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />

<%@ include file="../DBAccessInfo.jsp" %>

<%

  SendInfo.setConnection(PersFile.getConnection());
  SendInfo.setSQLTerminator(PersFile.getSQLTerminator());

  Reg.setConnection(PersFile.getConnection()); 
  Reg.setSQLTerminator(PersFile.getSQLTerminator());

String ownersName = request.getParameter("email");
if (ownersName != null) ownersName = Unescape.unescapeHtml(ownersName);
String CCode = "";
String NeedPassword = "NO";
boolean pFlag = PersFile.setPersInfo(ownersName); 

if (pFlag) {
   SysTable.setConnection(PersFile.getConnection());   //SystemInfo.jsp handled differently here
   SysTable.setSQLTerminator(PersFile.getSQLTerminator());
   if (!SystemDOM.getDOMProcessed()) {
     String system_file = SysTable.getSystemString("XMLSYSTEM","C:\\WORK\\"); 
     java.io.File SystemFile = new java.io.File(system_file);
     SystemDOM.setSQLTerminator(PersFile.getSQLTerminator());
     SystemDOM.setDOM(SystemFile);
   }
   NeedPassword = "no";//SystemDOM.getDOMTableValueFor("configuration", "pwd_approval","yes");

   if(PersFile.getChallengeCode().equals("")) {
     PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
   }
   CCode = request.getParameter("ccode"); 
}

if (pFlag  && PersFile.getChallengeCode().equals(CCode)) { 

%>
<strong><em><%= Lang.getLabel("REPORTS_APPROVED") %></em></strong><br>
<%
   String SQLCommand;
   String persnum;
   int SQLResult;
   String pal_address = "services@elc.com.sg";

   persnum = request.getParameter("reference");
   String leavenum = request.getParameter("status");
   String action = request.getParameter("voucher");
   String msgdata = request.getParameter("msgdata");
   boolean actionFlag = false;
   String name = PersFile.name;
	String emailUser = pal_address;
	String SQLCommand4 = "SELECT USER.EMAIL,USER.FNAME,USER.LNAME FROM USER JOIN LEAVERECORD ON USER.PERS_NUM = LEAVERECORD.PERS_NUM WHERE LEAVERECORD.LEAVE_NUM = '" + leavenum + "'" + PersFile.getSQLTerminator();
	if (Reg.setResultSet(SQLCommand4)) {
		emailUser = PersFile.getTrim(Reg.myResult.getString(1));
		name = PersFile.getTrim(Reg.myResult.getString(2)) + " " + PersFile.getTrim(Reg.myResult.getString(3));
	}
	String sEmailMsg = "\n  Leave Details:\n";
	String SQLCommand2 = "SELECT * FROM LEAVERECORD WHERE LEAVE_NUM='" + leavenum + "'" + PersFile.getSQLTerminator();
	if (Reg.setResultSet(SQLCommand2)) {
		sEmailMsg += "    User Name:  " + name + "\n";
		sEmailMsg += "    User ID:         " + PersFile.getTrim(Reg.myResult.getString(1)) + "\n";
		sEmailMsg += "    Department: " + PersFile.getTrim(Reg.myResult.getString(2)) + "\n";
		sEmailMsg += "    From:             " + PersFile.getTrim(Reg.myResult.getString(8));
		sEmailMsg += " " + PersFile.getTrim(Reg.myResult.getString(9)) + "\n";
		sEmailMsg += "    To:                  " + PersFile.getTrim(Reg.myResult.getString(10));
		sEmailMsg += " " + PersFile.getTrim(Reg.myResult.getString(11)) + "\n";
		sEmailMsg += "    Total:             " + PersFile.getTrim(Reg.myResult.getString(5)) + "\n";
		sEmailMsg += "    Type:              " + PersFile.getTrim(Reg.myResult.getString(7)) + "\n";
		sEmailMsg += "    Reason:         " + PersFile.getTrim(Reg.myResult.getString(13)) + "\n";
		sEmailMsg += "    Created on:  " + PersFile.getTrim(Reg.myResult.getString(6));
	}
	if (action.equalsIgnoreCase("Approved")){
           SQLCommand = "UPDATE LEAVERECORD SET LEAVE_STATUS = 'Verified' WHERE LEAVE_NUM ='" + leavenum + "'" + PersFile.getSQLTerminator();
           SQLResult = Reg.doSQLExecute(SQLCommand);
		   String SQLCommand3 = "SELECT USER.EMAIL FROM USER JOIN DEPART ON USER.PERS_NUM = DEPART.CLERK WHERE DEPART.DEPART = '" + PersFile.depart + "'" + PersFile.getSQLTerminator();
		   if (Reg.setResultSet(SQLCommand3)) {
			   String email = PersFile.getTrim(Reg.myResult.getString(1));
			   String subject = "Leave waiting for approve:" + leavenum;
			   String msg = "There is leave verified by BU head. Waiting for your approval!\n";
			   SendAnEmail(email, pal_address, subject, msg+sEmailMsg, SendInfo);
				String eMailHR = SystemDOM.getDOMTableValueFor("configuration", "hr_mail", "ivy@elc.com.sg");
				String msg3 = "New leave application is verified by BU head and sent to AO for approval!\n";
				SendAnEmail(eMailHR, pal_address, subject, msg3+sEmailMsg, SendInfo);
		   }
   }
   else {
           SQLCommand = "UPDATE LEAVERECORD SET LEAVE_STATUS = 'Rejected', LEAVE_REASON = '(REJECTED by VO:" + msgdata + ")' WHERE LEAVE_NUM ='" + leavenum + "'" + PersFile.getSQLTerminator();
           SQLResult = Reg.doSQLExecute(SQLCommand);
			String subject = "Rejected leave:" + leavenum + "; Reason:" + msgdata + " By BU Head";
			String msg = "There is leave rejected by your BU head. Please verify it with your VO!\n";
			SendAnEmail(emailUser, pal_address, subject, msg+sEmailMsg, SendInfo);
			String eMailHR = SystemDOM.getDOMTableValueFor("configuration", "hr_mail", "ivy@elc.com.sg");
			String msg3 = "New leave application is rejected by BU head!\n";
			SendAnEmail(eMailHR, pal_address, subject, msg3+sEmailMsg, SendInfo);
   }
	//if (action.equalsIgnoreCase("Rejected"))
%>
<br/>
<strong>Leave verified:<%=leavenum%>---<%=msgdata%><strong>
<br/><br/>
<p align="center"><a href="javascript: void parent.PersWithDBase('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ajax/ApproveList.jsp?downlevel=','approvallevel','1')" tabindex="1"><em><strong><%= Lang.getString("APP_RETURN") %></strong></em></a></p>
<% } else { %>
     <%@ include file="ReloginRedirectMsg.jsp" %>
<% } %>
<%@ include file="../SendAnEmail.jsp" %>

