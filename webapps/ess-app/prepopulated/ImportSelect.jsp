<%--
ImportSelect.jsp - Specifies which file to import 
Copyright (C) 2006 R. James Holton

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
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<%@ include file="../DBAccessInfo.jsp" %>
<%

Log.println("[000] ImportSelect.jsp by: " + PersFile.getEmailAddress());
String CCode = "";
// Check to see if the personnelSession object is OK

%>
<%@ include file="../SystemInfo.jsp" %>


<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Import Selection</title>
</head>

<body onLoad="initForm()">

<p><u><em><strong><font face="Arial"><big>File Import</big></font></strong></em></u></p>

<p><font face="Arial">Enter the name of the file to import:</font></p>

<form method="POST" action="" ENCTYPE="multipart/form-data" onSubmit="updateValues()">
<input type="hidden" name="importMethod" value="">
  <p><font face="Arial">Import file name:</font> 
  <input type="file" name="filename" size="50"></p>
  <p><font face="Arial">File type: </font> 
    <select name="importClass" size="1">
<%@ include file="ImportInfo.jsp" %>
<%      String class_name;
        String title_of_import;
        org.jdom.Element r;
        org.jdom.Element x = ImportDOM.getRootElement();
        java.util.List imports = x.getChildren("method");
        for (int i = 0; i < imports.size(); i++) {
           r = (org.jdom.Element) imports.get(i);
           class_name = r.getChild("class").getText();
           title_of_import = r.getChild("name").getText();

%>     <option value="<%= class_name %>"><%= title_of_import %></option>
<%     } 
%>
  </select></p>
  <p><font face="Arial">File Date: 
  <input type="text" name="standardDate" size="11"
  onChange="checkdate(document.forms[0].standardDate)"><a HREF="javascript:doNothing()"
  mysubst="2"
  onClick="setDateField(document.forms[0].standardDate); top.newWin = window.open('<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.html', 'cal', 'dependent=yes, width=210, height=230, screenX=200, screenY=300, titlebar=yes')">
  <img SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.gif" BORDER="0" WIDTH="16" HEIGHT="16"></a><font size="1">Popup Calendar</font></p>
  <p>Action:&nbsp;<select name="postAction" size="1">
        <option value="POST">Update database</option>
        <option selected value="TEST">Test only</option>
  </select></p>
  <p>&nbsp;</p>
  <p><input type="submit" value="Process above file" name="Process"></p>
</form>
</body>
<script LANGUAGE="JavaScript" SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.js"></script>
<script>
function initForm() {
  document.forms[0].action = parent.frames[1].defaultApps + "prepopulated/Launch.jsp";
  parent.frames[1].setDefaultDate(document.forms[0].standardDate,0);
//  document.forms[0].action = parent.frames[1].defaultApps + "prepopulated/multiDiagnostic.jsp";
}
function updateValues() {
   document.forms[0].importMethod.value = document.forms[0].importClass[document.forms[0].importClass.selectedIndex].text;
   return true;
}
</script>
</html>

