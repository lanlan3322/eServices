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
String name = "00000000";
String threshold = "00000000";	
String action = "create";	
String id = "";	
boolean bUploaded = false;
while (iter.hasNext() && fileOK && !bUploaded) {
    org.apache.commons.fileupload.FileItem item = (org.apache.commons.fileupload.FileItem) iter.next();

    if (item.isFormField()) {
      //  processFormField(item);
      
      paramName = item.getFieldName();
      paramValue = item.getString();
		if (paramName.equalsIgnoreCase("id")) 
		{
			id = paramValue;
		}
		if (paramName.equalsIgnoreCase("action")) 
		{
			action = paramValue;
		}
		if (paramName.equalsIgnoreCase("leaveReason")) 
		{
			name = paramValue;
		}
		if (paramName.equalsIgnoreCase("leaveTotal")) 
		{
			threshold = paramValue;
		}
      if (paramName.equalsIgnoreCase("pvoucher")) 
      {
    	  //pvoucher = paramValue.substring(0,8);
    	  reporter = paramValue.substring(9);
    	  
    	  if (reporter.equals("")) reporter = "00000000";
    	  
    	  java.io.File repFolder = new java.io.File(parentFolder);// + reporter);
    	  if (!repFolder.isDirectory()) 
    	  {
    	  	repFolder.mkdirs();
    	  	Log.println("[000] Upload.jsp - directory created[2]: " + parentFolder);// + reporter);
    	  }
    	  
    	  %> Your report number = <%= paramValue %><br>
    	  <%
      }
      

    }
}
    	if (fileOK)
    	{
%>          Category ID = <%= pvoucher %><br>
			Category name = <%= name %><br>
			Category threshold = <%= threshold %><br>
<%
    	    if (true)//(originalName != null) && (fileSize > (long) 10) && (fileSize < (long) 10000000))
    	    {
				if(action.equalsIgnoreCase("update")){
					pvoucher = id;
					limitSQL = "UPDATE db_category SET cat_name='" + name + "', cat_threshold='" + threshold + "', cat_photo='elc' WHERE cat_id='" + pvoucher + "'" + PersFile.getSQLTerminator();
				}
				else{
					limitSQL = "INSERT INTO db_category VALUES ('" + pvoucher + "','" + name + "','0', '" + threshold + "','elc')" + PersFile.getSQLTerminator();
				}
				db.doSQLExecute(limitSQL);
    	    } 
			else 
    	    {
				if(action.equalsIgnoreCase("update")){
					pvoucher = id;
					limitSQL = "UPDATE db_category SET cat_name='" + name + "', cat_threshold='" + threshold + "' WHERE cat_id='" + pvoucher + "'" + PersFile.getSQLTerminator();
					db.doSQLExecute(limitSQL);
				}
				else{
					fileOK = false;
				}
    	    }
			bUploaded = true;
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
