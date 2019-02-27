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
<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
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
   //String persnumber = PersFile.persnum;    //need to replace with a PersFile.get...()
	   SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	   String todayDateStr = sdf.format(new java.util.Date());
	   //String endDateStr = sdf.format(new java.util.Date());
	   String begDateStr = request.getParameter("begdate");
	   String endDateStr = begDateStr;
	   String begDateSQL = "";
	   String endDateSQL = "";
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
	   if (begDateStr != null && !begDateStr.equals("")) begDateSQL = Dt.getSQLDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
	   if (endDateStr != null && !endDateStr.equals("")) endDateSQL = Dt.getSQLDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));
		String name = "";
		String pernum = "";
		String depart = "";
		List empdetails = new LinkedList();
        JSONObject empObj = null;
		String SQLCommand3 = "SELECT PERS_NUM, FNAME, LNAME, DEPART FROM USER";
		SQLCommand3 += " WHERE ACTIVE = '1'";		
		SQLCommand3 += " ORDER BY DEPART ASC";		
		SQLCommand3 += PersFile.getSQLTerminator();		
		if (Reg2.setResultSet(SQLCommand3)) {
			try {%>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">

	  </head>
     <body>
     <h1>Daily Attendance:(<%=begDateStr%>)</h1>
     <form>
	<p><input type="button" value="Apply" name="B1"onClick="Javascript: void SetNewValues()">&nbsp; <span class="ExpenseTag">Click &quot;Apply&quot; to change the red color attendance and pending leave will be created for user to apply.</span></p>
     <table id="previousTable" border="0" cellspacing="0" cellpadding="0">
     <thead>
         <tr>
             <th width="10%" <%=backcolor%> align="left">Depart</th>
             <th width="20%" <%=backcolor%> align="left">Name</th>
             <th width="20%" <%=backcolor%>>Current</th>
             <th width="30%" <%=backcolor%> align="left">Change To</th>
            <th width="15%" <%=backcolor%> align="left">Leave Period(AM/PM)</th>
            <th width="5%" <%=backcolor%>></th>
         </tr>
     </thead>
<%			newbackcolor = backcolor;
			backcolor = oldbackcolor; 
			oldbackcolor = newbackcolor;
			do { 
				pernum = PersFile.getTrim(Reg2.myResult.getString(1));
				name = PersFile.getTrim(Reg2.myResult.getString(2));
				name += " ";
				name += PersFile.getTrim(Reg2.myResult.getString(3));
				depart = PersFile.getTrim(Reg2.myResult.getString(4));
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
			SQLCommand2 = "SELECT SUPER FROM DEPART WHERE DEPART = '";
			SQLCommand2 += depart;
			SQLCommand2 += "'";
			SQLCommand2 += DBSQLTerminator;
				if (Reg.setResultSet(SQLCommand2)) {
					try {
						if(PersFile.getTrim(Reg.myResult.getString(1)).equals("0")){
							leavetype = "";
						}
					} catch (java.lang.Exception ex) {
						%>
							<h2>Error in the SQL logic Attendance.jsp - contact support.<h2>
						<%  
					} //try
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
            <td width="10%" <%=backcolor%>><%= depart%></td>
            <td width="20%" <%=backcolor%> align="left"><%= name%></td>
            <td width="20%" <%=backcolor%> align="center"><%= leavetype%></td>
            <td width="30%" <%=backcolor%>>
			<select id="<%=pernum%>" onChange="Change('<%=pernum%>','<%= leavetype%>');"><%=selectionList%></select>
			</td>
			<td width="15%"  <%=backcolor%> align="left">
			<select id="<%=pernum%>AMPM" onChange="ChangeHalfday('<%=pernum%>','<%= leavetype%>');">
				<%=selectionListAMPM%>
			</select>
			</td>
            <td width="5%"  <%=backcolor%>>
				<input type="checkbox" id="<%=pernum%>select_this_item" style="display: none" value="">
			</td>
            </tr>
<%
			newbackcolor = backcolor;
			backcolor = oldbackcolor; 
			oldbackcolor = newbackcolor;
			} while (Reg2.myResult.next());
		  } catch (java.lang.Exception ex) {
			ex.printStackTrace();
		  } //try
		}
%>
	</table>  
	<p><input type="button" value="Apply" name="B1"onClick="Javascript: void SetNewValues()">&nbsp; <span class="ExpenseTag">Click &quot;Apply&quot; to change the red color attendance and pending leave will be created for user to apply.</span></p>
	</form>
	
      <form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/edit/AttendanceConfirm.jsp">
        <input type="hidden" name="email" value>
        <input type="hidden" name="database" value>
        <input type="hidden" name="company" value>
        <input type="hidden" name="ccode" value>
        <input type="hidden" name="reference" value>
        <input type="hidden" name="xaction" value="apply">
        <input type="hidden" name="type" value=>
        <input type="hidden" name="dateSelected" value=	<%=begDateStr%>>
      </form>
</body>
     <script>
      function Change(num,t){
		  var obj = document.getElementById(num);
		  var obj2 = document.getElementById(num + "AMPM");
        if(obj.options[obj.selectedIndex].value != t)
		{
			document.getElementById(num).style.backgroundColor = "red";
			document.getElementById(num + "select_this_item").checked = true;
			document.getElementById(num + "select_this_item").value = num + "," + obj.options[obj.selectedIndex].value + "," + obj2.options[obj2.selectedIndex].value;
		}
		else
		{
			document.getElementById(num).style.backgroundColor = "initial";
			document.getElementById(num + "select_this_item").checked = false;
			document.getElementById(num + "select_this_item").value = "";
		}
      }
		function ChangeHalfday(num,t){
		  var obj = document.getElementById(num);
		  var obj2 = document.getElementById(num + "AMPM");
			if(obj2.options[obj2.selectedIndex].value != "")
			{
				document.getElementById(num + "AMPM").style.backgroundColor = "red";
				document.getElementById(num + "select_this_item").checked = true;
				document.getElementById(num + "select_this_item").value = num + "," + obj.options[obj.selectedIndex].value + "," + obj2.options[obj2.selectedIndex].value;
			}
			else
			{
				document.getElementById(num + "AMPM").style.backgroundColor = "initial";
				document.getElementById(num + "select_this_item").checked = false;
				document.getElementById(num + "select_this_item").value = "";
			}
		}
		
		function SetNewValues(){
			var delim = "";
			  document.forms[1].name.value = parent.contents.getDBValue(parent.Header,"name");
			  //reference was here
			  document.forms[1].reference.value = "";
			  document.forms[1].email.value = parent.contents.getDBValue(parent.Header,"email");
			  document.forms[1].company.value = parent.company;
			  document.forms[1].database.value = parent.database;
			  document.forms[1].ccode.value = parent.CCode;
			  document.forms[1].xaction.value = "apply";
			for (var i = 0; i < document.forms[0].length; i++) {
				 if (document.forms[0].elements[i].id.indexOf("select_this_item") && document.forms[0].elements[i].checked == true) {
				   document.forms[1].reference.value += delim + document.forms[0].elements[i].value;
				   delim = ";";   
				 }
			}
			/*if (delim == ";") {
				document.forms[1].submit();

			} else {
			  alert("There is no change!");
			}*/
				document.forms[1].submit();
		}
      </script>
	  </html>
<%	} else { %>
  <%@ include file="../ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 
Reg2.close();      //cleaning up open connections 
%>




