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

//String persnumber = PersFile.getPersNum();
String name = request.getParameter("name");
String cat = request.getParameter("cat");
String desc = request.getParameter("desc");
String amount = request.getParameter("amount");
String id = request.getParameter("id");



%>


<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Create new Stock</title>
</head>

<body onLoad="initForm()">

<p><u><em><strong><font face="Arial"><big>Edit Stock</big></font></strong></em></u></p>

<p><font face="Arial">Edit information about the Stock.</font></p>

<form method="POST" action="" ENCTYPE="multipart/form-data" onSubmit="return checkInput()">
	<input type="hidden" name="id" value=<%= id %>>
	<input type="hidden" name="action" value="update">
	<input type="hidden" name="cat" value=<%= cat %>>
	<input type="hidden" name="requestType" value="Update">
  <table border="0" cellpadding="10" cellspacing="10">
<!--    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Category</span>: </font></strong></em></td>
		<td class="expenseType"><select name="category" xref="cat" class="limited-width" onMouseDown="if(document.all) this.className='expanded-width';" onBlur="if(document.all) this.className='limited-width';" onChange="createCat();"></select></td>
    </tr>-->
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Name</span>: </font></strong></em></td>
      <td width="85%" align="left"><input type="text" name="name" maxlength="100" value="<%= name %>"  style="font-size: 12pt; height: 30px; width:480px; "></td>
    </tr>
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Description</span>: </font></strong></em></td>
      <td width="85%" align="left"><input type="text" name="desc" maxlength="100" value="<%= desc %>"  style="font-size: 12pt; height: 30px; width:480px; "></td>
    </tr>
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">New Amount</span>: </font></strong></em></td>
      <td width="85%" align="left"><input type="text" name="amount" maxlength="100" value="<%= amount %>"  style="font-size: 12pt; height: 30px; width:480px; "></td>
    </tr>
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Old Amount</span>: </font></strong></em></td>
      <td width="85%" align="left"> <%= amount %></td>
    </tr>
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Edit Reason</span>: </font></strong></em></td>
      <td width="85%" align="left"><input type="text" name="reason" maxlength="100" value="Update from stock checking"  style="font-size: 12pt; height: 30px; width:480px; "></td>
    </tr>
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Edit Type</span>: </font></strong></em></td>
      <td width="85%" align="left">
			<select name="act" value="">
				<option value="Return">Returned by User</option>
				<option value="Update" selected>Updated by Admin</option>
			</select>
		</td>
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
  document.forms[0].action = parent.contents.defaultApps + "receipts/inventoryStockUpload.jsp";
	//document.forms[0].amount.value = "1";
	/*if(document.forms[0].category){
		parent.contents.setListWithValue(document.forms[0].category,parent.contents.getCatTypes(),0,1,true,true,1);
		document.forms[0].category.options[0].text = "(Create new)"; 
		document.forms[0].category.options[0].value = "(Create new)";
		document.forms[0].category.selectedIndex = 1;
	}*/
}
function checkInput() {
	//document.forms[0].cat.value = document.forms[0].category.options[document.forms[0].category.selectedIndex].text;
	document.forms[0].requestType.value = document.forms[0].act.options[document.forms[0].act.selectedIndex].value;
  return true;
}

</script>
</html>

