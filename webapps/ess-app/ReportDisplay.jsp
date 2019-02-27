<html>
<!--
ReportDisplay.html - Create list for returning from audit reports
Copyright (C) 2007 R. James Holton

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
-->

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Report Selection for Audit Usage</title>
<link rel="stylesheet" href="expense.css" type="text/css">
</head>

<body onLoad="submitReport()">

<form method="POST" action="ReportAuditList.jsp">
  <input type="hidden" name="email" value>
  <input type="hidden" name="ccode" value>
  <input type="hidden" name="xaction" value>
  <input type="hidden" name="database" value>
  <input type="hidden" name="reportclass" value="form">
  <input type="hidden" name="reporttype" value="SELECT * FROM REPORT WHERE">
</form>

<script LANGUAGE="JavaScript" SRC="calendar.js"></script>
<script LANGUAGE="JavaScript" SRC="addmerchant.js"></script>
<script LANGUAGE="JavaScript">

function submitReport() {
  with(document.forms[0]) {

    var lastDisplay = parent.contents.getLastDisplay()
    action = parent.contents.defaultApps + lastDisplay;
    email.value = parent.contents.getNameValue(parent.Header, "email");
    database.value = parent.database;
    ccode.value = parent.CCode;
    xaction.value = "List";
    reporttype.value = parent.contents.getLastSQL();

    document.forms[0].submit();
  }
}

</script>

</body>
</html>
