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
    	  /*limitSQL = db.SQLReplace(limitSQL,"$persnum$",persnum);
    	  limitSQL = db.SQLReplace(limitSQL,"$pvoucher$",pvoucher);
    	  if (db.setResultSet(limitSQL))
    	  {
    		  try 
    		  {
    		      int itemCount = db.myResult.getInt(1);
    		      if (itemCount > 10)
    		      {
    		    	  %> <br><strong>You have exceeded the number of receipt files (<%= itemCount %>) that can be attached to this report!</strong><br>
    		    	  <%
    		            Log.println("[249] Upload.jsp - Exceeded number of scan files for one report: " + itemCount);        
    		    	    fileOK = false;
    		      }
    		  } catch (java.lang.Exception ex)
    		  {
    			  fileOK = false;
    		  }
    	  }*/
      }
      

    } else {
    	if (fileOK)
    	{
    		fileSize = item.getSize();
            originalName = item.getName();
            picture = item.get();

%>          Category ID = <%= pvoucher %><br>
			Category name = <%= name %><br>
			Category threshold = <%= threshold %><br>
			Category image file name = <%= originalName %><br>
            Category image file size = <%= fileSize %><br>
<%
            Log.println("[248] Upload.jsp - File: " + originalName + ", Scan#: " + scanName + ", Pers#: " + persnum);        
    	    if ((originalName != null) && (fileSize > (long) 10) && (fileSize < (long) 10000000))
    	    {
        	    uploadFile = new java.io.File(parentFolder + "/" + scanName + "." + newExtension.toLowerCase());
    		    item.write(uploadFile);
				if(action.equalsIgnoreCase("update")){
					pvoucher = id;
					limitSQL = "UPDATE db_category SET cat_name='" + name + "', cat_threshold='" + threshold + "', cat_photo='" + scanName + "' WHERE cat_id='" + pvoucher + "'" + PersFile.getSQLTerminator();
				}
				else{
					limitSQL = "INSERT INTO db_category VALUES ('" + pvoucher + "','" + name + "','0', '" + threshold + "','" + scanName + "')" + PersFile.getSQLTerminator();
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
    }
}

if (fileOK)
{
if ((originalName != null) && (fileSize > (long) 10) && (fileSize < (long) 10000000))
{
	dotLocation = originalName.lastIndexOf(".");
	if ((dotLocation != -1) && (uploadFile != null)) 
	{
       newExtension = originalName.substring(dotLocation + 1);
%>	   Scan reference = <%= scanName + ", file type = " + newExtension %><br>
<%       
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
			%> 
		    	<br><strong>Category is updated.</strong><br>
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
