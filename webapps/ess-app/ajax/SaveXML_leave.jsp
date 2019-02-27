<%--
SaveXML.jsp - saves a report to the user's register file (XMLR) 
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

<jsp:useBean id = "SaveXML"
     class="ess.ReportContainer"
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
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" /> 
<jsp:useBean id = "Sys"
     class="ess.ServerSystemTable"
     scope="page" />            
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="page" />     
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />    
<%@ include file="../DBAccessInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>
<% 

String database = request.getParameter("database");
String ownersName = request.getParameter("email");
String reportComment = request.getParameter("comment");
String reference = request.getParameter("reference");


if (reportComment != null) SaveXML.setComment(reportComment);

Log.println("[000] ajax/SaveXML.jsp owner is " + ownersName);
Log.println("[000] ajax/SaveXML.jsp reference is " + reference);

boolean pFlag = PersFile.setPersInfo(ownersName); 

String CCode = "";
String persnumber = PersFile.getPersNum();
String email = PersFile.getEmailAddress();

Reg.setConnection(PersFile.getConnection());
Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
Log.println("[000] ajax/SaveXML.jsp ccode is " + CCode);
if (pFlag && PersFile.getChallengeCode().equals(CCode)) {  
	SaveXML.setConnection(PersFile.getConnection());
    SaveXML.setSQLTerminator(PersFile.getSQLTerminator());
	SaveXML.setOwner(ownersName); 
    if (SaveXML.getDOMProcessed()) { 
      String setStatus = "Pending";
      SaveXML.setStatus(setStatus);
	}
	String reportScript = SystemDOM.getDOMTableValueFor("history","ajaxscreenscript","ajax/HistoryReportV1.jsp");
	String newLeaveStatue = SaveXML.getStatus();
	String newLeaveType = request.getParameter("newLeaveType");
	String newLeaveFrom = request.getParameter("newLeaveFrom");
	String newLeaveFromAMPM = request.getParameter("newLeaveFromAMPM");
	String newLeaveTo = request.getParameter("newLeaveTo");
	String newLeaveToAMPM = request.getParameter("newLeaveToAMPM");
	String newLeaveTotal = request.getParameter("newLeaveTotal");
	String newLeaveReason = request.getParameter("newLeaveReason");
	String currentDate = Dt.simpleDate.format(Dt.date);
	String currentTime = Dt.getLocalTime();
	currentTime = currentTime.replace(":","");
	//currentTime = currentTime.substring(0,4);
	String newLeaveNum = persnumber.replace("0","") + currentTime;
	if(newLeaveNum.length() > 8){
		newLeaveNum = newLeaveNum.substring(0,8);
	}
	int SQLResult = 0;
  	String manager = PersFile.getManager();
    String SQLCommand = SystemDOM.getDOMTableValueFor("history","reporter_balance");
	SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",persnumber);
	String ANNUAL_BAL="0";
	String ANNUAL_ENT="0";
	String MARRIAGE_BAL="0";
	String MARRIAGE_ENT="0";
	String CHILDCARE_BAL="0";
	String CHILDCARE_ENT="0";
	String MEDICAL_BAL="0";
	String MEDICAL_ENT="0";
	String HOSPITAL_BAL="0";
	String HOSPITAL_ENT="0";
	String PATERNITY_BAL="0";
	String PATERNITY_ENT="0";
	String MATERNITY_BAL="0";
	String MATERNITY_ENT="0";
	String COMP_BAL="0";
	String COMP_ENT="0";
	String COMP_NEXTOFKIN_BAL="0";
	String COMP_NEXTOFKIN_ENT="0";
	String OFINLIEU_BAL="0";
	String OFINLIEU_ENT="0";
	String RESERVIST_BAL="0";
	String RESERVIST_ENT="0";
	String UNPAID_BAL="0";
	String UNPAID_ENT="0";
	String BRING_FORWARD="0";
	String ADVANCE_LEAVE="0";
	String PENDING_LEAVE="0";
	if (Reg.setResultSet(SQLCommand)) { 
		ANNUAL_BAL=PersFile.getTrim(Reg.myResult.getString(1));
		ANNUAL_ENT=PersFile.getTrim(Reg.myResult.getString(2));
		MARRIAGE_BAL=PersFile.getTrim(Reg.myResult.getString(3));
		MARRIAGE_ENT=PersFile.getTrim(Reg.myResult.getString(4));
		CHILDCARE_BAL=PersFile.getTrim(Reg.myResult.getString(5));
		CHILDCARE_ENT=PersFile.getTrim(Reg.myResult.getString(6));
		MEDICAL_BAL=PersFile.getTrim(Reg.myResult.getString(7));
		MEDICAL_ENT=PersFile.getTrim(Reg.myResult.getString(8));
		HOSPITAL_BAL=PersFile.getTrim(Reg.myResult.getString(9));
		HOSPITAL_ENT=PersFile.getTrim(Reg.myResult.getString(10));
		PATERNITY_BAL=PersFile.getTrim(Reg.myResult.getString(11));
		PATERNITY_ENT=PersFile.getTrim(Reg.myResult.getString(12));
		MATERNITY_BAL=PersFile.getTrim(Reg.myResult.getString(13));
		MATERNITY_ENT=PersFile.getTrim(Reg.myResult.getString(14));
		COMP_BAL=PersFile.getTrim(Reg.myResult.getString(15));
		COMP_ENT=PersFile.getTrim(Reg.myResult.getString(16));
		COMP_NEXTOFKIN_BAL=PersFile.getTrim(Reg.myResult.getString(17));
		COMP_NEXTOFKIN_ENT=PersFile.getTrim(Reg.myResult.getString(18));
		OFINLIEU_BAL=PersFile.getTrim(Reg.myResult.getString(19));
		OFINLIEU_ENT=PersFile.getTrim(Reg.myResult.getString(20));
		RESERVIST_BAL=PersFile.getTrim(Reg.myResult.getString(21));
		RESERVIST_ENT=PersFile.getTrim(Reg.myResult.getString(22));
		UNPAID_BAL=PersFile.getTrim(Reg.myResult.getString(23));
		UNPAID_ENT=PersFile.getTrim(Reg.myResult.getString(24));
		BRING_FORWARD=PersFile.getTrim(Reg.myResult.getString(25));
		ADVANCE_LEAVE=PersFile.getTrim(Reg.myResult.getString(26));
		PENDING_LEAVE=PersFile.getTrim(Reg.myResult.getString(27));
	}//if (Reg.setResultSet(SQLCommand)) balance found
	String[] dataValue = newLeaveFrom.split("/");
    int monthValue = Integer.parseInt(dataValue[1]);
	if(monthValue > 6){
		BRING_FORWARD = "0";
	}
	float leaveBalance = Float.parseFloat(ANNUAL_BAL);
	float leaveApplied = Float.parseFloat(newLeaveTotal);
	String errorMsg = "You may not apply for leave type:" + newLeaveType + "! ";
	if(newLeaveType.equals("Annual")){
			leaveBalance = Float.parseFloat(ANNUAL_BAL) + Float.parseFloat(BRING_FORWARD);
	}
	else if(newLeaveType.equals("Marriage")){
			leaveBalance = Float.parseFloat(MARRIAGE_BAL);
	}
	else if(newLeaveType.equals("Childcare")){
			if(leaveBalance > 0){
				SQLResult = -1;
				errorMsg += "Please clear Annual Leave first!";
			}
			else{
				leaveBalance = Float.parseFloat(CHILDCARE_BAL);
			}
	}
	else if(newLeaveType.equals("Medical")){
			leaveBalance = Float.parseFloat(MEDICAL_BAL);
	}
	else if(newLeaveType.equals("Hospitalisation")){
			leaveBalance = Float.parseFloat(HOSPITAL_BAL);
	}
	else if(newLeaveType.equals("Paternity")){
			leaveBalance = Float.parseFloat(PATERNITY_BAL);
	}
	else if(newLeaveType.equals("Maternity")){
			leaveBalance = Float.parseFloat(MATERNITY_BAL);
	}
	else if(newLeaveType.equals("Compassionate Next-of-kin")){
			leaveBalance = Float.parseFloat(COMP_NEXTOFKIN_BAL);
	}
	else if(newLeaveType.equals("Compassionate")){
			leaveBalance = Float.parseFloat(COMP_BAL);
	}
	else if(newLeaveType.equals("Off In Lieu")){
			leaveBalance = Float.parseFloat(OFINLIEU_BAL);
	}
	else if(newLeaveType.equals("Reservist")){
			SQLResult = -2;
			leaveBalance = Float.parseFloat(RESERVIST_BAL);
	}
	else if(newLeaveType.equals("Unpaid")){
			/*if(leaveBalance > 0){
				SQLResult = -1;
				errorMsg += "Please clear Annual Leave first!...redirecting page now...";
			}
			else*/{
				SQLResult = -5;
				leaveBalance = Float.parseFloat(UNPAID_BAL);
			}
	}

    int yearValue1 = Integer.parseInt(newLeaveFrom.substring(newLeaveFrom.length()-4,newLeaveFrom.length()));
    int yearValue2 = Integer.parseInt(currentDate.substring(currentDate.length()-4,currentDate.length()));
	if(yearValue1 > yearValue2){
		SQLResult = -3;
	}//apply leave for next year

		//checking newLeaveNum duplicate start
			SQLCommand = "SELECT LEAVE_NUM FROM LEAVERECORD WHERE LEAVE_NUM =";
			SQLCommand += newLeaveNum + PersFile.getSQLTerminator();
			if (Reg.setResultSet(SQLCommand)) {
				newLeaveNum = persnumber.substring(persnumber.length()-2,persnumber.length()) + newLeaveNum;
				newLeaveNum = newLeaveNum.substring(0,8);
			}
			SQLCommand = "SELECT LEAVE_NUM FROM LEAVERECORD WHERE LEAVE_NUM =";
			SQLCommand += newLeaveNum + PersFile.getSQLTerminator();
			if (Reg.setResultSet(SQLCommand)) {
				newLeaveNum = persnumber.substring(0,2) + newLeaveNum;
				newLeaveNum = newLeaveNum.substring(0,8);
			}
		//checking newLeaveNum duplicate finish
	//checking duplicate leaves
	newLeaveFrom = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(newLeaveFrom,PersFile.getDateFormat())));
	newLeaveTo = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(newLeaveTo,PersFile.getDateFormat())));
    SQLCommand = SystemDOM.getDOMTableValueFor("history","reporter_duplicate");
	SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",persnumber);
	SQLCommand = Reg.SQLReplace(SQLCommand,"$begdate$",newLeaveFrom);
	SQLCommand = Reg.SQLReplace(SQLCommand,"$enddate$",newLeaveTo);
	SQLCommand = Reg.SQLReplace(SQLCommand,"$leavefromampm$",newLeaveFromAMPM);
	if (Reg.setResultSet(SQLCommand)) { 
		SQLResult = -4;
	}//duplicate leave found
	if(SQLResult == -4){%>
<br><br>
<h1><span id="personalData"><%= errorMsg%></span><h1>
<h1><span id="personalData">From or To dates are applied already!</span><h1>
<h1><span id="personalData">...redirecting page now...</span><h1>
<br><br>
<span language="javascript" id="script" folder="<%= PersFile.getAppServer() + "/" + PersFile.getAppFolder() %>" file="ajax/startJS_leave.jsp"/>

<%
	}//duplicate leave found
	else if(SQLResult == -1){%>
<br><br>
<h1><span id="personalData"><%= errorMsg%></span><h1>
<br><br>

<span language="javascript" id="script" folder="<%= PersFile.getAppServer() + "/" + PersFile.getAppFolder() %>" file="ajax/startJS_leave.jsp"/>

<%
	}//need to clear annual leave first
	else if(leaveApplied > leaveBalance && SQLResult == 0 && SQLResult != -5){
			errorMsg += "      Not enough balance!   ...redirecting page now...";%>
<br><br>
<h1><span id="personalData"><%= errorMsg%></span><h1>
<br><br>

<span language="javascript" id="script" folder="<%= PersFile.getAppServer() + "/" + PersFile.getAppFolder() %>" file="ajax/startJS_leave.jsp"/>

<%
	}//not enough leave balance left
	else{
		String newAsOfDate = Dt.xBaseDate.format(Dt.date);
		//newLeaveFrom = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(newLeaveFrom,PersFile.getDateFormat())));
		//newLeaveTo = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(newLeaveTo,PersFile.getDateFormat())));
		SQLCommand = SystemDOM.getDOMTableValueFor("history","reporter_leave_new");
       SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",persnumber);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$depart$",PersFile.getDepartment());
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavevo$",PersFile.getManager());
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavenum$",newLeaveNum);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavetotal$",newLeaveTotal);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavecreated$",newAsOfDate);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavetype$",newLeaveType);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavefrom$",newLeaveFrom);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavefromampm$",newLeaveFromAMPM);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leaveto$",newLeaveTo);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavetoampm$",newLeaveToAMPM);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavestatus$",newLeaveStatue);
	   newLeaveReason = newLeaveReason.replaceAll("'","\\\\'");
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavereason$",newLeaveReason);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leaveapplicant$",ownersName);
	   SQLResult = Reg.doSQLExecute(SQLCommand);
	   SQLResult = 0;
	   if(SQLResult > -1){%>
<br><br>
<span id="personalData"><%= Lang.getString("PERSONAL_DATA_BEING_UPDATED") %></span>
<br><br>

<span language="javascript" id="script" folder="<%= PersFile.getAppServer() + "/" + PersFile.getAppFolder() %>" file="ajax/SaveXMLJS_leave.jsp?email=<%= ownersName%>&reference=<%= newLeaveNum%>&ccode=<%= CCode%>&status=<%= newLeaveStatue%>&type=<%=newLeaveType%>"/>

<% 		}
		else {%>
<span>Update leave database failed!</span>		
<%		}

	}//enough balance to update leave database
} else { %>
<%@ include file="ReloginRedirectMsg.jsp" %>
<% } %>


