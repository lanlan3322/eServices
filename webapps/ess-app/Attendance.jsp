<%@ page contentType="text/html" %>
<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="org.json.JSONObject" %>
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

<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="NumericSetup.jsp" %>
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
<%@ include file="StatusInfo.jsp" %>
<%
Log.println("[000] ReportList.jsp 2");
%>
<%@ include file="SystemInfo.jsp" %>
<%@ include file="../SendAnEmail.jsp" %>
<%

// these are used in conjunction with the SQL found in system.xml
   //String persnumber = PersFile.persnum;    //need to replace with a PersFile.get...()
	String depart = request.getParameter("departToRun");
	String person = request.getParameter("person");
	String typeToRun = request.getParameter("typeToRun");
	String statusToRun = request.getParameter("statusToRun");
	   String begDateStr = request.getParameter("begdate");
	   String endDateStr = request.getParameter("enddate");
	   String begDateSQL = "";
	   String endDateSQL = "";
	   String SQLCommand2 = "";
	   if (begDateStr != null && !begDateStr.equals("")) begDateSQL = Dt.getSQLDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
	   if (endDateStr != null && !endDateStr.equals("")) endDateSQL = Dt.getSQLDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));
		String name = "";
		String pernum = "";
		List empdetails = new LinkedList();
        JSONObject empObj = null;
		String SQLCommand3 = "SELECT PERS_NUM, FNAME, LNAME FROM USER";
		SQLCommand3 += " WHERE ACTIVE = '1'";		
		if(person != null && !person.equals("")){
			SQLCommand3 += " AND PERS_NUM = '" + person + "'";
			depart = "";
		}
		else if(depart != null && !depart.equals("All")){
			SQLCommand3 += " AND DEPART = '" + depart + "'";
			person = "";
		}
		SQLCommand3 += PersFile.getSQLTerminator();		
		if (Reg2.setResultSet(SQLCommand3)) {
			try {
			 do { 
				pernum = PersFile.getTrim(Reg2.myResult.getString(1));
				name = PersFile.getTrim(Reg2.myResult.getString(2));
				name += " ";
				name += PersFile.getTrim(Reg2.myResult.getString(3));
				SQLCommand2 = "SELECT LEAVE_TYPE, LEAVE_NUM, LEAVE_STATUS, LEAVE_FROM, LEAVE_FROM_AMPM, LEAVE_TO, LEAVE_TO_AMPM, LEAVE_REASON FROM LEAVERECORD WHERE PERS_NUM = '";
				SQLCommand2 += pernum + "'";
				if(typeToRun != null && !typeToRun.equals("All")){
					SQLCommand2 += " AND LEAVE_TYPE = '" + typeToRun + "'";
				}
				if(statusToRun != null && !statusToRun.equals("All")){
					SQLCommand2 += " AND LEAVE_STATUS = '" + statusToRun + "'";
				}
				else{
					SQLCommand2 += " AND LEAVE_STATUS <> 'Cancelled' AND LEAVE_STATUS <> 'Rejected' AND LEAVE_STATUS <> 'Credit' AND LEAVE_STATUS <> 'Offset'";
				}
				SQLCommand2 += " AND (LEAVE_TO BETWEEN '" + begDateSQL + "' AND '" + endDateSQL + "'";
				SQLCommand2 += " OR LEAVE_FROM BETWEEN '" + begDateSQL + "' AND '" + endDateSQL + "')";
				SQLCommand2 += DBSQLTerminator;
				if (Reg.setResultSet(SQLCommand2)) {
					String leavetype;
					String leavestart;
					String leavestartampm;
					String leaveend;
					String leaveendampm;
					String leavestatus;
					String leaveNum;
					String leaveReason;
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
					empObj.put("leavetype", "No leave record found");
					empObj.put("start", begDateSQL);
					empObj.put("startampm", "AM");
					empObj.put("end", endDateSQL);
					empObj.put("endampm", "PM");
					empObj.put("status", "In office");
					empObj.put("reason", "Working very hard");
					empdetails.add(empObj);
				}
			 } while (Reg2.myResult.next());
		  } catch (java.lang.Exception ex) {
			ex.printStackTrace();
		  } //try
	    %>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     <link rel="stylesheet" media="print" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/print.css" type="text/css">
     <title><%= Lang.getString("LEAVE_HISTORY")%></title>
	<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
        <script type="text/javascript" src="https://www.google.com/jsapi"></script>
		<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
     </head>
     <body>
     <h1><%= Lang.getString("LEAVE_HISTORY")%></h1> 
	 Person:<%=person%>; Department:<%=depart%>; Leave Type:<%=typeToRun%>;  Leave Status:<%=statusToRun%>
<div id="chartAttendance" style="height: 100%; width: 100%;"></div>
		<script type="text/javascript">
            var queryObject=<%=empdetails%>;
            var queryObjectLen=queryObject.length;
            google.charts.load("current", {packages:["timeline"]});
            google.charts.setOnLoadCallback(drawChart);
            function drawChart() {
				var data = new google.visualization.DataTable();
				data.addColumn({ type: 'string', id: 'name' });
				data.addColumn({ type: 'string', id: 'leavetype' });
				data.addColumn({type: 'string', role: 'tooltip', 'p': {'html': true}});
				data.addColumn({ type: 'datetime', id: 'start' });
				data.addColumn({ type: 'datetime', id: 'end' });
                for(var i=0;i<queryObjectLen;i++)
                {
                    var name = queryObject[i].name;
                    var leavetype = queryObject[i].leavetype;
                    var status = queryObject[i].status;
                    var reason = queryObject[i].reason;
					var startampm = (queryObject[i].startampm == "AM")?9:14;
					var endampm = (queryObject[i].endampm == "AM")?13:18;
					var startDate = new Date(queryObject[i].start);
					var endDate = new Date(queryObject[i].end);
                    var start = new Date(startDate.getFullYear(),startDate.getMonth(),startDate.getDate(),startampm,0,0);
                    var end = new Date(endDate.getFullYear(),endDate.getMonth(),endDate.getDate(),endampm,0,0);
					var tooltip = createCustomHTMLContent(name,start,end,status,reason);
					data.addRows([
						[name,leavetype,tooltip,start,end]
                    ]);
                }
                var options = {
					height: 900,
					tooltip: {isHtml: true},
                    title: 'Attendance History',
					  hAxis: {
						format: 'd/M/yy',
					  },
				};
				
			var container = document.getElementById('chartAttendance');
			var chart = new google.visualization.Timeline(container);

			chart.draw(data,options);
			}	
			function roundToHalf(value) { 
			   var decimal = (value - Math.round(value)); 
			   decimal = Math.round(decimal * 10); 
			   if (decimal == 2) { return (Math.round(value)+0.5); } 
			   if (decimal == 4) { return (Math.round(value)+1.0); } 
			} 			
			function createCustomHTMLContent(name,start,end,status,reason) {
                    var hours = Math.abs(start - end) / (1000*3600*24);
					hours = roundToHalf(hours);
					var options = {
							weekday: "long", year: "numeric", month: "short",
							day: "numeric", hour: "2-digit", minute: "2-digit"
						};
					var startStr = start.toLocaleTimeString("en-us", options);
					var endStr = end.toLocaleTimeString("en-us", options);
					var n = name.indexOf("/");
					if(n > 0)
					{
						name = name.substring(0,n-2);
					}
				  return '<div style="padding:5px 5px 5px 5px;">' +
					  '<img src="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/images/photos/' + name + '.jpg" style="width:100px;height:128px"><br/>' +
					  '<table class="medals_layout">' + '<tr>' +
					  '<td>From:</td><td>' + startStr + '</td></tr>' + '<tr>' +
					  '<td>To:</td><td>' + endStr + '</td></tr>' + '<tr>' +
					  '<td>Reason:</td><td>' + reason + '</td></tr>' + '<tr>' +
					  '<td>Status:</td><td><b>' + status + '</b></td></tr>' + '<tr>' +
					  '<td>Total days:</td><td><b>' + hours + '</b></td>' + '</tr>' + '</table>' + '</div>';
			}			
		</script>
     
    </body>
    </html>
<%
		}
		else{
%>
  <h1>No result found!</h1> 
	 Person:<%=person%>; Department:<%=depart%>; Leave Type:<%=typeToRun%>;  Leave Status:<%=statusToRun%>
<%			
		}
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



