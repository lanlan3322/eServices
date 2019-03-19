<%--
EditRemove.jsp - removes an item from the table 
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
<%@ include file="../SystemInfo.jsp" %>
<%@ include file="../SchemaInfo.jsp" %>
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
Log.println("[000] InventoryConfirm.jsp - name: " + ownersName);
boolean pFlag = PersFile.setPersInfo(ownersName); 
String CCode = "";
     String backcolor = "class=\"TableData offsetColor\"";
     String oldbackcolor = "class=\"TableData\"";
     String newbackcolor;
     String reference = "";
     String curdate = "";
     String repamt = "";
     String repStat = "";
	String persname = ownersName;
	 
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
   int SQLResult = 0;
   String changed = request.getParameter("reference");
   String temp = request.getParameter("reason");
   String action = request.getParameter("xaction");
	String currentDate = Dt.xBaseDate.format(Dt.date);
   String reason = temp;
	String pername = PersFile.getName();
	String domain_email = SystemDOM.getDOMTableValueFor("configuration", "domain_mail", "services@elc.com.sg");
	String audit_email = SystemDOM.getDOMTableValueFor("configuration", "audit_mail", "services@elc.com.sg");
	String mngt_email = SystemDOM.getDOMTableValueFor("configuration", "mngt_mail", "services@elc.com.sg");
	String pal_address = SendInfo.getSystemString("PAL_EMAIL_ADDRESS","services@elc.com.sg");
	String subject = "Stock check result submitted";
	String sEmailMsg = "";
			String itemName = "";
			String itemCat = "";
			String itemDesc = "";
			String itemAmountold = "";
			String catThreshold = "";
   String SQLCommand = "";

   //sign & cancel request start
   String newStatus = "Submitted";
   String newType = "Request";
   String stockTally = "0";
   String stockcheckId = "";
   boolean bSignOrCancel = false;
   String newStatusStr = "";
   if(action.equals("Cancel")){
	   newStatus = "Cancelled";
	   bSignOrCancel = true;
			subject = "Inventory request " + changed + " cancelled (" + currentDate + ")";
			sEmailMsg = "\n  Inventory Details:\n\n";
			sEmailMsg += "    User Name:  " + pername;
			sEmailMsg += "    Created on:  " + currentDate + "\n\n";
	   
	   //need to update balance if cancel request start
		newStatusStr = "SELECT * FROM DB_OPERATED_ITEM WHERE REF_ID_OPERATION = '";
		newStatusStr += changed + "'" + PersFile.getSQLTerminator();
		if (Reg.setResultSet(newStatusStr)) {
			try {
				do {
					String sId = PersFile.getTrim(Reg.myResult.getString(1));
					String sAmount = PersFile.getTrim(Reg.myResult.getString(2));
					
					String newStr = "UPDATE DB_ITEM SET ITEM_AMOUNT = ITEM_AMOUNT + ";
					newStr += sAmount;
					newStr += " WHERE ITEM_ID ='" + sId + "'" + PersFile.getSQLTerminator();
					SQLResult = Reg2.doSQLExecute(newStr);
					
					SQLCommand = "SELECT * FROM db_item WHERE item_id = '" + sId + "'" + PersFile.getSQLTerminator();
					if (Reg2.setResultSet(SQLCommand)) { 
						itemName = PersFile.getTrim(Reg2.myResult.getString(2));
						itemCat = PersFile.getTrim(Reg2.myResult.getString(3));
						itemDesc = PersFile.getTrim(Reg2.myResult.getString(4));
						itemAmountold = PersFile.getTrim(Reg2.myResult.getString(5));
						sEmailMsg += "    Name:				"+ itemName + "\n    Category:			" + itemCat + "\n    Description: 		" + itemDesc + "\n    Amount:				" + sAmount + "\n\n";
					}
				} while (Reg.myResult.next());
			} catch (java.lang.Exception ex) {
				Log.println("[500] ajax/InventoryConfirm.jsp ln100 exception toString : " + ex.toString());
				ex.printStackTrace();
%>
    <h2>Error in the SQL logic - contact support.<h2>
<%
			} //try
		}
	   //need to update balance if cancel request finish
	   
	   //need to send email if cancel request start
            Log.println("[500] InventoryConfirm.jsp - cancel request email to: " + domain_email);
			sEmailMsg += "\n\n" + "  The above inventory request has been cancelled.";
			if(!SendAnEmail(domain_email, pal_address, subject, sEmailMsg, SendInfo))
			{
                Log.println("[500] InventoryConfirm.jsp - notification email failure");
			}
	   //need to send email if cancel request finish
   }
   else if(action.equals("Sign Out")){
		newStatus = "Signed";
	   bSignOrCancel = true;
   }
   else if(action.equals("Update")){
		newStatus = "Signed";
	   bSignOrCancel = false;
	   newType = "Update";
	   stockTally = temp.substring(9,10);
	   stockcheckId = temp.substring(0,8);
		reason = temp.substring(11,temp.length()-2);
   }
   else if(action.equals("Return")){
		newStatus = "Signed";
	   bSignOrCancel = false;
	   newType = "Return";
	   stockcheckId = temp.substring(0,8);
		reason = temp.substring(9,temp.length());
   }
   
   if(action.equals("Remove")){
		String details = request.getParameter("reason");
		String[] a = details.split(",");
		String itemID = "";
		itemName = a[0];
		itemCat = a[1];
		itemAmountold = a[2];
		SQLCommand = "SELECT * FROM db_item WHERE item_name = '" + itemName + "'" + PersFile.getSQLTerminator();
		if (Reg.setResultSet(SQLCommand)) { 
			itemID = PersFile.getTrim(Reg.myResult.getString(1));
		}
		
		newStatusStr = "DELETE FROM db_operated_item WHERE ref_id_operation = '";
		newStatusStr += changed;
		newStatusStr += "' AND ref_id_item ='" + itemID + "'" + PersFile.getSQLTerminator();
		SQLResult = Reg2.doSQLExecute(newStatusStr);

		newStatusStr = "UPDATE db_category SET cat_amount = cat_amount + '";
		newStatusStr += itemAmountold + "' WHERE cat_name = '";
		newStatusStr += itemCat;
		newStatusStr += "'" + PersFile.getSQLTerminator();
		SQLResult = Reg2.doSQLExecute(newStatusStr);
		
		newStatusStr = "UPDATE db_item SET item_amount = item_amount + '";
		newStatusStr += itemAmountold + "' WHERE item_name = '";
		newStatusStr += itemName;
		newStatusStr += "'" + PersFile.getSQLTerminator();
		SQLResult = Reg2.doSQLExecute(newStatusStr);
				
%>
<html>
	<body>

		<h1>Item is removed from your request:</h1>
		<h2>
		Name: 		<%=itemName%><br/>
		Category:	<%=itemCat%><br/>
		Amount:		<%=itemAmountold%>
		</h2>
	</body>
</html>
<%
   }
   else if(bSignOrCancel){
	newStatusStr = "UPDATE DB_OPERATION SET OPERATION_STATUS = '";
	newStatusStr += newStatus;
	newStatusStr += "', OPERATION_SIGNED ='" + currentDate + "' WHERE OPERATION_ID ='" + changed + "'" + PersFile.getSQLTerminator();
	SQLResult = Reg2.doSQLExecute(newStatusStr);
%>
<html>
	<body>

		<h1>Inventory <%=newType%> <%=changed%> is updated to <%=newStatus%></h1>

	</body>
</html>
<%
   }
   //sign & cancel request finish
   else{

%> 

<html>
<body>

<h1>Inventory <%=newType%> :</h1>
    <table border="0" cellspacing="0" cellpadding="0" id="approveTable">
<% 
	if(stockTally.equals("1")){
%>
	<h1>Stock check result: Tally</h1>
<% 	}else{				
%>     	<thead>
     		<tr>
				<th width="10%" <%=backcolor%>>Name</th>
				<th width="10%" <%=backcolor%>>Category</th>
				<th width="50%" <%=backcolor%>>Description</th>
				<th width="10%" <%=backcolor%>>Amount</th>
			</tr>
		</thead>
<% }
    backcolor = "class=\"TableData offsetColor\"";
    oldbackcolor = "class=\"TableData\"";
    newbackcolor = backcolor;
	String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   String SQLDateReplace = SystemDOM.getDOMTableValueFor("sql","datesql");

   String item2Remove;
   String tableName;

   Log.println("[000] EditRemove.jsp - reference: " + changed);
   java.util.StringTokenizer rp = new java.util.StringTokenizer(changed, ";"); 
   
   String days = request.getParameter("days");
   String leavetype = request.getParameter("type");
   String dateSelected = request.getParameter("dateSelected");
	if (dateSelected != null && !dateSelected.equals("")) dateSelected = Dt.getSQLDate(Dt.getDateFromStr(dateSelected,PersFile.getDateFormat()));
	
	//Create request start
		String newDate = currentDate.replace("-","");
		newDate = newDate.substring(4,8);
		String currentTime = Dt.getLocalTime();
		currentTime = currentTime.replace(":","");
		currentTime = currentTime.substring(2,6);
		String newNum = newDate + currentTime;//persnumber.replace("0","") + currentTime.replace("0","");
		String newSQL = "INSERT INTO db_operation (operation_id, operation_by, operation_created, operation_reason, operation_status, operation_type, operation_ref) VALUES ('";
		if(newType.equals("Update")){
			newSQL = "INSERT INTO db_operation (operation_signed, operation_id, operation_by, operation_created, operation_reason, operation_status, operation_type, operation_ref) VALUES ('";
			newSQL = newSQL + currentDate + "', '";
			newNum = stockcheckId;
		}
		newSQL = newSQL + newNum + "', '";
		newSQL = newSQL + PersFile.getPersNum() + "', '";
		newSQL = newSQL + currentDate + "', '";
		newSQL = newSQL + reason + "', '";
		newSQL = newSQL + newStatus + "', '";
		newSQL = newSQL + newType;
		if(newType.equals("Return")){
			newSQL = newSQL + "', '" + stockcheckId + "')";
		}
		else{
			newSQL = newSQL + "', '')";
		}
		newSQL = newSQL + PersFile.getSQLTerminator();
		Reg2.doSQLExecute(newSQL);
	//Create request finish

	Log.println("[500] InventoryConfirm.jsp - request created: " + newSQL);
	
	subject = "Inventory " + newType + " created by " + pername;
	sEmailMsg = "\n  Inventory " + newType + " Details:\n\n";
	sEmailMsg += "    User Name:  " + pername;
	sEmailMsg += "    Created on:  " + currentDate + "\n\n";
	//sEmailMsg += "    Reason:         " + reason + "\n";
	//sEmailMsg += "    Name							Category		Description							Amount\n";
		
		if(newType.equals("Update")){
			newSQL = "UPDATE db_stockcheck SET ";
			newSQL += "stockcheck_end='" + currentDate + "', ";
			newSQL += "stockcheck_status ='1', ";
			newSQL += "stockcheck_report ='" + reason + "', ";
			newSQL += "stockcheck_result ='" + stockTally + "' ";
			newSQL += "WHERE stockcheck_id='" + stockcheckId + "'" + PersFile.getSQLTerminator();
			Reg2.doSQLExecute(newSQL);
			Log.println("[500] InventoryConfirm.jsp - stockcheck update created: " + newSQL);
			newSQL = "UPDATE USER SET BILLEXP='0' ";
			newSQL += "WHERE PERS_NUM='" + PersFile.getPersNum() + "'" + PersFile.getSQLTerminator();
			Reg2.doSQLExecute(newSQL);
			Log.println("[500] InventoryConfirm.jsp - nominee cleared: " + newSQL);
			subject = "Inventory stock check has been done by " + pername;
		}	
	String sStockWarning = "Warning:";
	while (rp.hasMoreTokens()) {  
		String singleChanged = rp.nextToken().trim() ;
		String[] result = singleChanged.split(",");
		String itemNum = "900";
		String itemAmount = "Error";
   		String newSQL2 = "";
		if(result.length > 1){
			if (result[0] != null && !result[0].equals(""))
			{
				itemNum = result[0];
			}
			if (result[1] != null && !result[1].equals(""))
			{
				itemAmount = result[1];
			}
			
			//Create item reference start
				newSQL2 = "INSERT INTO db_operated_item VALUES ('";
				newSQL2 = newSQL2 + itemNum + "', ";
				newSQL2 = newSQL2 + itemAmount + ", '";
				newSQL2 = newSQL2 + newNum + "');";
				Reg2.doSQLExecute(newSQL2);
			//Create item reference finish
Log.println("[500] InventoryConfirm.jsp - item ref created: " + newSQL2);
		
			//get requested item details
			SQLCommand = "SELECT db_item.item_name,db_item.item_category,db_item.item_desc,db_item.item_amount,db_category.cat_threshold FROM db_item JOIN db_category ON db_item.item_category = db_category.cat_name WHERE db_item.item_id = '" + itemNum + "'" + PersFile.getSQLTerminator();
			if (Reg.setResultSet(SQLCommand)) { 
				itemName = PersFile.getTrim(Reg.myResult.getString(1));
				itemCat = PersFile.getTrim(Reg.myResult.getString(2));
				itemDesc = PersFile.getTrim(Reg.myResult.getString(3));
				itemAmountold = PersFile.getTrim(Reg.myResult.getString(4));
				catThreshold = PersFile.getTrim(Reg.myResult.getString(5));
				int catThresholdInt = Integer.parseInt(catThreshold);
				//if(action.equals("Request")){
%>             	<tr>
					<td width="10%" <%=backcolor%>><%= itemName%></td>
					<td width="10%" <%=backcolor%>><%= itemCat%></td>
					<td width="50%" <%=backcolor%>><%= itemDesc%></td>
					<td width="10%" <%=backcolor%>><%= itemAmount%></td>
				</tr>
<%  			//} 
			sEmailMsg += "    Name:				"+ itemName + "\n    Category:			" + itemCat + "\n    Description: 		" + itemDesc + "\n    Amount:				" + itemAmount + "\n\n";
			//Update item balance start
				int amountInt = Integer.parseInt(itemAmount);
				int amountIntOld = Integer.parseInt(itemAmountold);
				int amountNew = amountIntOld - amountInt;
				newSQL2 = "UPDATE db_item SET item_amount='" + amountNew + "' WHERE item_id='" + itemNum + "'" + PersFile.getSQLTerminator();
				if(newType.equals("Request")){
					Reg2.doSQLExecute(newSQL2);
				}
			//Update item balance finish
Log.println("[500] InventoryConfirm.jsp - item balance changed: " + newSQL2);

				if(amountNew < catThresholdInt){
					sStockWarning += "\n\n" + "    Name:				"+ itemName + "\n    Category:			" + itemCat + "\n    Balance: 		    " + amountNew + "\n\n";;
				}

				newbackcolor = backcolor;
				backcolor = oldbackcolor; 
				oldbackcolor = newbackcolor;
			}//item requested
		}//requested number valid
	}//loop items
	//newSQL2 = newSQL2 + PersFile.getSQLTerminator();
%>
</table>
</body>
</html>

<% 
				if(sStockWarning.equals("Warning:")){
					Log.println("[500] InventoryConfirm.jsp - no stock wrning email to: " + domain_email);
				}
				else{
					Log.println("[500] InventoryConfirm.jsp - stock warning email to: " + domain_email);
					sStockWarning += "\n\n  Threshold: " + catThreshold;
					sStockWarning += "\n\n" + "  Please be aware of the stock balance!";
					if(!SendAnEmail(domain_email, pal_address, "Stock warning below threshold!", sStockWarning, SendInfo))
					{
						Log.println("[500] InventoryConfirm.jsp - stock warning email failure");
					}
				}

				String sEmailToDomain = sEmailMsg + "\n\n" + "  Please prepare the requested items and update status at http://elc.southeastasia.cloudapp.azure.com/ess/ess/Audit.html";
				String sResult = "NO";
				if(stockTally.equals("1")){
					sResult = "YES";
				}
				
				if(newType.equals("Request")){
					sEmailMsg += "\n\n" + "  Waiting for stock to be ready.";
				}
				else if(newType.equals("Return")){
					sEmailToDomain = sEmailMsg + "\n\n" + "  Please verify the returned items at http://elc.southeastasia.cloudapp.azure.com/ess/ess/Audit.html";
					sEmailMsg += "\n\n" + "  Waiting for return to be verified by Domain Admin.";
				}
				else{
					sEmailMsg += "\n\n" + "  Stock checking result has been submitted by : " + pername;
					sEmailMsg += "\n  Tally: " + sResult;
					sEmailToDomain = sEmailMsg;
					if(stockTally.equals("0")){
						sEmailToDomain = sEmailMsg + "\n\n  ACTION REQUIRED: Please investigate the stock balance and report to MNGT ASAP!";
                    }
					Log.println("[500] InventoryConfirm.jsp - notification email to: " + audit_email);
					if(!SendAnEmail(audit_email, pal_address, subject, sEmailToDomain, SendInfo))
					{
						Log.println("[500] InventoryConfirm.jsp - notification email failure");
					}
						Log.println("[500] InventoryConfirm.jsp - notification email to: " + mngt_email);
					sEmailToDomain = sEmailMsg;
					if(stockTally.equals("0")){
						sEmailToDomain = sEmailMsg + "\n\n  Audit Admin has been notified to do an investigation.";
                    }
					if(!SendAnEmail(mngt_email, pal_address, subject, sEmailToDomain, SendInfo))
					{
						Log.println("[500] InventoryConfirm.jsp - notification email failure");
					}
				}
                    Log.println("[500] InventoryConfirm.jsp - notification email to: " + domain_email);
				if(!SendAnEmail(domain_email, pal_address, subject, sEmailToDomain, SendInfo))
				{
                    Log.println("[500] InventoryConfirm.jsp - notification email failure");
				}
                    Log.println("[500] InventoryConfirm.jsp - notification email to: " + ownersName);
				if(!SendAnEmail(ownersName, pal_address, subject, sEmailMsg, SendInfo))
				{
                    Log.println("[500] InventoryConfirm.jsp - notification email failure");
                }
	}//not sign or cancel
} else { 
     Log.println("[500] EditRemove.jsp security object removed for " + ownersName); %>
     <%@ include file="../ReloginRedirectMsg.jsp" %>
<%
}
%>