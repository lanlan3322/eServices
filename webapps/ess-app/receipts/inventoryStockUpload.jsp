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
	
%>
<html>
<head>
<title>Category Updated Result</title>
</head>

<body onLoad="reLoadMe()">
<br><br>



<big><u> Category Updated Result </u></big><br><br>

<%
// Create a factory for disk-based file items
org.apache.commons.fileupload.FileItemFactory factory = new org.apache.commons.fileupload.disk.DiskFileItemFactory();
// Create a new file upload handler
org.apache.commons.fileupload.servlet.ServletFileUpload upload = new org.apache.commons.fileupload.servlet.ServletFileUpload(factory);
// Parse the request
java.util.List items = upload.parseRequest(request);
// Process the uploaded items
String paramName;
String paramValue;
String originalName = null;
org.apache.commons.fileupload.FileItem uploadItem = null;
java.util.Iterator iter = items.iterator();
String newExtension = "err";
int dotLocation = -1;
String scanName = SysTable.getSystemIncString("SCAN_SEQUENCE");
String pvoucher = "00000000";
String reporter = "00000000";
java.io.File uploadFile = null;
long fileSize = (long) 0;
boolean fileOK = true;
byte[] picture = null;
		String currentTime = Dt.getLocalTime();
		currentTime = currentTime.replace(":","");
		currentTime = currentTime.substring(2,6);
		CurDate = CurDate.replace("/","");
		CurDate = CurDate.substring(0,4);
		//String newLeaveNum = persnum.replace("0","") + currentTime;//.replace("0","");
		String newLeaveNum = CurDate + currentTime;
		if(newLeaveNum.length() > 8){
			newLeaveNum = newLeaveNum.substring(0,8);
		}
		pvoucher = newLeaveNum;

		String threshold = "00000000";	
	boolean bUploaded = false;
	
	String name = "";//request.getParameter("name");
	String desc = "";//request.getParameter("desc");
	String action = "create";//request.getParameter("action");
	String cat = "";//request.getParameter("cat");
	String amount = "";//request.getParameter("amount");
	String store = "";//request.getParameter("store");
	String id = "";//request.getParameter("id");
	String reason = "";//request.getParameter("reason");
	String requestType = "";//request.getParameter("requestType");
	String mngt_mail = SystemDOM.getDOMTableValueFor("configuration", "mngt_mail", "services@elc.com.sg");
	String audit_email = SystemDOM.getDOMTableValueFor("configuration", "audit_mail", "services@elc.com.sg");
	String pal_address = SendInfo.getSystemString("PAL_EMAIL_ADDRESS","services@elc.com.sg");
	String subject = "Inventory stock updated";
	String sEmailMsg = "\n  Notification of stock update:\n\n";
	int amountInt = 0;
	
	while (iter.hasNext() && fileOK && !bUploaded) {
		org.apache.commons.fileupload.FileItem item = (org.apache.commons.fileupload.FileItem) iter.next();

		if (item.isFormField()) {
		  //  processFormField(item);
		  
		  paramName = item.getFieldName();
		  paramValue = item.getString();
			if (paramName.equalsIgnoreCase("name")) 
			{
				name = paramValue;
			}
			if (paramName.equalsIgnoreCase("desc")) 
			{
				desc = paramValue;
			}
			if (paramName.equalsIgnoreCase("amount")) 
			{
				amount = paramValue;
				amountInt = Integer.parseInt(amount);
			}
			if (paramName.equalsIgnoreCase("store")) 
			{
				store = paramValue;
			}
			if (paramName.equalsIgnoreCase("id")) 
			{
				id = paramValue;
			}
			if (paramName.equalsIgnoreCase("reason")) 
			{
				reason = paramValue;
			}
			if (paramName.equalsIgnoreCase("action")) 
			{
				action = paramValue;
			}
			if (paramName.equalsIgnoreCase("cat")) 
			{
				cat = paramValue;
			}
			if (paramName.equalsIgnoreCase("requestType")) 
			{
				requestType = paramValue;
			}
		} else {
			if (fileOK)
			{
				fileSize = item.getSize();
				originalName = item.getName();
				picture = item.get();

				Log.println("[248] Upload.jsp - File: " + originalName + ", Scan#: " + scanName + ", Pers#: " + persnum);        
				if ((originalName != null) && (fileSize > (long) 10) && (fileSize < (long) 10000000))
				{
					uploadFile = new java.io.File(parentFolder + "/" + scanName + "." + newExtension.toLowerCase());
					item.write(uploadFile);
					
					limitSQL = "INSERT INTO db_item VALUES ";
					limitSQL = limitSQL + "('" + pvoucher + "','" + name + "','" + cat + "','" + desc + "','" + amount + "','" + createDate + "','0000-00-00','" + scanName + "','9999','" + store + "')";
					limitSQL = limitSQL + PersFile.getSQLTerminator();
					db.doSQLExecute(limitSQL);
				} 
				else 
				{
					fileOK = false;
				}
				bUploaded = true;
			} 
		}
	}
	String amountold2 = "";
	int amountIntOld2 = 0;
	String SQLCommand = "SELECT * FROM db_category WHERE cat_name = '" + cat + "'" + PersFile.getSQLTerminator();
	if (db2.setResultSet(SQLCommand)) { 
		amountold2 = PersFile.getTrim(db2.myResult.getString(3));
		amountIntOld2 = Integer.parseInt(amountold2);
	}

		currentTime = Dt.getLocalTime();
		currentTime = currentTime.replace(":","");
		currentTime = currentTime.substring(0,4);
		newLeaveNum = persnum.replace("0","") + currentTime.replace("0","");
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
		
		sEmailMsg += "    Stock name = '" + name + "'\n";
		sEmailMsg += "    Stock description = " + desc + "'\n";
		sEmailMsg += "    Stock amount before = " + amountold1 + "\n";
		sEmailMsg += "    Stock amount after = " + amount + "\n";
		sEmailMsg += "    Stock update reason = " + reason + "\n";
	}
	else{		
		sEmailMsg += "    The new stock added:\n";
		sEmailMsg += "    Stock name = '" + name + "'\n";
		sEmailMsg += "    Stock category = '" + cat + "'\n";
		sEmailMsg += "    Stock description = '" + desc + "'\n";
		sEmailMsg += "    Stock amount created = '" + amount + "'\n";
		sEmailMsg += "    Stock storage = '" + store + "'\n";
    
		Log.println("[eLCventory] receipts/inventoryStockUpdate.jsp " + sEmailMsg); 
	}

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
if (fileOK)
{
				if(action.equalsIgnoreCase("update")){
					//limitSQL = "UPDATE db_category SET cat_name='" + name + "', cat_threshold='" + threshold + "', cat_photo='" + scanName + "' WHERE cat_id='" + pvoucher + "'" + PersFile.getSQLTerminator();
					limitSQL = "UPDATE db_item SET item_name='" + name + "', item_desc='" + desc + "', item_amount='" + amount + "' WHERE item_id='" + pvoucher + "'" + PersFile.getSQLTerminator();
					db.doSQLExecute(limitSQL);
				}

if ((originalName != null) && (fileSize > (long) 10) && (fileSize < (long) 10000000))
{
	dotLocation = originalName.lastIndexOf(".");
	if ((dotLocation != -1) && (uploadFile != null)) 
	{
       newExtension = originalName.substring(dotLocation + 1);
      
	   if (validFileTypes.indexOf(newExtension.toLowerCase()) > -1)
	   {
       java.io.File newLoadFile = new java.io.File(parentFolder + scanName + "." + newExtension.toLowerCase());
   	   if (uploadFile.renameTo(newLoadFile))
	   {
	   		
	   		String[] tags = {"SCAN_REF","PERS_NUM","PVOUCHER","RECEIPT","FILE_TYPE","UP_DATE","UP_TIME","CLERK","STATUS","XREF","COMMENT","ADDRESS"};
	   		String[] values = new String[12];
	   		values[0] = scanName;
	   		values[1] = persnum;
	   		values[2] = pvoucher;
	   		values[3] = "00000000";
	   		values[4] = newExtension.toLowerCase();
	   		values[5] = CurDate;
	   		values[6] = Dt.getLocalTime();
	   		values[7] = persnum;
	   		values[8] = "Received";
	   		values[9] = "";
	   		values[10] = "";  //scanComment
	   		values[11] = "";

			limitSQL = "INSERT INTO SCAN VALUES ('" + values[0] + "','" + values[1] + "','" + values[2] + "','" + values[3] + "','" + values[4] + "','" + values[5] + "','" + values[6] + "','" + values[7] + "','" + values[8] + "','" + values[9] + "','" + values[10] + "','" + values[11] + "')" + PersFile.getSQLTerminator();

	   		int result = db2.doSQLExecute(limitSQL);
	   		if (result != 0)//db2.setPersistance("insert","SCAN",tags, values))
	   		{
				/*String INSERT_PICTURE = "UPDATE SCAN SET FILE_SIZE = ?, IMAGE_WIDTH = ?, IMAGE_HEIGHT = ?, FILE_CONTENT = ? where SCAN_REF = '" + scanName + "'";
				// put zipping here
				java.sql.Blob picture_as_blob = new SerialBlob(Scan.compress(picture));   
  				PreparedStatement ps = PersFile.getConnection().prepareStatement(INSERT_PICTURE); 
  				ps.setInt(1,picture.length);
  		        try {
  		        	java.awt.image.BufferedImage bimg = javax.imageio.ImageIO.read(new java.io.ByteArrayInputStream(picture));
  		        	if (bimg != null)
  		        	{
  		            	ps.setInt(2,bimg.getWidth());
  		            	ps.setInt(3,bimg.getHeight());
  		        	} else 
  		        	{
  		            	ps.setInt(2,0);
  		            	ps.setInt(3,0);
  		        	}
  		        } catch (java.io.IOException e)
  		        {
  		        	ps.setInt(2,0);
  		        	ps.setInt(3,0);
  		        }

	   			ps.setBlob(4,picture_as_blob);   
	   			ps.executeUpdate();   */
				
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
			Stock name = <%= name %><br>
			Stock category = <%= cat %><br>
			Stock description = <%= desc %><br>
			Stock amount created = <%= amount %><br>
			Stock storage = <%= store %><br>
			Image = <%= scanName%>.jpeg<br>
		    	<br><strong>Stock is updated.</strong><br>
			<%		   
	   		} else 
	   		{
			%> 
		    	<br><strong>Error logging receipt scan.   Try again and if problem persists contact support.</strong><br>
			<%
	   		}
	   } else
	   {
	   %> 
		    <br><strong>Error renaming the receipt scan.   Try again and if problem persists contact support.</strong><br>
		<%
   
	   }
	   } else
	   {
		   %> 
		    <br><strong>Invalid file extension.  Scan not accepted.   </strong><br>
		<%
		   
	   }
	   
	} else 
	{
    %> 
       <br><strong>Invalid file name.  File has not been attached to a report.</strong><br>
    <%
	}
} else
{
				if(action.equalsIgnoreCase("update")){
%> 
  <br><strong>Update without image change has been accepted.</strong><br>
				<%}else{
%> 
  <br><strong>Invalid file. File has not been accepted.</strong><br>
				<%}
}
} else
{
	%> 
	  <br><strong>File has not been accepted.</strong><br>
	<%
	
}

%>
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
