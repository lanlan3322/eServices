<%--
UploadSelect.jsp - Specifies which file to import 
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
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="page" />     
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "TableDOM"
     class="ess.AdisoftDOM"
     scope="page" />

<%@ include file="../SystemInfo.jsp" %>
<%@ include file="../edit/EditInfo.jsp" %>
<%@ include file="../DBAccessInfo.jsp" %>
<%

String persnumber = PersFile.getPersNum();
String name = request.getParameter("name");
String id = request.getParameter("id");
String threshold = request.getParameter("threshold");


%>


<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Create new Storage</title>
</head>

<body onLoad="initForm()">

<p><u><em><strong><font face="Arial"><big>Edit Storage</big></font></strong></em></u></p>

<p><font face="Arial">Edit information about the Storage.</font></p>

<form method="POST" action="" onSubmit="return checkInput()">
	<input type="hidden" name="id" value=<%= id %>>
	<input type="hidden" name="action" value="update">
	
  <table border="0" cellpadding="10" cellspacing="10">
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Storage Name</span>: </font></strong></em></td>
      <td width="85%" align="left"><input type="text" name="leaveReason" maxlength="100" value="<%= name %>" style="font-size: 12pt; height: 30px; width:480px; "></td>
    </tr>
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Description</span>: </font></strong></em></td>
      <td width="85%" align="left"><input type="text" name="leaveTotal" maxlength="100" value="<%= threshold %>" style="font-size: 12pt; height: 30px; width:480px; "></td>
    </tr>

	<tr>
		<td width="15%"/>
		<td  width="85%" align="left"><input id="butLeaveCreate" type="submit" value="Update" name="B1"></td>
    </tr>
  </table>  

</form>

<p align="right"><a class="ExpenseReturnLink" href="javascript: void history.go(-1)">Return to previous screen</a></p>

</body>
<script>
function initForm() {
  document.forms[0].action = parent.contents.defaultApps + "receipts/inventoryStorageUpload.jsp";
  //selectRemoveFiles();
}
function checkInput() {

  return true;
}
</script>
</html>

