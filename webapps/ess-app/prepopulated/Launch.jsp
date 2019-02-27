<%--
EODSave.jsp - Runs the EOD jobs to produce various output files
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
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "DBConn"
     class="ess.AdisoftDbConn"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "SystemDOM"
     class="ess.AdisoftDOM"
     scope="application" />
<jsp:useBean id = "SysTable"
     class="ess.ServerSystemTable"
     scope="page" />


<%@ include file="../DBAccessInfo.jsp" %>
<%
Log.println("[000] Launch.jsp Access from: " + request.getRemoteAddr());

String database = DBDatabase;
// Since DBConn is an application, we should check to see if it exists.
DBConn.setDB(database,DBUser,DBPassword); 


String securityContext3 = config.getServletContext().getInitParameter("ESSSecurity"); //JH 9-19-2003
if (securityContext3 == null) securityContext3 = "APPLICATION";

database = request.getParameter("database");

String NeedPassword = "NO";

boolean pFlag = PersFile.setPersInfo(PersFile.getEmailAddress()); 

if (pFlag) {
// figure out a way to see if this exists already - set thge SystemInfo JSP - maybe already there
   SysTable.setConnection(PersFile.getConnection());
   SysTable.setSQLTerminator(PersFile.getSQLTerminator());
   if (!SystemDOM.getDOMProcessed()) {
     String system_file = SysTable.getSystemString("XMLSYSTEM","C:\\WORK\\"); 
     java.io.File SystemFile = new java.io.File(system_file);
     SystemDOM.setDOM(SystemFile);
   }

  Log.println("[000] Import Launch.jsp start");


  session.putValue("loginAttempts", new java.lang.Integer(0));


  boolean errorCondition = false; 

//**** Section for the incoming html parameters ////////////


// Create a factory for disk-based file items
org.apache.commons.fileupload.FileItemFactory factory = new org.apache.commons.fileupload.disk.DiskFileItemFactory();

// Create a new file upload handler
org.apache.commons.fileupload.servlet.ServletFileUpload upload = new org.apache.commons.fileupload.servlet.ServletFileUpload(factory);

// Parse the request
java.util.List items = upload.parseRequest(request);

// Process the uploaded items
String paramClass = "ess.GeneralFlatimport";  // just example values;
String paramMethod = "simple";
String paramDate = "";
String paramAction = "";
String paramName;
String paramValue;
String uploadFileName = SystemDOM.getDOMTableValueFor("configuration","importwork","c:/upload.dat");

java.util.Iterator iter = items.iterator();
while (iter.hasNext()) {
    org.apache.commons.fileupload.FileItem item = (org.apache.commons.fileupload.FileItem) iter.next();

    if (item.isFormField()) {
      
      paramName = item.getFieldName();
      paramValue = item.getString();

      Log.println("[000] Import Launch.jsp paramName: " + paramName + ", paramValue: " + paramValue);
      if (paramName.equalsIgnoreCase("importClass")) paramClass = paramValue;
      if (paramName.equalsIgnoreCase("importMethod")) paramMethod = paramValue;
      if (paramName.equalsIgnoreCase("standardDate")) paramDate = paramValue;
      if (paramName.equalsIgnoreCase("postAction")) paramAction = paramValue;

    } else {
// Need to put the 
      java.io.File uploadedFile = new java.io.File(uploadFileName);
      item.write(uploadedFile);
      
    }
}

%>
<html>
<body>
<strong><em><u>File Import Process</u><br><br>
Import Method: <%= paramMethod %>
<br></em></strong><br>
<%

  Log.println("[000] Import Launch.jsp importClass: " + paramClass);
  Log.println("[000] Import Launch.jsp importMethod: " + paramMethod);
  Log.println("[000] Import Launch.jsp importAsOfDate: " + paramDate);

// Call ImportAPI.java interface as a separate thread for return performance

ess.ImportSave ImportThread = (ess.ImportSave) (Class.forName(paramClass)).newInstance();

ImportThread.setConnection(DBConn.getConnection());
// ImportThread.setEmailAddress(PersFile.getEmailAddress());
ImportThread.setSQLTerminator(PersFile.getSQLTerminator());
ImportThread.setInputFileName(uploadFileName);     //importwork
ImportThread.setImportDescFile(SystemDOM.getDOMTableValueFor("configuration","xmlexport","c:/export.xml"));    //export.xml
if (!paramDate.equals("")) ImportThread.setImportDate(paramDate,PersFile.getDateFormat());  //2nd parameter added 7/18/2011
ImportThread.setImportMethod(paramMethod);
ImportThread.setSystemDOM(SystemDOM);
if (!paramAction.equals("")) ImportThread.setAction(paramAction);

// Next is temporary for testing
// ImportThread.setFileType("SDF");

Thread threadx = new Thread(ImportThread);

threadx.start();

%>
 
<br><strong><em>Import process has been launched.</em></strong>

<script langauge="JavaScript">
</script>
</body>
</html>

<% 

Log.println("[000] Pre-populater Launch.jsp finished");

} else { 

   java.lang.Integer xLoginTrys = (java.lang.Integer) session.getValue("loginAttempts");
   java.lang.Integer loginAttempts = new java.lang.Integer(4);
   if (xLoginTrys != null) {
      loginAttempts = xLoginTrys;
   }
   int numTrys;
   numTrys = loginAttempts.intValue() + 1;
   if (numTrys > 3 || securityContext3.equalsIgnoreCase("HOST")) {
     Log.println("[400] Prepopulated Launch.jsp Invalid access (3X)"); %>
     <%@ include file="../ReloginRedirectMsg.jsp" %>
<% } else {
      session.putValue("loginAttempts", new java.lang.Integer(numTrys));
%>
     <%@ include file="../InvalidPasswordMsg.jsp" %>
<% } 

}
%>





