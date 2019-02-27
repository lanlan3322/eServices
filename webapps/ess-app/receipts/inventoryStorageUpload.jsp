<%--
Upload.jsp - Save receipt image files that have been uploaded from a scanner
Copyright (C) 2004,2008 R. James Holton

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
<%@ page import = "java.sql.*" %>
<%@ page import = "javax.sql.rowset.serial.*" %>
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "db"
     class="ess.AdisoftDbase"
     scope="page" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />  
<jsp:useBean id = "Scan"
     class="ess.Scan"
     scope="session" /> 
<jsp:useBean id = "db2"
     class="ess.AdisoftDbase"
     scope="page" />          
<%@ include file="../DBAccessInfo.jsp" %>
<%
// need to put the active session check here.
String persnum = PersFile.getPersNum();

db.setConnection(PersFile.getConnection());
db.setSQLTerminator(PersFile.getSQLTerminator());
db2.setConnection(PersFile.getConnection());
db2.setSQLTerminator(PersFile.getSQLTerminator());%>
<%@ include file="../SystemInfo.jsp" %>
<% 
String parentFolder = SystemDOM.getDOMTableValueFor("receiptmanagement","inventory");
String validFileTypes = SystemDOM.getDOMTableValueFor("receiptmanagement","filetypes");
validFileTypes = validFileTypes.toLowerCase();
String limitSQL = SystemDOM.getDOMTableValueFor("receiptmanagement","limitchecksql");

java.io.File persFolder = new java.io.File(parentFolder);// + persnum);
if (!persFolder.isDirectory()) 
{
	persFolder.mkdirs();
	Log.println("[000] Upload.jsp - directory created[1]: " + persFolder);
}

String CurDate = Dt.simpleDate.format(Dt.date);
//String action = request.getParameter("action");
	
%>
<html>
<head>
<title>Storage Updated Result</title>
</head>

<body onLoad="reLoadMe()">
<br><br>



<big><u> Storage Updated Result </u></big><br><br>

<%

String pvoucher = "00000000";
boolean fileOK = true;
		String currentTime = Dt.getLocalTime();
		currentTime = currentTime.replace(":","");
		currentTime = currentTime.substring(0,4);
		String newLeaveNum = persnum.replace("0","") + currentTime.replace("0","");
		if(newLeaveNum.length() > 8){
			newLeaveNum = newLeaveNum.substring(0,8);
		}
		pvoucher = newLeaveNum;
String name = request.getParameter("leaveReason");
String desc = request.getParameter("leaveTotal");
String action = request.getParameter("action");
String id = request.getParameter("id");
boolean bUploaded = false;
	if(action.equalsIgnoreCase("update")){
		pvoucher = id;
		limitSQL = "UPDATE db_storage SET storage_owner='" + name + "', storage_desc='" + desc + "' WHERE storage_id='" + pvoucher + "'" + PersFile.getSQLTerminator();
	}
	else{
		limitSQL = "INSERT INTO db_storage VALUES ('" + pvoucher + "','" + name + "','" + desc + "')" + PersFile.getSQLTerminator();
	}
	db.doSQLExecute(limitSQL);

%>          Storage ID = <%= pvoucher %><br>
			Storage name = <%= name %><br>
			Storage description = <%= desc %><br>
<%
%>
<br><strong>Storage is updated.</strong><br>

<br> *** <br>
<form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/diagnostic.jsp">
</form>
</body>
<script>
function reLoadMe() {
//  setTimeout("document.forms[0].submit()",300000);
}
</script>
</html>
