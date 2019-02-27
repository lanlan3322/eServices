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
                  
<%@ include file="../../DBAccessInfo.jsp" %><%
// need to put the active session check here.
String persnum = PersFile.getPersNum();
String uploadMsg = "";
db.setConnection(PersFile.getConnection());
db.setSQLTerminator(PersFile.getSQLTerminator());
%>
<%@ include file="../../SystemInfo.jsp" %>
<% 
String parentFolder = SystemDOM.getDOMTableValueFor("receiptmanagement","parentfolder");
String validFileTypes = SystemDOM.getDOMTableValueFor("receiptmanagement","filetypes");
validFileTypes = validFileTypes.toLowerCase();
String limitSQL = SystemDOM.getDOMTableValueFor("receiptmanagement","limitchecksql");

java.io.File persFolder = new java.io.File(parentFolder + persnum);
if (!persFolder.isDirectory()) 
{
	persFolder.mkdirs();
	Log.println("[000] Upload.jsp - directory created: " + parentFolder + persnum);
}

String CurDate = Dt.simpleDate.format(Dt.date);

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
String scanComment = "";
java.io.File uploadFile = null;
long fileSize = (long) 0;
boolean fileOK = true;
byte[] picture = null;

while (iter.hasNext() && fileOK) {
    org.apache.commons.fileupload.FileItem item = (org.apache.commons.fileupload.FileItem) iter.next();

    if (item.isFormField()) {
      //  processFormField(item);
      
      paramName = item.getFieldName();
      paramValue = item.getString();

      if (paramName.equalsIgnoreCase("pvoucher")) 
      {
    	  pvoucher = paramValue;
		  scanName = paramValue;
      }
    } else {
    	if (fileOK)
    	{
    		fileSize = item.getSize();
            originalName = item.getName();
            picture = item.get();
            Log.println("[248] Upload.jsp - File: " + originalName + ", Scan#: " + scanName + ", Pers#: " + persnum + ", pvoucher#: " + pvoucher);        
    	    if ((originalName != null) && (fileSize > (long) 10) && (fileSize < (long) 10000000))
    	    {
        	    uploadFile = new java.io.File(parentFolder + persnum + "/" + pvoucher + "." + newExtension.toLowerCase());
    		    item.write(uploadFile);
    	    } else 
    	    {
    	    	fileOK = false;
    	    }
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
	   if (validFileTypes.indexOf(newExtension.toLowerCase()) > -1)
	   {
       java.io.File newLoadFile = new java.io.File(parentFolder + persnum + "/" + scanName + "." + newExtension.toLowerCase());
		   Boolean bChangeNameOK = false;
		   if(scanName.equalsIgnoreCase(pvoucher))
		   {
			   bChangeNameOK = true;
		   }
		   else{
			   if (uploadFile.renameTo(newLoadFile))
			   {
				   bChangeNameOK = true;
			   }
		   }
   	   if (bChangeNameOK)//uploadFile.renameTo(newLoadFile))
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
	   		values[10] = scanComment;
	   		values[11] = "";
	   		
	   		if (db.setPersistance("insert","SCAN",tags, values))
	   		{
				String INSERT_PICTURE = "UPDATE SCAN SET FILE_SIZE = ?, IMAGE_WIDTH = ?, IMAGE_HEIGHT = ?, FILE_CONTENT = ? where SCAN_REF = '" + scanName + "'";
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
	   			ps.executeUpdate();   

				uploadMsg = "REC_UPL_OK";	
				Log.println("[000] Upload.jsp - scan upload OK: " + scanName); 
				PersFile.addImage(scanName);
    	    // db.setCommit();
	   		} else 
	   		{
				uploadMsg = "REC_UPL_ERR501";
	   		}
	   } else
	   {
	   		uploadMsg = "REC_UPL_ERR502";
       }
	   } else
	   {
		   uploadMsg = "REC_UPL_ERR503";
	   }
	   
	} else 
	{
    uploadMsg = "REC_UPL_ERR504";
	}
} else
{
    uploadMsg = "REC_UPL_ERR505";
	Log.println("[500] Upload.jsp - upload file not found");
}
} else
{
	uploadMsg = "REC_UPL_ERR506";
}
%>
<script>
alert("<%= Lang.getString(uploadMsg) %>");
<% if (uploadMsg == "REC_UPL_OK") { %>

//parent.initUploadFields();
// document.forms["UploadSelectForm"].filename.value = "";

<% } %>

parent.getRemoveFiles(parent.myESSMenu.voucher);
</script>