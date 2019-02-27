<%--
diagnostic.jsp - returns information about the state of the web server
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
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />

<html>
<head>
<title>Parameters and Heap Size</title>
</head>

<body onLoad="reLoadMe()">
<big> These are the heap characteristics</big><br>
<% 
// Get current size of heap in bytes
long heapSize = Runtime.getRuntime().totalMemory();

// Get maximum size of heap in bytes. The heap cannot grow beyond this size.
// Any attempt will result in an OutOfMemoryException.
long heapMaxSize = (long) 0.0;
// heapMaxSize = Runtime.getRuntime().maxMemory();

// Get amount of free memory within the heap in bytes. This size will increase
// after garbage collection and decrease as new objects are created.
long heapFreeSize = Runtime.getRuntime().freeMemory();
%>
Current heap size: <%= java.lang.Long.toString(heapSize) %><br>
Maximum possible heap size: <%= java.lang.Long.toString(heapMaxSize) %><br>
Current free heap memory: <%= java.lang.Long.toString(heapFreeSize) %><br>
Current used heap memory: <%= java.lang.Long.toString(heapSize - heapFreeSize) %><br>
<br><br><br>

<%
Log.println("[000] diagnostic.jsp - Current heap size: " + java.lang.Long.toString(heapSize));
Log.println("[000] diagnostic.jsp - Maximum possible heap size: " + java.lang.Long.toString(heapMaxSize));
Log.println("[000] diagnostic.jsp - Current free heap memory: " + java.lang.Long.toString(heapFreeSize));
Log.println("[000] diagnostic.jsp - Current used heap size: " + java.lang.Long.toString(heapSize - heapFreeSize));
%>

<big> This is the input stream </big><br>
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
java.util.Iterator iter = items.iterator();
while (iter.hasNext()) {
    org.apache.commons.fileupload.FileItem item = (org.apache.commons.fileupload.FileItem) iter.next();

    if (item.isFormField()) {
      //  processFormField(item);
      
      paramName = item.getFieldName();
      paramValue = item.getString();

%> Form field name = <%= paramName %>, value = <%= paramValue %><br>
<%
    } else {
       // processUploadedFile(item);
      java.io.File uploadedFile = new java.io.File("c:/upload.dat");
      item.write(uploadedFile);
      
%> File has been written<br>
<%
    }
}

%>
<br> end of display <br>
<form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/diagnostic.jsp">
</form>
</body>
<script>
function reLoadMe() {
//  setTimeout("document.forms[0].submit()",300000);
}
</script>
</html>


