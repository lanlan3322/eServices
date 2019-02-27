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
String limitSQL = "";//SystemDOM.getDOMTableValueFor("receiptmanagement","limitchecksql");
String limitSQL2 = "";

String CurDate = Dt.xBaseDate.format(Dt.date);
	
%>
<html>
<head>
<title>Stock Updated Result</title>
</head>

<body onLoad="reLoadMe()">
<br><br>



<big><u> Stock Updated Result </u></big><br><br>

<%

String pvoucher = "00000000";
boolean fileOK = true;
String name = request.getParameter("name");
String desc = request.getParameter("desc");
String action = request.getParameter("action");
String cat = request.getParameter("cat");
String amount = request.getParameter("amount");
String store = request.getParameter("store");
String id = request.getParameter("id");
String reason = request.getParameter("reason");
String requestType = request.getParameter("requestType");
	String mngt_mail = SystemDOM.getDOMTableValueFor("configuration", "mngt_mail", "services@elc.com.sg");
	String audit_email = SystemDOM.getDOMTableValueFor("configuration", "audit_mail", "services@elc.com.sg");
	String pal_address = SendInfo.getSystemString("PAL_EMAIL_ADDRESS","services@elc.com.sg");
	String subject = "Inventory stock updated";
	String sEmailMsg = "\n  Notification of stock update:\n\n";
	String amountold2 = "";
	String SQLCommand = "SELECT * FROM db_category WHERE cat_name = '" + cat + "'" + PersFile.getSQLTerminator();
	if (db2.setResultSet(SQLCommand)) { 
		amountold2 = PersFile.getTrim(db2.myResult.getString(3));
	}
	int amountInt = Integer.parseInt(amount);
	int amountIntOld2 = Integer.parseInt(amountold2);

		String currentTime = Dt.getLocalTime();
		currentTime = currentTime.replace(":","");
		currentTime = currentTime.substring(0,4);
		String newLeaveNum = persnum.replace("0","") + currentTime.replace("0","");
		if(newLeaveNum.length() > 8){
			newLeaveNum = newLeaveNum.substring(0,8);
		}
		pvoucher = newLeaveNum;
	int amountNew2 = amountInt + amountIntOld2;
	if(action.equalsIgnoreCase("update")){
		pvoucher = id;
		String amountold1 = "";
		SQLCommand = "SELECT * FROM db_item WHERE item_id = '" + pvoucher + "'" + PersFile.getSQLTerminator();
		if (db2.setResultSet(SQLCommand)) { 
			amountold1 = PersFile.getTrim(db2.myResult.getString(5));
		}
		int amountIntOld1 = Integer.parseInt(amountold1);
		amountNew2 = amountInt - amountIntOld1 + amountIntOld2;
    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp Update item : "); 
    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp item : " + name); 
    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp desc : " + desc); 
    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp before : " + amountold1); 
    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp after : " + amount); 
		
		limitSQL = "UPDATE db_item SET item_name='" + name + "', item_desc='" + desc + "', item_amount='" + amount + "' WHERE item_id='" + pvoucher + "'" + PersFile.getSQLTerminator();
		db.doSQLExecute(limitSQL);
		
		sEmailMsg += "    Stock name = '" + name + "'\n";
		sEmailMsg += "    Stock description = " + desc + "'\n";
		sEmailMsg += "    Stock amount before = " + amountold1 + "\n";
		sEmailMsg += "    Stock amount after = " + amount + "\n";
		sEmailMsg += "    Stock update reason = " + reason + "\n";
%>          
			Stock name = <%= name %><br>
			Stock description = <%= desc %><br>
			Stock amount before = <%= amountold1 %><br>
			Stock amount after = <%= amount %><br>
<%	}
	else{
		/*String newID = pvoucher.substring(0,4);
		String newIDStr = pvoucher;
		limitSQL = "INSERT INTO db_item VALUES ";
		for(int i=1;i<=amountInt;i++){
			newIDStr = pvoucher.replace(newID,Integer.toString(i));
			limitSQL = limitSQL + "('" + newIDStr + "','" + name + "','" + cat + "','" + desc + "','" + amount + "','" + CurDate + "','0000-00-00','Idle','9999','Store')";// + PersFile.getSQLTerminator();
			if(i<amountInt){
				limitSQL = limitSQL + ",";
			}
		}*/
		limitSQL = "INSERT INTO db_item VALUES ";
		limitSQL = limitSQL + "('" + pvoucher + "','" + name + "','" + cat + "','" + desc + "','" + amount + "','" + CurDate + "','0000-00-00','Idle','9999','" + store + "')";
		limitSQL = limitSQL + PersFile.getSQLTerminator();
		db.doSQLExecute(limitSQL);

		
		sEmailMsg += "    The new stock added:\n";
		sEmailMsg += "    Stock name = '" + name + "'\n";
		sEmailMsg += "    Stock category = '" + cat + "'\n";
		sEmailMsg += "    Stock description = '" + desc + "'\n";
		sEmailMsg += "    Stock amount created = '" + amount + "'\n";
		sEmailMsg += "    Stock storage = '" + store + "'\n";
    
		Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp " + sEmailMsg); 
%>          
			Stock name = <%= name %><br>
			Stock category = <%= cat %><br>
			Stock description = <%= desc %><br>
			Stock amount created = <%= amount %><br>
			Stock storage = <%= store %><br>
<%	}

	limitSQL = "UPDATE db_category SET cat_amount='" + amountNew2 + "' WHERE cat_name='" + cat + "'" + PersFile.getSQLTerminator();
	db.doSQLExecute(limitSQL);

    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp UpdateStock to update category : "); 
    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp before category amount : " + amountIntOld2); 
    Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp after category amount : " + amountNew2); 

		//Create request start
		String currentDate = Dt.xBaseDate.format(Dt.date);
		String newDate = currentDate.replace("-","");
		newDate = newDate.substring(4,8);
		currentTime = Dt.getLocalTime();
		currentTime = currentTime.replace(":","");
		currentTime = currentTime.substring(2,6);
		String newNum = newDate + currentTime;//persnumber.replace("0","") + currentTime.replace("0","");
		String 	newSQL = "INSERT INTO db_operation (operation_signed, operation_id, operation_by, operation_created, operation_reason, operation_status, operation_type) VALUES ('";
		newSQL = newSQL + currentDate + "', '";
		newSQL = newSQL + newNum + "', '";
		newSQL = newSQL + PersFile.getPersNum() + "', '";
		newSQL = newSQL + currentDate + "', '";
		newSQL = newSQL + reason + "', 'Finished', '";
		newSQL = newSQL + requestType + "')" + PersFile.getSQLTerminator();
		db.doSQLExecute(newSQL);
		Log.println("[500] [eLCventory] inventoryStockUpdate.jsp - request created: " + newSQL);
		//Create request finish
			
			//Create item reference start
				newSQL = "INSERT INTO db_operated_item VALUES ('";
				newSQL = newSQL + pvoucher + "', ";
				newSQL = newSQL + amount + ", '";
				newSQL = newSQL + newNum + "');";
				db.doSQLExecute(newSQL);
				Log.println("[500] [eLCventory] inventoryStockUpdate.jsp - item ref created: " + newSQL);
			//Create item reference finish

				Log.println("[500] inventoryStockUpdate.jsp - stock update email to: " + mngt_mail);
				if(!SendAnEmail(mngt_mail, pal_address, subject, sEmailMsg, SendInfo))
				{
					Log.println("[500] inventoryStockUpdate.jsp - notification email failure" + mngt_mail);
				}
				Log.println("[500] inventoryStockUpdate.jsp - stock update email to: " + audit_email);
				if(!SendAnEmail(audit_email, pal_address, subject, sEmailMsg, SendInfo))
				{
					Log.println("[500] inventoryStockUpdate.jsp - notification email failure" + audit_email);
				}
			
%>
<br><strong>Stock is updated.</strong><br>

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
