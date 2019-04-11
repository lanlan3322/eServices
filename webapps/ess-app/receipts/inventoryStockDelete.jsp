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
<jsp:useBean id = "SendInfo"
     class="ess.ServerSystemTable"
     scope="page" />
<%@ include file="../../SendAnEmail.jsp" %>
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

String createDate = Dt.xBaseDate.format(Dt.date);
String CurDate = Dt.simpleDate.format(Dt.date);
String name = request.getParameter("name");
String cat = request.getParameter("cat");
String desc = request.getParameter("desc");
String amount = request.getParameter("amount");
String id = request.getParameter("id");	
%>
<html>
<head>
<title>Category Updated Result</title>
</head>

<body onLoad="reLoadMe()">
<br><br>



<big><u> Category Updated Result </u></big><br><br>

<%

	String mngt_mail = SystemDOM.getDOMTableValueFor("configuration", "mngt_mail", "services@elc.com.sg");
	String audit_email = SystemDOM.getDOMTableValueFor("configuration", "audit_mail", "services@elc.com.sg");
	String pal_address = SendInfo.getSystemString("PAL_EMAIL_ADDRESS","services@elc.com.sg");
	String subject = "Inventory stock deleted";
	String sEmailMsg = "\n  Notification of stock deleted:\n\n";
	int amountInt = Integer.parseInt(amount);

	String amountold2 = "";
	int amountIntOld2 = 0;
	String SQLCommand = "SELECT * FROM db_category WHERE cat_name = '" + cat + "'" + PersFile.getSQLTerminator();
	if (db2.setResultSet(SQLCommand)) { 
		amountold2 = PersFile.getTrim(db2.myResult.getString(3));
		amountIntOld2 = Integer.parseInt(amountold2);
	}


		String amountold1 = "";
		SQLCommand = "SELECT * FROM db_item WHERE item_id = '" + id + "'" + PersFile.getSQLTerminator();
		if (db2.setResultSet(SQLCommand)) { 
			amountold1 = PersFile.getTrim(db2.myResult.getString(5));
		}
		int amountIntOld1 = Integer.parseInt(amountold1);
		int amountNew2 = amountIntOld2 - amountIntOld1;
    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp Delete item : "); 
    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp item : " + name); 
    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp desc : " + desc); 
    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp before : " + amountold1); 
    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp after : " + amount); 
		
		sEmailMsg += "    Stock name = '" + name + "'\n";
		sEmailMsg += "    Stock description = " + desc + "'\n";
		sEmailMsg += "    Stock amount before = " + amountold1 + "\n";
		sEmailMsg += "    Stock amount after = " + amount + "\n";
		sEmailMsg += "    Stock update reason = delete by DA\n";

	limitSQL = "UPDATE db_category SET cat_amount='" + amountNew2 + "' WHERE cat_name='" + cat + "'" + PersFile.getSQLTerminator();
	db.doSQLExecute(limitSQL);

    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp UpdateStock to update category : "); 
    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp before category amount : " + amountIntOld2); 
    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp after category amount : " + amountNew2); 

		//Create request start
		String currentDate = Dt.xBaseDate.format(Dt.date);
		String newDate = currentDate.replace("-","");
		newDate = newDate.substring(4,8);
		String currentTime = Dt.getLocalTime();
		currentTime = currentTime.replace(":","");
		currentTime = currentTime.substring(2,6);
		String newNum = newDate + currentTime;//persnumber.replace("0","") + currentTime.replace("0","");
		String 	newSQL = "INSERT INTO db_operation (operation_signed, operation_id, operation_by, operation_created, operation_reason, operation_status, operation_type) VALUES ('";
		newSQL = newSQL + currentDate + "', '";
		newSQL = newSQL + newNum + "', '";
		newSQL = newSQL + PersFile.getPersNum() + "', '";
		newSQL = newSQL + currentDate + "', '";
		newSQL = newSQL + "Deleted by DA', 'Finished', '";
		newSQL = newSQL + "Delete')" + PersFile.getSQLTerminator();
		db.doSQLExecute(newSQL);
		Log.println("[500] [eLCventory] inventoryStockUpdate.jsp - request created: " + newSQL);
		//Create request finish
			
			//Create item reference start
				newSQL = "INSERT INTO db_operated_item VALUES ('";
				newSQL = newSQL + id + "', ";
				newSQL = newSQL + amount + ", '";
				newSQL = newSQL + newNum + "');";
				db.doSQLExecute(newSQL);
				Log.println("[500] [eLCventory] inventoryStockUpdate.jsp - item ref created: " + newSQL);
			//Create item reference finish

					limitSQL = "DELETE FROM db_item WHERE item_id='" + id + "'" + PersFile.getSQLTerminator();
					db.doSQLExecute(limitSQL);
				Log.println("[500] [eLCventory] inventoryStockUpdate.jsp - item deleted: " + limitSQL);

%> 

  <br><strong>ITEM IS DELETED.</strong><br>

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
