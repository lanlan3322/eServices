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

Reg.setConnection(PersFile.getConnection());

Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

%>


<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Create new storage</title>
</head>

<body onLoad="initForm()">

<p><u><em><strong><font face="Arial"><big>Update stock</big></font></strong></em></u></p>

<p><font face="Arial">Enter information about the new stock.</font></p>

<form method="POST" action="" ENCTYPE="multipart/form-data" onSubmit="return checkInput()">
	<input type="hidden" name="action" value="create">
	<input type="hidden" name="cat" value="create">
	<input type="hidden" name="store" value="create">
	<input type="hidden" name="reason" value="New stock created">
	<input type="hidden" name="requestType" value="Update">
  <table border="0" cellpadding="10" cellspacing="10">
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Category</span>: </font></strong></em></td>
		<td class="expenseType"><select name="category" xref="cat" class="limited-width" onMouseDown="if(document.all) this.className='expanded-width';" onBlur="if(document.all) this.className='limited-width';" onChange="createCat();"></select></td>
    </tr>
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Name</span>: </font></strong></em></td>
      <td width="85%" align="left"><input type="text" name="name"></td>
    </tr>
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Description</span>: </font></strong></em></td>
      <td width="85%" align="left"><input type="text" name="desc"></td>
    </tr>
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Amount</span>: </font></strong></em></td>
      <td width="85%" align="left"><input type="text" name="amount"></td>
    </tr>
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Storage</span>: </font></strong></em></td>
		<td class="expenseType"><select name="storage" xref="storage" class="limited-width" onMouseDown="if(document.all) this.className='expanded-width';" onBlur="if(document.all) this.className='limited-width';"></select></td>
    </tr>
	<tr>
		<td width="15%" align="right"><em><strong><font face="Arial">Upload Image:</font></strong></em></td>
		<td  width="85%" align="left"><input type="file" name="filename" size="50">  Only .jpeg format supported!</td>
	</tr>

	<tr>
		<td width="15%"/>
		<td  width="85%" align="left"><input id="butLeaveCreate" type="submit" value="Add" name="B1"></td>
    </tr>
  </table>  

</form>
<p><u><em><strong><font face="Arial"><big>Stock List:</big></font></strong></em></u></p>
<%
String SQLCommand = "SELECT * FROM db_item ORDER BY item_category, item_name" + PersFile.getSQLTerminator();
if (Reg.setResultSet(SQLCommand)) { 
     String E;         //     ditto
     boolean xFlag;
     boolean xfound = false;
     String voucher = "";
     String pvoucher = "";
     String name = "";
     String cat = "";
     String desc = "";
     String amount = "";
     String dCreated = "";
     String dDelivered = "";
     String status = "";
	 String holder = "";
	 String storage = "";
     String backcolor = "class=\"TableData offsetColor\"";
     String oldbackcolor = "class=\"TableData\"";
     String newbackcolor;

%>

     <table id="previousTable" border="1" cellspacing="0" cellpadding="0">
     <thead>
         <tr>
<!--
             <th width="10%" <%=backcolor%>>id</th>
-->
             <th width="25%" <%=backcolor%>>Name</th>
             <th width="10%" <%=backcolor%>>Category</th>
             <th width="40%" <%=backcolor%>>Description</th>
             <th width="5%" <%=backcolor%>>Amount</th>
             <th width="10%" <%=backcolor%>>Created</th>
             <th width="10%" <%=backcolor%>>Holder</th>
             <th width="10%" <%=backcolor%>>Storage</th>
             <th width="5%" <%=backcolor%>></th>
             <th width="5%" <%=backcolor%>></th>
         </tr>
     </thead>
<%
    newbackcolor = backcolor;
    backcolor = oldbackcolor; 
    oldbackcolor = newbackcolor;
 
    try {
     do { 
        pvoucher = PersFile.getTrim(Reg.myResult.getString(1));
        name = PersFile.getTrim(Reg.myResult.getString(2));
        cat = PersFile.getTrim(Reg.myResult.getString(3));
        desc = PersFile.getTrim(Reg.myResult.getString(4)); 
        amount = PersFile.getTrim(Reg.myResult.getString(5)); 
        dCreated = PersFile.getTrim(Reg.myResult.getString(6)); 
        dDelivered = PersFile.getTrim(Reg.myResult.getString(7)); 
        status = PersFile.getTrim(Reg.myResult.getString(8)); 
        holder = PersFile.getTrim(Reg.myResult.getString(9)); 
        storage = PersFile.getTrim(Reg.myResult.getString(10)); 
		
		
     %>          
            <tr>

<!--
            <td width="10%" <%=backcolor%>><%= pvoucher%></td>
-->
            <td width="25%" <%=backcolor%>><a href="javascript: void window.open('<%= PersFile.getAppServer()%>/<%= PersFile.getAppFolder()%>/inventory/images/<%= status%>.jpeg','dependent=yes, width=700, height=540, screenX=580, screenY=420, resizable, titlebar=yes, menubar=yes, status=no, scrollbars=yes')"><%= name%></a></td>
            <td width="10%" <%=backcolor%>><%= cat%></td>
            <td width="40%" <%=backcolor%>><%= desc%></td>
            <td width="5%" <%=backcolor%>><%= amount%></td>
            <td width="10%" <%=backcolor%>><%= dCreated%></td>
<!--
            <td width="10%" <%=backcolor%>><%= dDelivered%></td>
            <td width="5%" <%=backcolor%>><%= status%></td>
-->
            <td width="10%" <%=backcolor%>><%= holder%></td>
            <td width="10%" <%=backcolor%>><%= storage%></td>
            <td width="5%" <%=backcolor%>><a href="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/receipts/inventoryStockEdit.jsp?id=<%=pvoucher%>&cat=<%= cat%>&name=<%= name%>&desc=<%= desc%>&amount=<%= amount%>&image=<%= status%>">Edit</a></td>
            <td width="5%" <%=backcolor%>><a href="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/receipts/inventoryStockDelete.jsp?id=<%=pvoucher%>&cat=<%= cat%>&name=<%= name%>&desc=<%= desc%>&amount=<%= amount%>">Delete</a></td>
            </tr>
     <%     xfound = true;
            newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] ajax/HistoryList.jsp java.lang exception possibly voucher: " + voucher);
    Log.println("[500] ajax/HistoryList.jsp exception toString : " + ex.toString()); 
    ex.printStackTrace();
%>
    <h2>Error in the SQL logic - contact support.<h2>
<%  
  } //try
%>
  </table>

<% } //if (Reg.setResultSet(SQLCommand)) 
%>          

<p align="right"><a class="ExpenseReturnLink" href="javascript: void history.go(-1)">Return to previous screen</a></p>

</body>
<script>
function initForm() {
	document.forms[0].action = parent.contents.defaultApps + "receipts/inventoryStockUpload.jsp";
	document.forms[0].amount.value = "1";
	if(document.forms[0].category){
		parent.contents.setListWithValue(document.forms[0].category,parent.contents.getCatTypes(),0,1,true,true,1);
		document.forms[0].category.options[0].text = "(Create new)"; 
		document.forms[0].category.options[0].value = "(Create new)";
		document.forms[0].category.selectedIndex = 1;
	}
	if(document.forms[0].storage){
		parent.contents.setListWithValue(document.forms[0].storage,parent.contents.getStorage(),0,1,true,true,1);
		document.forms[0].storage.selectedIndex = 1;
	}
}
function checkInput() {
	document.forms[0].cat.value = document.forms[0].category.options[document.forms[0].category.selectedIndex].text;
	document.forms[0].store.value = document.forms[0].storage.options[document.forms[0].storage.selectedIndex].text;
  return true;
}
function createCat(){
	//alert(document.forms[0].cat.selectedIndex);
	if(document.forms[0].category.selectedIndex == 0){
		parent.contents.PersWithDBase(parent.contents.defaultApps + "receipts/inventoryCatAdd.jsp?downlevel=","approvallevel","1");
	}
	
}
</script>
</html>
