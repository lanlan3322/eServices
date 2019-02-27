<%@ page contentType="text/html" %>
<%@page import="java.sql.*" %>
<%@page import="java.util.*" %>
<%@page import="java.text.SimpleDateFormat"%>
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
<jsp:useBean id = "TableDOM"
     class="ess.AdisoftDOM"
     scope="page" />

<%@ include file="edit/EditInfo.jsp" %>
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
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     <link rel="stylesheet" media="print" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/print.css" type="text/css">
     <title><%= Lang.getString("LEAVE_HISTORY")%></title>
	<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
        <script type="text/javascript" src="https://www.google.com/jsapi"></script>
		<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
	<style>
	td {
		padding: 15px;
	}
	.pagebreak {
		page-break-before: always;
	}
	</style>
	<script text="javascript">
	function pageReady(numDrawed)
	{
		var height = '80%';
		if(numDrawed > 50)
		{
			height = '250%';
		}
		else if(numDrawed > 30)
		{
			height = '180%';
		}
		else if(numDrawed > 10)
		{
			height = '120%';
		}
		document.getElementById('chartReport').style.height = height;
	}
	</script>

<script type="text/javascript">
function x(AddValue) {
  if (AddValue.length > 0) {
    parent.contents.setListBuffer(AddValue);
    parent.contents.TransWindow(parent.contents.defaultHome + 'edit/inventoryEdit.html','ListBuffer');
  } else {
    alert("System is not able to fulfill this request.\nPlease try again.\nIf problem persists, contact support.");
  }
}

</script>  
     </head>
     <body>
<%@ include file="StatusInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<%@ include file="../SendAnEmail.jsp" %>
<%@ include file="StandardBottom.jsp" %>
<%
	String editArray;
   String screenname = "userprimary_edit";
   String tableName = EditDOM.getDOMTableValueFor(screenname,"table"); 
   String sqlTableName = EditDOM.getDOMTableValueFor(screenname,"sqltable"); //JH 2007-05-24
   String schemaFileName = SystemDOM.getDOMTableValueFor("configuration","xmlschema");
   java.io.File schemaFile = new java.io.File(schemaFileName);
   TableDOM.setDOM(schemaFile);
   org.jdom.Element schemaElement = TableDOM.getElement(tableName);

   org.jdom.Element schemaColumns = schemaElement.getChild("columns");
   java.util.List columnList = schemaColumns.getChildren();

   org.jdom.Element schemaKey = schemaElement.getChild("key");
   java.util.List keyList = schemaKey.getChildren();

   org.jdom.Element tag;
   org.jdom.Attribute tagInfo;
   org.jdom.Attribute nameInfo;
   java.util.ArrayList columnValues; 
   String tagName;
   String otherName;
   String physicalName;
   String type;

   java.util.ArrayList logicalFields = new java.util.ArrayList();
   java.util.ArrayList dateFields = new java.util.ArrayList();

   java.util.ArrayList schemaNames = new java.util.ArrayList();
   java.util.ArrayList physicalNames = new java.util.ArrayList();

   for (int i = 0; i < columnList.size(); i++)
   {
      tag = (org.jdom.Element) columnList.get(i);
      tagName = tag.getName();
      nameInfo = tag.getAttribute("physical");
      if (nameInfo == null || nameInfo.getValue().trim().equals(""))
      {
         otherName = tagName;

      } else {
         otherName = nameInfo.getValue().trim();
      }
      physicalNames.add(otherName);
      schemaNames.add(tagName);

      tagInfo = tag.getAttribute("type");
      type = tagInfo.getValue();
      if (type.equals("logical")) logicalFields.add(tagName);
      if (type.equals("date")) dateFields.add(tagName);
   }
   String[] logicals = set2ArrayFromAL(logicalFields); 
   String[] dates = set2ArrayFromAL(dateFields); 
   String[] physicals = set2ArrayFromAL(physicalNames); 
   String[] schemas = set2ArrayFromAL(schemaNames); 
	//String persnumber = PersFile.persnum;    //need to replace with a PersFile.get...()
	String depart = request.getParameter("departToRun");
	String person = request.getParameter("persnum");
	String begDateStr = request.getParameter("begdate");
	String endDateStr = request.getParameter("enddate");
	String typeToRun = request.getParameter("typeToRun");
	SimpleDateFormat mdyFormat = new SimpleDateFormat("dd/MM/yyyy");
	java.util.Date dateFrom = mdyFormat.parse(begDateStr);
	java.util.Date dateTo = mdyFormat.parse(endDateStr);
	int differenceInDays = (int) ((dateTo.getTime() - dateFrom.getTime())/(1000*60*60*24));
	String begDateSQL = "";
	String endDateSQL = "";
	String infoName = "";
	String infoNameLast = "";
	String infoDepart = "";
	String infoPhone = "";
	String infoServDate = "";
	String infoEmail = "";
	if (begDateStr != null && !begDateStr.equals("")) begDateSQL = Dt.getSQLDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
	if (endDateStr != null && !endDateStr.equals("")) endDateSQL = Dt.getSQLDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));
	String name = "";
	String mode = "General";
	if(typeToRun != null && !typeToRun.equals("All")){
		mode = "Type";
	}
	else if(person != null && !person.equals("")){
		mode = "User";
	}
	else if(depart != null && !depart.equals("All")){
		mode = "Depart";
	}
	List empdetails = new LinkedList();
	List userdetails = new LinkedList();
    JSONObject empObj = null;
	String SQLCommand = request.getParameter("reporttype") + PersFile.getSQLTerminator();		
	SQLCommand = Reg.SQLReplace(SQLCommand,"$begdate$",begDateSQL);
	SQLCommand = Reg.SQLReplace(SQLCommand,"$enddate$",endDateSQL);
	if (Reg.setResultSet(SQLCommand)) {
		String leavePersNum;
		String leaveDepart;
		String leaveVO;
		String leaveNum;
		String leaveTotal;
		String leaveCreated;
		String leaveType;
		String leaveStart;
		String leaveStartampm;
		String leaveEnd;
		String leaveEndampm;
		String leaveStatus;
		String leaveReason;
		 String backcolor = "class=\"TableData offsetColor\"";
		 String oldbackcolor = "class=\"TableData\"";
		 String newbackcolor;
		java.sql.ResultSetMetaData MetaData = Reg.myResult.getMetaData();
		int numberOfColumns = MetaData.getColumnCount();
				%>
				 <table id="previousTable" border="1" cellspacing="0" cellpadding="0">
				 <thead>
					 <tr>
						<th class="ExpenseTag" width="10%" <%=backcolor%>><u>Name</u></th>
						<th class="ExpenseTag" width="20%" <%=backcolor%>><u>Date</u></th>
						<th class="ExpenseTag" width="50%" <%=backcolor%>><u>Reason</u></th>
						<th class="ExpenseTag" width="10%" <%=backcolor%>><u>Status</u></th>
						<th class="ExpenseTag" width="10%" <%=backcolor%>><u>Type</u></th>
						<th width="5%" ></th>
					 </tr>
				 </thead>
				 <%
				newbackcolor = backcolor;
				backcolor = oldbackcolor; 
				oldbackcolor = newbackcolor;
		try {
			do { 
				/*leavePersNum = PersFile.getTrim(Reg.myResult.getString(1));
				leaveDepart = PersFile.getTrim(Reg.myResult.getString(2));
				leaveVO = PersFile.getTrim(Reg.myResult.getString(3));
				leaveNum = PersFile.getTrim(Reg.myResult.getString(4));
				leaveTotal = PersFile.getTrim(Reg.myResult.getString(5));
				leaveCreated = PersFile.getTrim(Reg.myResult.getString(6));
				leaveType = PersFile.getTrim(Reg.myResult.getString(7));
				leaveStart = PersFile.getTrim(Reg.myResult.getString(8));
				leaveStartampm = PersFile.getTrim(Reg.myResult.getString(9));
				leaveEnd = PersFile.getTrim(Reg.myResult.getString(10));
				leaveEndampm = PersFile.getTrim(Reg.myResult.getString(11));
				leaveStatus = PersFile.getTrim(Reg.myResult.getString(12));
				leaveReason = PersFile.getTrim(Reg.myResult.getString(13));
				if(!leaveStatus.equals("Cancelled") && !leaveStatus.equals("Rejected") && !leaveStatus.equals("Credit") && !leaveStatus.equals("Offset"))
				{
					empObj = new JSONObject();
					empObj.put("leavePersNum", leavePersNum);
					empObj.put("leaveDepart", leaveDepart);
					empObj.put("leaveVO", leaveVO);
					empObj.put("leaveNum", leaveNum);
					empObj.put("leaveTotal", leaveTotal);
					empObj.put("leaveCreated", leaveCreated);
					empObj.put("leaveType", leaveType);
					empObj.put("leaveStart", leaveStart);
					empObj.put("leaveStartampm", leaveStartampm);
					empObj.put("leaveEnd", leaveEnd);
					empObj.put("leaveEndampm", leaveEndampm);
					empObj.put("leaveStatus", leaveStatus);
					empObj.put("leaveReason", leaveReason);
					empObj.put("leavePeriodFrom", begDateSQL);
					empObj.put("leavePeriodTo", endDateSQL);
					empdetails.add(empObj);
				}*/
     %>          
            <tr>
<%
		String OPERATION_ID=PersFile.getTrim(Reg.myResult.getString(1));
		String OPERATION_BY=PersFile.getTrim(Reg.myResult.getString(2));
		String OPERATION_CREATED=PersFile.getTrim(Reg.myResult.getString(3));
		String OPERATION_DELIVERED=PersFile.getTrim(Reg.myResult.getString(4));
		String OPERATION_PREPARED=PersFile.getTrim(Reg.myResult.getString(5));
		String OPERATION_SIGNED=PersFile.getTrim(Reg.myResult.getString(6));
		String OPERATION_REASON=PersFile.getTrim(Reg.myResult.getString(7));
		String OPERATION_STATUS=PersFile.getTrim(Reg.myResult.getString(8));
		String OPERATION_TYPE=PersFile.getTrim(Reg.myResult.getString(9));
        editArray = getArrayString(MetaData, Reg, Log, schemas, physicals, logicals, dates, Dt);
			String SQLCommand3 = "SELECT FNAME FROM USER WHERE PERS_NUM =";
			SQLCommand3 += OPERATION_BY + PersFile.getSQLTerminator();
			if (Reg2.setResultSet(SQLCommand3)) {
%>
			<td width="10%" bgcolor="#42c5f4"><%= PersFile.getTrim(Reg2.myResult.getString(1))%></td>
			<%}else{%>
            <td width="10%" bgcolor="#42c5f4"><%= OPERATION_BY%></td>
			<%}%>
				<td width="20%" bgcolor="#42c5f4"><%= OPERATION_CREATED%></td>
				<td width="50%" bgcolor="#42c5f4"><%= OPERATION_REASON%></td>
				<td width="10%" bgcolor="#42c5f4"><%= OPERATION_STATUS%></td>
				<td width="10%" bgcolor="#42c5f4"><%= OPERATION_TYPE%></td>
				<td width="5%" bgcolor="#42c5f4"><a href="javascript: void x(<%= editArray %>)"><span class="ExpenseReturnLink">Edit</span></a></td>
            </tr>
	 <%          //xfound = true;
				newbackcolor = backcolor;
				backcolor = oldbackcolor; 
				oldbackcolor = newbackcolor;
				//starting of getting items
				String dinnerDate = "";
				String SQLGetDinnerDate;
				String bgcolor = backcolor;
				/*SQLGetDinnerDate = "SELECT ";
				SQLGetDinnerDate += "EXP_DATE ";
				SQLGetDinnerDate += "FROM EXPENSE ";
				SQLGetDinnerDate += "WHERE VOUCHER = '" + voucher + "'";
				SQLGetDinnerDate += " AND (EXPENSE = 'DINNER' OR EXPENSE = 'LUNCH')";
				SQLGetDinnerDate += PersFile.getSQLTerminator();*/
		
				SQLGetDinnerDate = "SELECT DB_ITEM.ITEM_NAME, DB_ITEM.ITEM_CATEGORY, DB_ITEM.ITEM_DESC, DB_OPERATED_ITEM.REF_AMOUNT_ITEM FROM DB_ITEM JOIN DB_OPERATED_ITEM ON DB_ITEM.ITEM_ID = DB_OPERATED_ITEM.REF_ID_ITEM WHERE TRIM(DB_OPERATED_ITEM.REF_ID_OPERATION) = " + OPERATION_ID;
				SQLGetDinnerDate += PersFile.getSQLTerminator();
				if (Reg2.setResultSet(SQLGetDinnerDate)) {
					try {
						do { 
							String sName = PersFile.getTrim(Reg2.myResult.getString(1));
							String sCat = PersFile.getTrim(Reg2.myResult.getString(2));
							String sDesc = PersFile.getTrim(Reg2.myResult.getString(3));
							String sAmount = PersFile.getTrim(Reg2.myResult.getString(4));

		 %>
						<tr>
						<td width="10%">&nbsp;</td>
						<td width="20%" <%=backcolor%>><%= sName%></td>
						<td width="50%" <%=backcolor%>><%= sDesc%></td>
						<td width="10%" <%=backcolor%> align="center"><%= sCat%></td>
						<td width="10%"  <%=backcolor%>><%= sAmount%></td>
						</tr>
		 <%     			//xfound = true;
							newbackcolor = backcolor;
							backcolor = oldbackcolor;
							oldbackcolor = newbackcolor;
						} while (Reg2.myResult.next());
					} catch (java.lang.Exception ex) {
							Log.println("[500] AuditList.jsp SQLGetDinnerDate Error");
							Log.println("[500] AuditList.jsp - " + ex.toString());
							ex.printStackTrace();
				%>
							<h1>Error in the SQLGetDinnerDate - contact support.<br></h1>
				<%  
					} //try
				}    
            newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;
		} while (Reg.myResult.next());
%>
            </table>
			
			<div class="pagebreak"  style="display:none">
			<%			
			if(mode.equals("Type")){
				String SQLCommand1 = "SELECT FNAME,LNAME,PERS_NUM FROM USER";
				if(depart != null && !depart.equals("All")){
					SQLCommand1 += " WHERE DEPART = '" + depart + "'";
					%>
					<h1><%=typeToRun%> Leave Report for Department: <%=depart%> (From:<%=begDateSQL%> To:<%=endDateSQL%>):<h1><br/>
					<%
				}
				else{
					%>
					<h1><%=typeToRun%> Leave Report for company: (From:<%=begDateSQL%> To:<%=endDateSQL%>):<h1><br/>
					<%
				}

				SQLCommand1 += " ORDER BY FNAME";
				SQLCommand1 += PersFile.getSQLTerminator();		
				String infoNameFirst;
				String infoPersNum;
				if (Reg2.setResultSet(SQLCommand1)) {
					try {
						do { 
							infoNameFirst = PersFile.getTrim(Reg2.myResult.getString(1));
							infoNameLast = PersFile.getTrim(Reg2.myResult.getString(2));
							infoPersNum = PersFile.getTrim(Reg2.myResult.getString(3));
							empObj = new JSONObject();
							empObj.put("infoNameFirst", infoNameFirst);
							empObj.put("infoNameLast", infoNameLast);
							empObj.put("infoPersNum", infoPersNum);
							userdetails.add(empObj);
						} while (Reg2.myResult.next());
					} catch (java.lang.Exception ex) {
							%>
								<h2>Error in the SQL logic ReportLeave.jsp - contact support.<h2>
							<%  
					} //try				
				}
				%>
				<div id="chartReport" style="width: 90%;"></div>
					<script type="text/javascript">
					var numDrawed = 0;
					google.charts.load('current', {packages: ['corechart', 'bar']});
					google.charts.setOnLoadCallback(drawStacked);

					function drawStacked() {
						var queryObject=<%=empdetails%>;
						var queryObjectLen=queryObject.length;
						var userObject=<%=userdetails%>;
						var userObjectLen=userObject.length;
						var leaveTotalNum = [];
						for(var j=0;j<userObjectLen;j++)
						{
							leaveTotalNum[j] = 0;
							for(var k=0;k<queryObjectLen;k++)
							{
								if(userObject[j].infoPersNum == queryObject[k].leavePersNum)
								{
									leaveTotalNum[j] = Number(leaveTotalNum[j]) + Number(queryObject[k].leaveTotal);
								}
							}
						}

						var data = new google.visualization.DataTable();
						data.addColumn('string', 'User'); // Implicit domain column.
						data.addColumn('number', 'Type');
						//data.addColumn({type: 'string', role: 'tooltip', 'p': {'html': true}});
						
						for(var i=0;i<userObjectLen;i++)
						{
							//var tooltip = createCustomHTMLContent(name,start,end,status,reason);
							if(leaveTotalNum[i] > 0)
							{
								numDrawed++;
								data.addRows([
									 [userObject[i].infoNameFirst,Number(leaveTotalNum[i])] 
								   ]);
							}
						}
						var options = {
							title: 'Leave Usage',
							chartArea: {top: '5%', width: '70%', height: '80%'},
							isStacked: true,
							legend: {position: 'none'},
							hAxis: {
							  title: 'Total Leave (days)',
							  minValue: 0,
							  minorGridlines: {count: 1}
							},
							vAxis: {
							  title: 'Users',
							}
						  };
						  pageReady(numDrawed);
						  var chart = new google.visualization.BarChart(document.getElementById('chartReport'));
						  chart.draw(data, options);
						}	
					</script>
<%
			}			
			else if(mode.equals("User")){
				String SQLCommand3 = "SELECT FNAME,DEPART,PHONE,SERVDATE,EMAIL,LNAME FROM USER";
				SQLCommand3 += " WHERE PERS_NUM = '" + person + "'";
				SQLCommand3 += PersFile.getSQLTerminator();		
				if (Reg2.setResultSet(SQLCommand3)) {
					infoName = PersFile.getTrim(Reg2.myResult.getString(1));
					infoDepart = PersFile.getTrim(Reg2.myResult.getString(2));
					infoPhone = PersFile.getTrim(Reg2.myResult.getString(3));
					infoServDate = PersFile.getTrim(Reg2.myResult.getString(4));
					infoEmail = PersFile.getTrim(Reg2.myResult.getString(5));
					infoNameLast = PersFile.getTrim(Reg2.myResult.getString(6));
					infoName += " " + infoNameLast;
					int n = infoName.indexOf("/");
					if(n > 0)
					{
						infoName = infoName.substring(0,n-2);
					}
				}
			%>
				<h1>Leave Report for user: <%=infoName%> (From:<%=begDateSQL%> To:<%=endDateSQL%>):<h1><br/>
				<table>
					<tr>
						<td><img src="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/images/photos/<%=infoName%>.jpg" style="width:100px;height:128px"></td>
						<td><h2>Name:<%=infoName%><br/>
						<br/>Depart:<%=infoDepart%><br/>
						<br/>Phone:<%=infoPhone%><br/>
						<br/>Join Date:<%=infoServDate%><br/>
						<br/>Email:<%=infoEmail%></h2></td>
					</tr>
				</table>
				<br/><div id="chartAttendance" style="height: 80%; width: 80%;"></div>
				<script type="text/javascript">
					var workingdays = <%=differenceInDays%>;
					var queryObject=<%=empdetails%>;
					var queryObjectLen=queryObject.length;
					google.charts.load('current', {'packages':['corechart']});
					google.charts.setOnLoadCallback(drawChart);
						function drawChart() {
							var leaveTypeList = parent.contents.getLeaveTypes();
							var typeNum = leaveTypeList.length;
							var leaveTypeTotal = [];
							for(var j=0;j<typeNum;j++)
							{
								leaveTypeTotal.push([0]);
								for(var i=0;i<queryObjectLen;i++)
								{
									var leaveRecordType = queryObject[i].leaveType;
									if(leaveRecordType == leaveTypeList[j]){
										leaveTypeTotal[j] = Number(leaveTypeTotal[j]) + Number(queryObject[i].leaveTotal);
									}
								}
								workingdays = workingdays - leaveTypeTotal[j];
							}

							var data = new google.visualization.DataTable();
							data.addColumn('string', 'Type');
							data.addColumn('number', 'Total');
							//data.addColumn({type: 'string', role: 'tooltip', 'p': {'html': true}});
							data.addRows([
								["Working",Number(workingdays)]
							]);
							for(var i=1;i<typeNum;i++)
							{
								data.addRows([
									[leaveTypeList[i].toString(),Number(leaveTypeTotal[i])]
								]);
							}

							var options = {
								tooltip: {isHtml: true},
								title: 'Total days:'+<%=differenceInDays%>,
								is3D: true,
							};
						
							var container = document.getElementById('chartAttendance');
							var chart = new google.visualization.PieChart(container);

							chart.draw(data,options);
						}			
				</script>
<%			}
			else{
				String SQLCommand1 = "SELECT FNAME,LNAME,PERS_NUM FROM USER";
				if(mode.equals("Depart")){
					SQLCommand1 += " WHERE DEPART = '" + depart + "'";
					%>
					<h1>Leave Report for Department: <%=depart%> (From:<%=begDateSQL%> To:<%=endDateSQL%>):<h1><br/>
					<%
				}
				else{
					%>
					<h1>Leave Report for company: (From:<%=begDateSQL%> To:<%=endDateSQL%>):<h1><br/>
					<%
				}
				SQLCommand1 += " ORDER BY DEPART";
				SQLCommand1 += PersFile.getSQLTerminator();		
				String infoNameFirst;
				String infoPersNum;
				if (Reg2.setResultSet(SQLCommand1)) {
					try {
						do { 
							infoNameFirst = PersFile.getTrim(Reg2.myResult.getString(1));
							infoNameLast = PersFile.getTrim(Reg2.myResult.getString(2));
							infoPersNum = PersFile.getTrim(Reg2.myResult.getString(3));
							empObj = new JSONObject();
							empObj.put("infoNameFirst", infoNameFirst);
							empObj.put("infoNameLast", infoNameLast);
							empObj.put("infoPersNum", infoPersNum);
							userdetails.add(empObj);
						} while (Reg2.myResult.next());
					} catch (java.lang.Exception ex) {
							%>
								<h2>Error in the SQL logic ReportLeave.jsp - contact support.<h2>
							<%  
					} //try				
				}
				%>
				<div id="chartReport" style="width: 90%;"></div>
<script type="text/javascript">
var numDrawed = 0;
google.charts.load('current', {packages: ['corechart', 'bar']});
google.charts.setOnLoadCallback(drawStacked);

function drawStacked() {
	var queryObject=<%=empdetails%>;
	var queryObjectLen=queryObject.length;
	var userObject=<%=userdetails%>;
	var userObjectLen=userObject.length;
	var leaveTypeList = parent.contents.getLeaveTypes();
	var typeNum = leaveTypeList.length;
	var leaveTypeTotal = [];
	var leaveTypeTotalList = [];
	var leaveTotalNum = [];
	for(var j=0;j<userObjectLen;j++)
	{
		leaveTypeTotalList[j] = "";
		leaveTotalNum[j] = 0;
		for(var i=1;i<typeNum;i++)
		{
			leaveTypeTotal[i] = 0;
			for(var k=0;k<queryObjectLen;k++)
			{
				if(queryObject[k].leaveType == leaveTypeList[i] && userObject[j].infoPersNum == queryObject[k].leavePersNum){
					leaveTypeTotal[i] = Number(leaveTypeTotal[i]) + Number(queryObject[k].leaveTotal);
				}
			}
			leaveTypeTotalList[j] += leaveTypeTotal[i] + ",";
			leaveTotalNum[j] += leaveTypeTotal[i];
		}
	}

	var data = new google.visualization.DataTable();
	data.addColumn('string', 'User'); // Implicit domain column.
	//data.addColumn({type: 'string', role: 'tooltip', 'p': {'html': true}});
    for(var n=1;n<typeNum;n++)
	{
		data.addColumn('number', leaveTypeList[n]);
	}
	
	for(var i=0;i<userObjectLen;i++)
	{
		//var tooltip = createCustomHTMLContent(name,start,end,status,reason);
		if(leaveTotalNum[i] > 0)
		{
			numDrawed++;
			var num = leaveTypeTotalList[i].split(",");
			   data.addRows([
				 [userObject[i].infoNameFirst,
				 Number(num[0]),  
				 Number(num[1]), 
				 Number(num[2]),
				 Number(num[3]),
				 Number(num[4]),
				 Number(num[5]),
				 Number(num[6]),
				 Number(num[7]),
				 Number(num[8]),
				 Number(num[9]),
				 Number(num[10]),
				 Number(num[11])],
			   ]);
		}
	}
    var options = {
		title: 'Leave Usage',
		chartArea: {top: '5%', width: '70%', height: '80%'},
        isStacked: true,
        hAxis: {
          title: 'Total Leave (days)',
          minValue: 0,
		  minorGridlines: {count: 1}
        },
        vAxis: {
          title: 'Users',
        }
      };
	  pageReady(numDrawed);
      var chart = new google.visualization.BarChart(document.getElementById('chartReport'));
      chart.draw(data, options);
    }	
				</script>
				</div>
				<%
			}
		} catch (java.lang.Exception ex) {
				%>
					<h2>Error in the SQL logic ReportLeave.jsp - contact support.<h2>
				<%  
		} //try
	}
	else{
			%>
				<h2>No leave record found during selected period.<h2>
			<%  
	}
%>
    </body>
    </html>
<%	} else { %>
		<%@ include file="ReloginRedirectMsg.jsp" %>
	<%} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) %>
<%
Reg.close();      //cleaning up open connections 
%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>
<%!
private String getArrayString(java.sql.ResultSetMetaData x, ess.AdisoftDbase y, ess.AuditTrail l, String[] schemas, String[] physicals, String[] booleans, String[] dates, ess.CustomDate Dt)
{
 String comma = "";
 String retVal = "[";
 String columnName = "";
 String otherName = "";
 String columnValue = "";

 try {
   int numberOfColumns = x.getColumnCount();
   for (int i = 1; i <= numberOfColumns; i++)
   {
       retVal += comma;
       retVal += "['";
       columnName = x.getColumnName(i);
       columnName = columnName.toUpperCase();  //check why I need uppercase.
       otherName = returnOtherName(columnName, physicals, schemas);
       retVal += otherName;     
       retVal += "','";
       columnValue = y.myResult.getString(columnName);
       if (ess.Utilities.findString(otherName, booleans) > -1)
       {
         retVal += getBooleanValue(columnValue);
       } else if (ess.Utilities.findString(otherName, dates) > -1)
       {
         if (columnValue != null && !columnValue.equals("1899-12-30")) 
         {
            // retVal += Dt.getSimpleDate(Dt.getDateFromXBase(columnValue));
            retVal += Dt.getUserDateString(Dt.getDateFromXBase(columnValue));
         } 
       } else { 
         columnValue = y.getTrim(columnValue);
         retVal += repStr(columnValue);
       }
       retVal += "']";
       comma = ",";
   }
   retVal += "]"; 

 } catch (java.sql.SQLException e) {
   retVal = "[]";
   l.println("[500] EditList.getArrayString - error in extracting column information for: " + columnName);
   l.println("[500] " + e.toString());
 }
 return retVal;
}

private String returnOtherName(String name, String[] lookup, String[] return_name)
{
  String retVal = name;
  for (int i = 0; i < lookup.length; i++)
  {
     if (lookup[i].equalsIgnoreCase(name))
     {
       retVal = return_name[i];
       i = lookup.length; 
     }
  }
  return retVal;
}

private String getBooleanValue(String X) {
   String Default = "";
   if (X == null) X = "";
   if (X.equals("1")) {
      X = "Yes";
   } else {
      X = "No";
   }
   return X;
}

private String[] set2ArrayFromAL(java.util.ArrayList x)
{  
   String[] retArray = new String[x.size()];
   for (int i = 0; i < x.size(); i++)
   {
     retArray[i] = (String) x.get(i);
   }
   return retArray;
}

public static String repStr(String x) {
   x = repStr(x, "\"","'");
   x = repStr(x, "\\","\\\\"); // was "&#92"
   x = repStr(x, "\n","\\n");  // was "&#10;"
   x = repStr(x, "\r","");
   x = repStr(x, "'","\\'");

   return x; 
}
   
public static String repStr(String x, String oldChar, String newChar) 
{
   int startLocate = 0;
   int oldLength = oldChar.length();
   int newLength = newChar.length();
      
   int locate = x.indexOf(oldChar, startLocate);
   while (locate != -1) {
      x = x.substring(0,locate) + newChar + x.substring(locate + oldLength);
      startLocate = locate + newLength;
      locate = x.indexOf(oldChar, startLocate);
   }
   return x;
}

private String getKeyDocument(ess.AdisoftDbase y, ess.AuditTrail l, java.util.List keyList, String table)
{
 String retVal = "<remove table='" + table + "'>";
 String columnName;
 String columnValue;
 org.jdom.Element x;
 try {
   for (int i = 0; i < keyList.size(); i++)
   {
       x = (org.jdom.Element) keyList.get(i);
       columnName = x.getName();
       columnName = columnName.toUpperCase();
       columnValue = y.myResult.getString(columnName);
//       columnValue = ess.Utilities.getXMLString(y.getTrim(columnValue));
       columnValue = y.getTrim(columnValue);
       retVal += "<" + columnName + ">";
       retVal += columnValue;
       retVal += "</" + columnName + ">";
   }

 } catch (java.sql.SQLException e) {
   retVal = "[]";
   l.println("[500] EditList.getKeyDocument - error in extracting key document information");
   l.println("[500] " + e.toString());
   e.printStackTrace();
 }
 retVal += "</remove>";
 return retVal;
}

%>


