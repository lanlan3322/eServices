<%@ page contentType="text/html" %>
<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="java.time.*" %>
<%@page import="org.json.JSONObject" %>
<%@page import="java.text.SimpleDateFormat"%>
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

<%@ include file="../DBAccessInfo.jsp" %>
<%@ include file="../NumericSetup.jsp" %>
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
   Reg2.setConnection(PersFile.getConnection()); 
   Reg2.setSQLTerminator(PersFile.getSQLTerminator()); 
%>
<%@ include file="../StatusInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>
<%

// these are used in conjunction with the SQL found in system.xml
   String persnumber = PersFile.persnum;    //need to replace with a PersFile.get...()
   String inputDate = request.getParameter("newLeaveFrom");
	   SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	   String todayDateStr = sdf.format(new java.util.Date());
	String begDateStr = "";
	String endDateStr = "";
	   String begDateSQL = begDateStr;
	   String endDateSQL = endDateStr;
	if (inputDate != null && !inputDate.equals("")){
		  begDateStr = inputDate;
		  endDateStr = begDateStr;
	   if (begDateStr != null && !begDateStr.equals("")) begDateSQL = Dt.getSQLDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
	   if (endDateStr != null && !endDateStr.equals("")) endDateSQL = Dt.getSQLDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));
	  }
	  else{
		LocalDate today = LocalDate.now();
	    begDateStr = today.toString();//(today.withDayOfYear(1)).toString();
	    endDateStr = begDateStr;//(today.withDayOfYear(today.lengthOfYear())).toString();
	  }
		String backcolor = "class=\"offsetColor\"";
		String oldbackcolor = "";
		String newbackcolor;
		String leavetype = "Present";
		String leavestart = "";
		String leavestartampm = "AM";
		String leaveend = "";
		String leaveendampm = "PM";
		String leavestatus;
		String leaveNum;
		String leaveReason;
		String name = "";
		String pernum = "";
		List empdetails = new LinkedList();
        JSONObject empObj = null;
		boolean bAbleEditAttendance = false;
		String SQLCommand4 = "SELECT PRENOTE FROM USER WHERE PERS_NUM ='" + persnumber + "'";
		SQLCommand4 += PersFile.getSQLTerminator();		
		if (Reg2.setResultSet(SQLCommand4)) {
			try {
				if(PersFile.getTrim(Reg2.myResult.getString(1)).equals("1")){
					bAbleEditAttendance = true;
				}
		  } catch (java.lang.Exception ex) {
			ex.printStackTrace();
		  } //try
		}
		if (bAbleEditAttendance) {
		String SQLCommand3 = "SELECT USER.PERS_NUM, USER.FNAME, USER.LNAME, DEPART.SUPER, USER.PRENOTE, DEPART.MANAGER FROM USER INNER JOIN DEPART ON USER.DEPART = DEPART.DEPART WHERE (USER.DEPART ='" + PersFile.getDepartment() + "' OR USER.MANAGER='" + persnumber + "') AND USER.ACTIVE = '1'";
		SQLCommand3 += PersFile.getSQLTerminator();		
		if (Reg2.setResultSet(SQLCommand3)) {
			try {
				if(PersFile.getTrim(Reg2.myResult.getString(4)).equals("1")){
			%>
				<span style="color:blue"><h1>Your department status had been updated already!</h1></span>
			<%
				}
			%>

     <h1>Edit Attendance:<%=begDateStr%></h1>
	 <form action="edit/AttendanceVOConfirm.jsp">
		<input type="hidden" name="reference" value>
		<input type="hidden" name="dateSelected" value=<%=begDateStr%>>
     <table id="previousTable" border="0" cellspacing="0" cellpadding="0">
     <thead>
         <tr>
             <th width="5%" <%=backcolor%>></th>
             <th width="20%" <%=backcolor%> align="left">Name</th>
             <th width="20%" <%=backcolor%>>Current</th>
             <th width="20%" <%=backcolor%> align="left">Change To</th>
            <th width="15%" <%=backcolor%> align="left">Leave Period(AM/PM)</th>
            <th width="20%" <%=backcolor%>>Role</th>
         </tr>
	<%
			do { 
				pernum = PersFile.getTrim(Reg2.myResult.getString(1));
				name = PersFile.getTrim(Reg2.myResult.getString(2));
				name += " ";
				name += PersFile.getTrim(Reg2.myResult.getString(3));
				String sRight = PersFile.getTrim(Reg2.myResult.getString(5));
				boolean canEdit = false;
				if(sRight.equals("1")){
					canEdit = true;
				}
				String sDepartMgr = PersFile.getTrim(Reg2.myResult.getString(6));
				String SQLCommand2 = "SELECT LEAVE_TYPE, LEAVE_NUM, LEAVE_STATUS, LEAVE_FROM, LEAVE_FROM_AMPM, LEAVE_TO, LEAVE_TO_AMPM, LEAVE_REASON FROM LEAVERECORD WHERE PERS_NUM = '";
				SQLCommand2 += pernum;
				SQLCommand2 += "' AND LEAVE_STATUS <> 'Cancelled' AND LEAVE_STATUS <> 'Rejected' AND LEAVE_STATUS <> 'Credit' AND LEAVE_STATUS <> 'Offset'";
				SQLCommand2 += " AND LEAVE_FROM <= '" + begDateSQL + "' AND LEAVE_TO >= '" + endDateSQL + "'";
				SQLCommand2 += DBSQLTerminator;
				leavetype = "Present";
				leavestartampm = "AM";
				leaveendampm = "PM";
				if (Reg.setResultSet(SQLCommand2)) {
					try {
						do { 
							leaveNum = PersFile.getTrim(Reg.myResult.getString(2)); 
							leavetype = PersFile.getTrim(Reg.myResult.getString(1));
							leavestart = PersFile.getTrim(Reg.myResult.getString(4)); 
							leavestartampm = PersFile.getTrim(Reg.myResult.getString(5)); 
							leaveend = PersFile.getTrim(Reg.myResult.getString(6)); //used for subordinate lookup
							leaveendampm = PersFile.getTrim(Reg.myResult.getString(7)); //used for subordinate lookup
							leavestatus = PersFile.getTrim(Reg.myResult.getString(3));
							leaveReason = PersFile.getTrim(Reg.myResult.getString(8));
							if(leavetype.equals("Add-on")){
								leavetype = leavestatus;
							}
							empObj = new JSONObject();
							empObj.put("name", name);
							empObj.put("leavetype", leavetype);
							empObj.put("start", leavestart);
							empObj.put("startampm", leavestartampm);
							empObj.put("end", leaveend);
							empObj.put("endampm", leaveendampm);
							empObj.put("status", leavestatus);
							empObj.put("reason", leaveReason);
							empdetails.add(empObj);
						} while (Reg.myResult.next());
					} catch (java.lang.Exception ex) {
						%>
							<h2>Error in the SQL logic Attendance.jsp - contact support.<h2>
						<%  
					} //try
				}
				else{
					empObj = new JSONObject();
					empObj.put("name", name);
					empObj.put("leavetype", "Present");
					empObj.put("start", begDateSQL);
					empObj.put("startampm", "AM");
					empObj.put("end", endDateSQL);
					empObj.put("endampm", "PM");
					empObj.put("status", "In office");
					empObj.put("reason", "Working very hard");
					empdetails.add(empObj);
				}
			String selectionList = "<option";
			if(leavetype.equals("Present")){
					selectionList += " selected";
			}
			selectionList += ">Present</option><option";
			if(leavetype.equals("Annual")){
					selectionList += " selected";
			}
			selectionList += ">Annual</option><option";
			if(leavetype.equals("Medical")){
					selectionList += " selected";
			}
			selectionList += ">Medical</option><option";
			if(leavetype.equals("Childcare")){
					selectionList += " selected";
			}
			selectionList += ">Childcare</option><option";
			if(leavetype.equals("Marriage")){
					selectionList += " selected";
			}
			selectionList += ">Marriage</option><option";
			if(leavetype.equals("Hospitalisation")){
					selectionList += " selected";
			}
			selectionList += ">Hospitalisation</option><option";
			if(leavetype.equals("Paternity")){
					selectionList += " selected";
			}
			selectionList += ">Paternity</option><option";
			if(leavetype.equals("Maternity")){
					selectionList += " selected";
			}
			selectionList += ">Maternity</option><option";
			if(leavetype.equals("Compassionate Next-of-kin")){
					selectionList += " selected";
			}
			selectionList += ">Compassionate Next-of-kin</option><option";
			if(leavetype.equals("Compassionate")){
					selectionList += " selected";
			}
			selectionList += ">Compassionate</option><option";
			if(leavetype.equals("Off In Lieu")){
					selectionList += " selected";
			}
			selectionList += ">Off In Lieu</option><option";
			if(leavetype.equals("Reservist")){
					selectionList += " selected";
			}
			selectionList += ">Reservist</option><option";
			if(leavetype.equals("Unpaid")){
					selectionList += " selected";
			}
			selectionList += ">Unpaid</option>";
			
			String selectionListAMPM = "<option";
			if(leavestartampm.equals("AM") && leaveendampm.equals("PM"))
			{
					selectionListAMPM += " selected";
			}
			selectionListAMPM += "></option><option";
			if(leaveendampm.equals("AM") && leaveend.equals(leavestart))
			{
					selectionListAMPM += " selected";
			}
			selectionListAMPM += ">AM</option><option";
			if(leavestartampm.equals("PM") && leaveend.equals(leavestart))
			{
					selectionListAMPM += " selected";
			}
			selectionListAMPM += ">PM</option>";
			
%>
            <tr>
            <td width="5%"  <%=backcolor%>>
				<input type="checkbox" id="<%=pernum%>select_this_item" style="display: none" value="">
			</td>
            <td width="20%" <%=backcolor%> align="left"><%= name%></td>
            <td width="20%" <%=backcolor%> align="center"><%= leavetype%></td>
            <td width="20%" <%=backcolor%>>
			<select id="<%=pernum%>" onChange="Change('<%=pernum%>','<%= leavetype%>');"><%=selectionList%></select>
			</td>
			<td width="15%"  <%=backcolor%> align="left">
			<select id="<%=pernum%>AMPM" onChange="ChangeHalfday('<%=pernum%>','<%= leavetype%>');">
				<%=selectionListAMPM%>
			</select>
			</td>
			<%
				if(sDepartMgr.equals(pernum)){
			%>
            <td width="20%" <%=backcolor%> align="left">VO</td>
			<%
				}
				else if(canEdit){
			%>
            <td width="20%" <%=backcolor%> align="left">
				<select id="<%=pernum%>Role" onChange="ChangeRole('<%=pernum%>','Alternate VO');">
					<option selected>Alternate VO</option>
					<option>User</option>
				</select>
			</td>
			<%
				}
				else{
			%>
            <td width="20%" <%=backcolor%>>
				<select id="<%=pernum%>Role" onChange="ChangeRole('<%=pernum%>','User');">
					<option>Alternate VO</option>
					<option selected>User</option>
				</select>
			</td>
			<%
				}
			%>
            </tr>
<%
			newbackcolor = backcolor;
			backcolor = oldbackcolor; 
			oldbackcolor = newbackcolor;
			} while (Reg2.myResult.next());
		  } catch (java.lang.Exception ex) {
			ex.printStackTrace();
		  } //try
%>		  
	</table>  
	</form>

	<input id="btSave" type="button" value="Apply" name=""  onClick="SetNewValues()" onDblClick="screenDupFlagOK = false">
	<br/>
	<br/>
	<br/>
	<br/>
<%		}
	else{
%>		
<h1>No subordinate found!</h1>
<%		}
	}
	else{
%>		
<h1>No right to edit attendance!</h1>
<%		}
%>


<%	} else { %>
  <%@ include file="../ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 
Reg2.close();      //cleaning up open connections 
%>
