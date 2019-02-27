<%@ page import = "java.io.*" %>
<jsp:useBean id = "PersFile" class = "ess.PersonnelSession" scope = "session" />
<jsp:useBean id = "CK" class = "ess.ChallengeKey" scope = "application" />
<jsp:useBean id = "Log" class = "ess.AuditTrail" scope = "application" />
<jsp:useBean id = "imageData" class = "ess.InputTextFile" scope = "page" />
<jsp:useBean id = "Lang" class = "ess.Language" scope = "session" /> 
<jsp:useBean id = "Scan" class="ess.Scan" scope="session" />
<%@ include file = "../../SystemInfo.jsp" %><%
 
  String receiptNumber =  request.getParameter("image"); 
  String parentFolder = SysTable.getSystemString("receiptmanagement","parentfolder","/var/ess/receipts/");
  Log.println("[000] ReceiptView.jsp parentFolder: " + parentFolder);
  String scanInfoSQL = SysTable.getSystemString("receiptmanagement","scaninfo","SELECT * FROM SCAN WHERE SCAN_REF = '$reference$'" + PersFile.getSQLTerminator());
  Log.println("[000] ReceiptView.Image.jsp scanInfoSQL: " + scanInfoSQL);
  String applicationTypes = SystemDOM.getDOMTableValueFor("receiptmanagement","applicationtypes",";pdf;doc;xdoc;xls;");
  
  if ( receiptNumber != null )
  {
  
	scanInfoSQL = PersFile.SQLReplace(scanInfoSQL, "$reference$", receiptNumber); 
    Log.println("[000] ajax/receipts/ReceiptView.java - SQL: " + scanInfoSQL);
	if (PersFile.setResultSet(scanInfoSQL))
	{
		String persnum = PersFile.myResult.getString("PERS_NUM");
		String filetype = PersFile.myResult.getString("FILE_TYPE");
		Log.println("[000] ReceiptView.jsp pers #: " + persnum + " (" + filetype + ")");
		String securityString = PersFile.getImageString();
		Log.println("[000] ReceiptView.jsp security string: " + securityString);
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
			%>
			<html>
			<head>
			</head>  
			<body> <%
            if (applicationTypes.indexOf(filetype) == -1)
            { 
            	if (filetype.equalsIgnoreCase("pdf")) {
                	    int numberOfPDFPages;
        	    	    Scan.resetPDFsList();
    					java.sql.Blob file_blob = PersFile.myResult.getBlob("FILE_CONTENT");
           				if (file_blob == null || file_blob.length() == 0) {
    						if(Scan.loadPDFDocumentObject(imageData.readWholeFile(parentFolder + persnum + "/" + receiptNumber + "." + filetype)))
    						{	
    							numberOfPDFPages = Scan.getNumberOfPages(0);
    							for (int j = 0; j < numberOfPDFPages; j++) {
    							%> <img src="/ess-app/receipts/ReceiptPDF2Image.jsp?image=<%= receiptNumber %>&pdf=0&page=<%= j %>"/><br/><br/><br/> 
    							<%
    							}
    						} else {
    							%> [error (<%= receiptNumber %>) from file]<br/><br/><br/> 
    							<%
    						}	
              				
           				} else {
    						if(Scan.loadPDFDocumentObject(Scan.decompress(file_blob.getBytes((long) 1, (int) file_blob.length()))))
    						{	
    							numberOfPDFPages = Scan.getNumberOfPages(0);
    							for (int j = 0; j < numberOfPDFPages; j++) {
    							%> <img src="/ess-app/receipts/ReceiptPDF2Image.jsp?image=<%= receiptNumber %>&pdf=0&page=<%= j %>"/><br/><br/><br/> 
    							<%
    							}
    						} else {
    							%> [error (<%= receiptNumber %>) from blob]<br/><br/><br/> 
    							<%
    						}	
           				}
           					
    						
            	} else {
			%>    <img src="/ess-app/receipts/ReceiptViewImage.jsp?image=<%= receiptNumber %>"/> 
            <%  }
            } else
            {%> <iframe width="660" height="500" src="/ess-app/receipts/ReceiptViewImage.jsp?image=<%= receiptNumber %>"/> 
            <%}
            %></body>
			</html>
			<%
		} else {
			
		    String ParamName;
		    String ParamValue;
			Log.println("[500] ReceiptView.jsp security error - image access violation");
			Log.println("[000] ReceiptView.jsp security error security string: " + securityString);
  	        Log.println("[500] ReceiptView.jsp security error pers#: " + PersFile.getPersNum());
		    Log.println("[500] ReceiptView.jsp security error name: " + PersFile.getName());
		    Log.println("[500] ReceiptView.jsp security error ip: " + request.getRemoteAddr());
		    Log.println("[500] ReceiptView.jsp security error url: " + request.getRemoteHost());
			for (java.util.Enumeration e = request.getHeaderNames(); e.hasMoreElements();){
			     ParamName = (String) e.nextElement();
			     ParamValue = request.getHeader(ParamName); 
			     Log.println("[500] ReceiptView.jsp security error: " + ParamName + " value, " + ParamValue);
			}
			response.setContentType("text/html");
			  %>
			  <HTML><h1><%= Lang.getString("IMAGE_ACCESS_VIOLATION")%></h1></HTML>
			  <%
		}
	} else {
	      Log.println("[500] ReceiptView.jsp image not found error pers#: " + PersFile.getPersNum());
		  Log.println("[500] ReceiptView.jsp image not found error name: " + PersFile.getName());
		  Log.println("[500] ReceiptView.jsp image not found error ref#: " + receiptNumber);
		  response.setContentType("text/html");
		  %>
		  <HTML><h1><%= Lang.getString("IMAGE_NOT_FOUND")%></h1></HTML>
		  <%
	}
  } else {
      Log.println("[500] ReceiptView.jsp image ref # null error pers#: " + PersFile.getPersNum());
	  Log.println("[500] ReceiptView.jsp image ref # null error name: " + PersFile.getName());
	  response.setContentType("text/html");
	  %>
	  <HTML><h1><%= Lang.getString("IMAGE_NOT_FOUND")%></h1></HTML>
	  <%
	  
  }
%>

