<%@ page import = "java.io.*" %>
<%@ page import = "java.sql.*" %>
<jsp:useBean id = "PersFile" class = "ess.PersonnelSession" scope = "session" />
<jsp:useBean id = "CK" class = "ess.ChallengeKey" scope = "application" />
<jsp:useBean id = "Log" class = "ess.AuditTrail" scope = "application" />
<jsp:useBean id = "imageData" class = "ess.InputTextFile" scope = "page" />
<jsp:useBean id = "Lang" class = "ess.Language" scope = "session" /> 
<jsp:useBean id = "Scan" class="ess.Scan" scope="session" />

<%@ include file = "../SystemInfo.jsp" %><%
 
  String receiptNumber =  request.getParameter("image"); 
  String parentFolder = SysTable.getSystemString("receiptmanagement","parentfolder","/var/ess/receipts/");
  Log.println("[000] ReceiptViewImage.jsp parentFolder: " + parentFolder);
  String scanInfoSQL = SysTable.getSystemString("receiptmanagement","scaninfo","SELECT * FROM SCAN WHERE SCAN_REF = '$reference$'" + PersFile.getSQLTerminator());
  Log.println("[000] ReceiptView.Image.jsp scanInfoSQL: " + scanInfoSQL);
  String applicationTypes = SystemDOM.getDOMTableValueFor("receiptmanagement","applicationtypes",";pdf;doc;xdoc;xls;");

  java.sql.Statement xState = null;
  java.sql.ResultSet xResult;

  if ( receiptNumber != null )
  {
  
	scanInfoSQL = PersFile.SQLReplace(scanInfoSQL, "$reference$", receiptNumber); 
    Log.println("[000] ajax/receipts/ReceiptViewImage.java - SQL: " + scanInfoSQL);
    xResult = PersFile.jdbcResultSet(scanInfoSQL,xState);
	if (xResult != null)
	{
		String persnum = xResult.getString("PERS_NUM");
		String filetype = xResult.getString("FILE_TYPE");
		Blob file_blob = xResult.getBlob("FILE_CONTENT");
		Log.println("[000] ReceiptViewImage.jsp pers #: " + persnum + " (" + filetype + ")");
		String securityString = PersFile.getImageString();
		Log.println("[000] ReceiptViewImage.jsp security string: " + securityString);
		boolean sendImage = (securityString.indexOf(receiptNumber) > -1);
		if (persnum.equals(PersFile.getPersNum())) 
		{
			sendImage = true;
		} else if (PersFile.isAuditor() || PersFile.isGLAdmin())
		{
			sendImage = true;
		}
		sendImage = true;//everyone is able to view receipt
		if (sendImage) {
    			try
   				{  
       			// display the image
       		    	Log.println("[000] ReceiptViewImage.jsp mime type: " + standardFileType(filetype,applicationTypes));
       				response.setContentType(standardFileType(filetype, applicationTypes));
       				OutputStream o = response.getOutputStream();
       				
       				if (file_blob == null || file_blob.length() == 0) {
       					Log.println("[000] ReceiptViewImage.jsp using file system copy");
       					o.write(imageData.readWholeFile(parentFolder + persnum + "/" + receiptNumber + "." + filetype));
       				} else {
       					Log.println("[000] ReceiptViewImage.jsp using database copy");
       					byte[] file_content = file_blob.getBytes((long) 1, (int) file_blob.length());
       					//file_blob.free();
       					o.write(Scan.decompress(file_content));
       				}
       				o.flush(); 
       				o.close();
       				Log.println("[000] ReceiptViewImage.jsp process completed: " + parentFolder + persnum + "/" + receiptNumber + "." + filetype );
    			}
    			catch (Exception e)
    			{
    				Log.println("[500] ReceiptViewImage.jsp error: " + e.toString());
      				e.printStackTrace();
    			}
    			finally
    			{
     			//close the connection;
    			}
		} else {
			
		    String ParamName;
		    String ParamValue;
			Log.println("[500] ReceiptViewImage.jsp security error - image access violation");
			Log.println("[000] ReceiptViewImage.jsp security error security string: " + securityString);
  	        Log.println("[500] ReceiptViewImage.jsp security error pers#: " + PersFile.getPersNum());
		    Log.println("[500] ReceiptViewImage.jsp security error name: " + PersFile.getName());
		    Log.println("[500] ReceiptViewImage.jsp security error ip: " + request.getRemoteAddr());
		    Log.println("[500] ReceiptViewImage.jsp security error url: " + request.getRemoteHost());
			for (java.util.Enumeration e = request.getHeaderNames(); e.hasMoreElements();){
			     ParamName = (String) e.nextElement();
			     ParamValue = request.getHeader(ParamName); 
			     Log.println("[500] ReceiptViewImage.jsp security error: " + ParamName + " value, " + ParamValue);
			}
			response.setContentType("text/html");
			  %>
			  <HTML><h1><%= Lang.getString("IMAGE_ACCESS_VIOLATION")%></h1></HTML>
			  <%
		}
	} else {
	      Log.println("[500] ReceiptViewImage.jsp image not found error pers#: " + PersFile.getPersNum());
		  Log.println("[500] ReceiptViewImage.jsp image not found error name: " + PersFile.getName());
		  Log.println("[500] ReceiptViewImage.jsp image not found error ref#: " + receiptNumber);
		  response.setContentType("text/html");
		  %>
		  <HTML><h1><%= Lang.getString("IMAGE_NOT_FOUND")%></h1></HTML>
		  <%
	}
  } else {
      Log.println("[500] ReceiptViewImage.jsp image ref # null error pers#: " + PersFile.getPersNum());
	  Log.println("[500] ReceiptViewImage.jsp image ref # null error name: " + PersFile.getName());
	  response.setContentType("text/html");
	  %>
	  <HTML><h1><%= Lang.getString("IMAGE_NOT_FOUND")%></h1></HTML>
	  <%
	  
  }
  //Got the following off the internet.  Normal JSP should only produce text.  This is temporary 
  //to give us time to create a servlet, which will be kind of hard.  JH 2012-09-14
  out.clear(); 
  out = pageContext.pushBody(); 
%>
<%@ include file="StandardFileType.jsp" %>