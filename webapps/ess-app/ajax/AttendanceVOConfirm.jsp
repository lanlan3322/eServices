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
<jsp:useBean id = "DOM"
     class="ess.AdisoftDOM"
     scope="session" />
<jsp:useBean id = "SendInfo"
     class="ess.ServerSystemTable"
     scope="page" />

<%@ include file="../DBAccessInfo.jsp" %>
<%@ include file="../../SendAnEmail.jsp" %>
<%
String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String database = request.getParameter("database");

//PersFile.setDB(database,DBUser,DBPassword);
Reg.setConnection(PersFile.getConnection()); 
Reg.setSQLTerminator(PersFile.getSQLTerminator());
Reg2.setConnection(PersFile.getConnection()); 
Reg2.setSQLTerminator(PersFile.getSQLTerminator());
boolean errorCondition = false; 
String ownersName = request.getParameter("email");
Log.println("[000] AttendanceVOConfirm.jsp - name: " + ownersName);
boolean pFlag = PersFile.setPersInfo(ownersName); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 

%> 
<%@ include file="../SystemInfo.jsp" %>
<%@ include file="../SchemaInfo.jsp" %>

<html>
<body>

<strong><em>Following attendance have been changed :</em></strong><br>
<%
   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   String SQLDateReplace = SystemDOM.getDOMTableValueFor("sql","datesql");

   String SQLCommand = "";
   String item2Remove;
   String tableName;
	int SQLResult = 0;
	SQLCommand = "UPDATE DEPART SET SUPER = '1' WHERE MANAGER = '" + PersFile.persnum + "' OR DEPART = '" + PersFile.getDepartment() + "'" + PersFile.getSQLTerminator();
	SQLResult = Reg.doSQLExecute(SQLCommand);
   String changed = request.getParameter("reference");
   Log.println("[000] EditRemove.jsp - reference: " + changed);
   java.util.StringTokenizer rp = new java.util.StringTokenizer(changed, ";"); 
   
   String days = request.getParameter("days");
   String reason = request.getParameter("reason");
   String leavetype = request.getParameter("type");
   String dateSelected = request.getParameter("newLeaveFrom");
	if (dateSelected != null && !dateSelected.equals("")) dateSelected = Dt.getSQLDate(Dt.getDateFromStr(dateSelected,PersFile.getDateFormat()));
	String pername = "";
	String msgToBUHead = "";
	   msgToBUHead += "    Thank you for updating the attendance.\n\n";
	   msgToBUHead += "    Here is the changed list:\n ";
   while (rp.hasMoreTokens()) {  
		String singleChanged = rp.nextToken().trim() ;
		String[] result = singleChanged.split(",");
		String newLeaveTotal = "1";
		String newLeaveFromAMPM = "AM";
		String newLeaveToAMPM = "PM";
		String persnumber = "900";
		String newLeaveType = "Error";
		String sDeputy = "0";
		if(result.length > 2){
			if (result[2] != null && !result[2].equals(""))
			{
				newLeaveFromAMPM = result[2];
				newLeaveToAMPM = result[2];
				newLeaveTotal = "0.5";
			}	
		}		

		if(result.length > 1){
			if (result[1] != null && !result[1].equals(""))
			{
				newLeaveType = result[1];
			}
		}
		
		if (result[0] != null && !result[0].equals(""))
		{
			persnumber = result[0];
		}
		if(result.length > 3){
			if (result[3].equals("Alternate VO"))
			{
				sDeputy = "1";
			}	
			SQLCommand = "UPDATE USER SET PRENOTE = '" + sDeputy + "' WHERE PERS_NUM = '" + persnumber + "'" + PersFile.getSQLTerminator();
			SQLResult = Reg.doSQLExecute(SQLCommand);
%>
<br><br><br><strong><em>User <%=persnumber%> is set as <%=result[3]%></em></strong>
<%		}		
		String newLeaveStatue = "Pending";
		if(newLeaveType.equals("Present"))
		{
			newLeaveStatue = "Approved";
		}
		String currentDate = Dt.xBaseDate.format(Dt.date);
		String newLeaveFrom = dateSelected;//currentDate;
		String newLeaveTo = dateSelected;//currentDate;
		String newLeaveReason = "Created by BU head from attendance editing";
		String currentTime = Dt.getLocalTime();
		currentTime = currentTime.replace(":","");
		currentTime = currentTime.substring(0,4);
		String newLeaveNum = persnumber.replace("0","") + currentTime.replace("0","");
		if(newLeaveNum.length() > 8){
			newLeaveNum = newLeaveNum.substring(0,8);
		}
		//checking duplicate leaves
		//newLeaveFrom = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(newLeaveFrom,PersFile.getDateFormat())));
		//newLeaveTo = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(newLeaveTo,PersFile.getDateFormat())));
		SQLCommand = SystemDOM.getDOMTableValueFor("history","reporter_duplicate");
		SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",persnumber);
		SQLCommand = Reg.SQLReplace(SQLCommand,"$begdate$",newLeaveFrom);
		SQLCommand = Reg.SQLReplace(SQLCommand,"$enddate$",newLeaveTo);
		SQLCommand = Reg.SQLReplace(SQLCommand,"$leavefromampm$",newLeaveFromAMPM);
		if (Reg.setResultSet(SQLCommand)) { 
			SQLResult = -4;
		}//duplicate leave found
			String email = "services@elc.com.sg";
		String manager = PersFile.getManager();
		String depart = PersFile.getDepartment();
		SQLCommand = "SELECT MANAGER, DEPART, FNAME, LNAME FROM USER WHERE PERS_NUM = '" + persnumber + "'" + PersFile.getSQLTerminator();
		if (Reg.setResultSet(SQLCommand)) {
			manager = PersFile.getTrim(Reg.myResult.getString(1));
			depart = PersFile.getTrim(Reg.myResult.getString(2));
			pername = PersFile.getTrim(Reg.myResult.getString(3)) + " " + PersFile.getTrim(Reg.myResult.getString(4));
		}

		if(SQLResult != -4)
		{
			if(!newLeaveType.equals("Present")){
				SQLCommand = SystemDOM.getDOMTableValueFor("history","reporter_leave_new");
			   SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",persnumber);
			   SQLCommand = Reg.SQLReplace(SQLCommand,"$depart$",depart);
			   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavevo$",manager);
			   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavenum$",newLeaveNum);
			   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavetotal$",newLeaveTotal);
			   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavecreated$",currentDate);
			   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavetype$",newLeaveType);
			   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavefrom$",newLeaveFrom);
			   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavefromampm$",newLeaveFromAMPM);
			   SQLCommand = Reg.SQLReplace(SQLCommand,"$leaveto$",newLeaveTo);
			   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavetoampm$",newLeaveToAMPM);
			   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavestatus$",newLeaveStatue);
			   SQLCommand = Reg.SQLReplace(SQLCommand,"$leavereason$",newLeaveReason);
			   SQLResult = Reg.doSQLExecute(SQLCommand);
			   SQLResult = 0;
			   if(SQLResult > -1){
					String sEmailMsg = "\n  Leave Details:\n";
						sEmailMsg += "    User Name:  " + pername + "\n";
						sEmailMsg += "    User ID:         " + persnumber + "\n";
						sEmailMsg += "    Department: " + depart + "\n";
						sEmailMsg += "    From:             " + newLeaveFrom;
						sEmailMsg += " " + newLeaveFromAMPM + "\n";
						sEmailMsg += "    To:                  " + newLeaveTo;
						sEmailMsg += " " + newLeaveToAMPM + "\n";
						sEmailMsg += "    Total:             " + newLeaveTotal + "\n";
						sEmailMsg += "    Type:              " + newLeaveType + "\n";
						sEmailMsg += "    Reason:         " + newLeaveReason + "\n";
						sEmailMsg += "    Created on:  " + currentDate + "\n";
						sEmailMsg += "\n\n" + "Please submit it from http://services.elc.com.sg";
						sEmailMsg += "\n\n" + "Annual leave will be deducted if you do not apply it within 7 days.";
					String SQLCommand2 = "SELECT EMAIL FROM USER WHERE PERS_NUM = '" + persnumber + "'" + PersFile.getSQLTerminator();
					if (Reg.setResultSet(SQLCommand2)) {
						email = PersFile.getTrim(Reg.myResult.getString(1));
						String pal_address = SendInfo.getSystemString("PAL_EMAIL_ADDRESS","services@elc.com.sg");
						String subject = "New pending leave created by BU Head: " + newLeaveReason;
						String msg = "There is a new pending leave created for you to apply.\n";
						msgToBUHead += "	-  User Name:  " + pername + ",    Leave: " + newLeaveType + " " + dateSelected + " " + newLeaveFromAMPM + " to " + newLeaveToAMPM + " ";
						//if(newLeaveType.equals("Present"))
						{
							if(sDeputy.equals("1")){
								subject = "You are assigned as VO by your BU head";
								msg = "\n  Congratulations!\n\n  You are assigned as VO by your BU head.\n\n  Please login and edit attendance for your department.\n\n\n Thank you!";
								sEmailMsg = "";
								msgToBUHead += "  Role is Alternate VO.\n";
							}
							else {
								subject = "You are removed from VO list by your BU head";
								msg = "\n  You are removed from VO list by your BU head.\n\n  Thanks for your help on editing attendance list.";
								sEmailMsg = "";
								msgToBUHead += "  Role is User.\n";
							}
						}
						SendAnEmail(email, pal_address, subject, msg+sEmailMsg, SendInfo);
					}
				}
			}
			else
			{
				msgToBUHead += "	-  User Name: " + pername;
				if(sDeputy.equals("1")){
					msgToBUHead += "  Role from User to Alternate VO.\n";
				}
				else {
					msgToBUHead += "  Role from Alternate VO to User.\n";
				}
			}
%>
<br><br><strong><em>User Num:<%=persnumber%> , User Name: <%= pername%>, Leave: <%= newLeaveType%> : <%= dateSelected%> <%=newLeaveFromAMPM %>-<%=newLeaveToAMPM %></em></strong>
<%	
		}//if duplicated leave found
		else{
%>
<br><br><strong><em>User Num:<%=persnumber%> , User Name: <%= pername%>, Leave: <%= newLeaveType%> : <%= dateSelected%> <%=newLeaveFromAMPM %>-<%=newLeaveToAMPM %></em></strong>
		<%	}
   }
	if(msgToBUHead.indexOf("User Name") < 0){
		msgToBUHead = "There is no change for leaves!";
%>
<br><br><br><strong><em><%=msgToBUHead%></em></strong>
<%	}
	else{
		msgToBUHead += "\n\n    Have a nice day!";
		SendAnEmail(ownersName, "services@elc.com.sg", "Thank you for updating the attendance", msgToBUHead, SendInfo);
	}
	//String HR_address = SendInfo.getSystemString("HR_MAIL","services@elc.com.sg");
	//SendAnEmail(HR_address, "services@elc.com.sg", "BU heads have updated the attendance", msgToBUHead, SendInfo);

%>

</body>
</html>

<% 
} else { 
     Log.println("[400] EditRemove.jsp security object removed for " + ownersName); %>
     <%@ include file="../ReloginRedirectMsg.jsp" %>
<%
}
%>