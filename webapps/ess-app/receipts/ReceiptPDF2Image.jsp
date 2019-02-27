<%@ page import = "java.io.*" %>
<jsp:useBean id = "PersFile" class = "ess.PersonnelSession" scope = "session" />
<jsp:useBean id = "CK" class = "ess.ChallengeKey" scope = "application" />
<jsp:useBean id = "Log" class = "ess.AuditTrail" scope = "application" />
<jsp:useBean id = "Lang" class = "ess.Language" scope = "session" /> 
<jsp:useBean id = "Scan" class="ess.Scan" scope="session" />

<%
  String receiptNumber =  request.getParameter("image");
  String pdfNumberString = request.getParameter("pdf");
  String pageNumberString =  request.getParameter("page");
  int pdfNumber = java.lang.Integer.parseInt(pdfNumberString);;
  int pageNumber = java.lang.Integer.parseInt(pageNumberString);
  int totalNumber = Scan.getNumberOfPages(pdfNumber);
  Log.println("[000] ReceiptPDF2Image.jsp Scan Reference: " + receiptNumber + ", page " + pageNumberString + ", of total " + totalNumber);
  Log.println("[000] ReceiptPDF2Image.jsp Supported Formats: " + Scan.getImageFormats());
  String securityString = PersFile.getImageString();
	if (pageNumber > -1 && pageNumber < totalNumber)
  	{
		Log.println("[000] ReceiptPDF2Image.jsp security string: " + securityString);
		boolean sendImage = (securityString.indexOf(receiptNumber) > -1);
        //if (PersFile.isAuditor() || PersFile.isGLAdmin())
		{
			sendImage = true;
		}
		if (sendImage) {
    			try
   				{  
       			    response.setContentType("jpeg");
       				OutputStream o = response.getOutputStream();
       				o.write(Scan.getPDFPageImage(pdfNumber, pageNumber));
       				o.flush(); 
       				o.close();
       				Log.println("[000] ReceiptPDF2Image.jsp.jsp process completed");
    			}
    			catch (Exception e)
    			{
    				Log.println("[500] ReceiptPDF2Image.jsp error: " + e.toString());
      				e.printStackTrace();
    			}
    			finally
    			{
     			//close the connection;
    			}
		} else {
			
		    String ParamName;
		    String ParamValue;
			Log.println("[500] ReceiptPDF2Image.jsp security error - image access violation");
			Log.println("[500] ReceiptPDF2Image.jsp security error security string: " + securityString);
  	        Log.println("[500] ReceiptPDF2Image.jsp security error pers#: " + PersFile.getPersNum());
		    Log.println("[500] ReceiptPDF2Image.jsp security error name: " + PersFile.getName());
		    Log.println("[500] ReceiptPDF2Image.jsp security error ip: " + request.getRemoteAddr());
		    Log.println("[500] ReceiptPDF2Image.jsp security error url: " + request.getRemoteHost());
			for (java.util.Enumeration e = request.getHeaderNames(); e.hasMoreElements();){
			     ParamName = (String) e.nextElement();
			     ParamValue = request.getHeader(ParamName); 
			     Log.println("[500] ReceiptPDF2Image.jsp security error: " + ParamName + " value, " + ParamValue);
			}
			response.setContentType("text/html");
			  %>
			  <HTML><h1><%= Lang.getString("IMAGE_ACCESS_VIOLATION")%></h1></HTML>
			  <%
		}
	} else {
	      	Log.println("[500] ReceiptPDF2Image.jsp image not found error pers#: " + PersFile.getPersNum());
		  	Log.println("[500] ReceiptPDF2Image.jsp image not found error name: " + PersFile.getName());
		  	Log.println("[500] ReceiptPDF2Image.jsp image not found error ref#: " + pageNumberString);
    		Log.println("[500] ReceiptPDF2Image.jsp security error ip: " + request.getRemoteAddr());
		    Log.println("[500] ReceiptPDF2Image.jsp security error url: " + request.getRemoteHost());
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