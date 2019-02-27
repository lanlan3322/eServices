<%@ page contentType="text/html" %>
<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="java.text.*" %>
<%@page import="org.json.JSONObject" %>
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="page" />
<jsp:useBean id = "Reg2"
     class="ess.AdisoftDbase"
     scope="page" />

	 <jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
	 <%

// these are used in conjunction with the SQL found in system.xml
	Reg.setConnection(PersFile.getConnection()); 
	Reg.setSQLTerminator(PersFile.getSQLTerminator()); 
	Reg2.setConnection(PersFile.getConnection()); 
	Reg2.setSQLTerminator(PersFile.getSQLTerminator()); 
     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
     String newbackcolor;
        DateFormat df = new SimpleDateFormat("dd/MM/yyyy");
		Calendar cal = Calendar.getInstance();
		cal.add(Calendar.DATE, -7);
		java.util.Date startdate = cal.getTime();
	   String begDateStr = df.format(startdate);//request.getParameter("newLeaveFrom");
		cal.add(Calendar.MONTH, 1);
		java.util.Date enddate = cal.getTime();
	   String endDateStr = df.format(enddate);request.getParameter("newLeaveTo");
	   String begDateSQL = "";
	   String endDateSQL = "";
	   if (begDateStr != null && !begDateStr.equals("")) begDateSQL = Dt.getSQLDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
	   if (endDateStr != null && !endDateStr.equals("")) endDateSQL = Dt.getSQLDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));
		String name = "";
		String pernum = "";
		List empdetails = new LinkedList();
        JSONObject empObj = null;
		String SQLCommand3 = "SELECT PERS_NUM, FNAME, LNAME FROM USER";
		SQLCommand3 += " WHERE MANAGER = '" + PersFile.persnum + "' AND ACTIVE = '1'";
		SQLCommand3 += PersFile.getSQLTerminator();		
		if (Reg2.setResultSet(SQLCommand3)) {
			%>
     <h1>Attendance from <%=begDateSQL%> to <%=endDateSQL%>:</h1>
	 <%
			try {
			 do { 
				pernum = PersFile.getTrim(Reg2.myResult.getString(1));
				name = PersFile.getTrim(Reg2.myResult.getString(2));
				name += " ";
				name += PersFile.getTrim(Reg2.myResult.getString(3));
				String SQLCommand2 = "SELECT LEAVE_TYPE, LEAVE_NUM, LEAVE_STATUS, LEAVE_FROM, LEAVE_FROM_AMPM, LEAVE_TO, LEAVE_TO_AMPM, LEAVE_REASON FROM LEAVERECORD WHERE PERS_NUM = '";
				SQLCommand2 += pernum;
				SQLCommand2 += "' AND LEAVE_STATUS <> 'Cancelled' AND LEAVE_STATUS <> 'Rejected' AND LEAVE_STATUS <> 'Credit' AND LEAVE_STATUS <> 'Offset";
				SQLCommand2 += "' AND (LEAVE_TO BETWEEN '" + begDateSQL + "' AND '" + endDateSQL + "'";
				SQLCommand2 += " OR LEAVE_FROM BETWEEN '" + begDateSQL + "' AND '" + endDateSQL + "')";
				SQLCommand2 += PersFile.getSQLTerminator();
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
							
								newbackcolor = backcolor;
								backcolor = oldbackcolor; 
								oldbackcolor = newbackcolor;
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
		<div id="chartAttendance"></div>
		<script type="text/javascript">
            var queryObject=<%=empdetails%>;
            var queryObjectLen=queryObject.length;
            google.charts.load("current", {packages:["timeline"]});
            google.charts.setOnLoadCallback(drawChart);
            function drawChart() {
				var container = document.getElementById('chartAttendance');
				var chart = new google.visualization.Timeline(container);
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
					width: 988,
					height: 500,
					timeline: { 
						rowLabelStyle: {fontName: 'Helvetica', fontSize: 16, color: '#603913' },
						barLabelStyle: { fontName: 'Garamond', fontSize: 10 } 
						},
					tooltip: {isHtml: true},
					hAxis: {
						format: 'd/MM/yy',
					}
				};
				chart.draw(data,options);
			}	
			function roundToHalf(value) { 
			   var decimal = (value - Math.round(value)); 
			   decimal = Math.round(decimal * 10); 
			   if (decimal == 2) { return (Math.round(value)+0.5); } 
			   if (decimal == 4) { return (Math.round(value)+1.0); } 
			} 			
			function createCustomHTMLContent(name,start,end,status,reason) {
					var fullname = name;
                    var hours = Math.abs(start - end) / (1000*3600*24);
					hours = roundToHalf(hours);
					var options = {
							weekday: "long", year: "numeric", month: "short",
							day: "numeric", hour: "2-digit", minute: "2-digit"
						};
					var startStr = start.toLocaleTimeString("en-us", options);
					var endStr = end.toLocaleTimeString("en-us", options);
					var n = fullname.indexOf("/");
					if(n > 0)
					{
						fullname = fullname.substring(0,n-2);
					}
				  return '<div style="padding:5px 5px 5px 5px;">' +
					  '<img src="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/images/photos/' + fullname + '.jpg" style="width:60px;height:80px"><br/>' +
					  '<table class="medals_layout">' + '<tr>' +
					  '<td>From:</td><td>' + startStr + '</td></tr>' + '<tr>' +
					  '<td>To:</td><td>' + endStr + '</td></tr>' + '<tr>' +
					  '<td>Reason:</td><td>' + reason + '</td></tr>' + '<tr>' +
					  '<td>Status:</td><td><b>' + status + '</b></td></tr>' + '<tr>' +
					  '<td>Total days:</td><td><b>' + hours + '</b></td>' + '</tr>' + '</table>' + '</div>';
			}			
		</script>

	<%
		}
		
		Reg.close();      //cleaning up open connections 
		Reg2.close();
%>

