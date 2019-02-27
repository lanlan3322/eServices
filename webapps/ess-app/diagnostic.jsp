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

<% 
String ParamName;
String ParamValue;
java.text.NumberFormat myFmt1 = java.text.NumberFormat.getCurrencyInstance();
%>  

<html>
<head>
<title>Parameters and Heap Size</title>
</head>

<body onLoad="reLoadMe()">

<% 
// Get current size of heap in bytes
long heapSize = Runtime.getRuntime().totalMemory();

// Get maximum size of heap in bytes. The heap cannot grow beyond this size.
// Any attempt will result in an OutOfMemoryException.
long heapMaxSize = (long) 0.0;
try {
    heapMaxSize = Runtime.getRuntime().maxMemory();
} catch (Exception e) {
    heapMaxSize =  (long) 0.0;
}
// Get amount of free memory within the heap in bytes. This size will increase
// after garbage collection and decrease as new objects are created.

long heapFreeSize = Runtime.getRuntime().freeMemory();
%>
<big> These are the locale characteristics</big><br>
Current locale: <%= java.util.Locale.getDefault()%><br>
Number format: <%= myFmt1.format(12345678.99) %><br>
System Character Set: <%= System.getProperty("file.encoding") %><br/>
<br>
<big> These are the heap characteristics</big><br>
Current heap size: <%= java.lang.Long.toString(heapSize) %><br>
Maximum possible heap size: <%= java.lang.Long.toString(heapMaxSize) %> (May not be implemented)<br>
Current free heap memory: <%= java.lang.Long.toString(heapFreeSize) %><br>
Current used heap memory: <%= java.lang.Long.toString(heapSize - heapFreeSize) %><br>
<br>
<%
Log.println("[000] diagnostic.jsp - Current local: " + java.util.Locale.getDefault());
Log.println("[000] diagnostic.jsp - Number format: " + myFmt1.format(12345678.99));
Log.println("[000] diagnostic.jsp - Current heap size: " + java.lang.Long.toString(heapSize));
Log.println("[000] diagnostic.jsp - Maximum possible heap size: " + java.lang.Long.toString(heapMaxSize));
Log.println("[000] diagnostic.jsp - Current free heap memory: " + java.lang.Long.toString(heapFreeSize));
Log.println("[000] diagnostic.jsp - Current used heap size: " + java.lang.Long.toString(heapSize - heapFreeSize));
%>
<big> These are the header values </big><br>
<%
for (java.util.Enumeration e = request.getHeaderNames(); e.hasMoreElements();){
     ParamName = (String) e.nextElement();
     ParamValue = request.getHeader(ParamName); 
     Log.println("[000] diagnostic.jsp - Headers: " + ParamName + " value, " + ParamValue);
%>
<%= ParamName %>: <%= ParamValue %><br> 
<%       
}
%>
<br><br><big> These are the parameters </big><br>
<%
for (java.util.Enumeration e = request.getParameterNames(); e.hasMoreElements();){
     ParamName = (String) e.nextElement();
     ParamValue = request.getParameter(ParamName); 
     Log.println("[000] diagnostic.jsp - Parameter: " + ParamName + " value, " + ParamValue);
%>
<%= ParamName %>: <%= ParamValue %><br> 
<%       
}

// java.util.Locale myL = new java.util.Locale("fr","CA");
// java.util.Locale.setDefault(myL);

%>

<br> end of display <br>
<form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/diagnostic.jsp">
</form>
</body>
<script>
function reLoadMe() {
  setTimeout("document.forms[0].submit()",300000);
}
</script>
</html>
