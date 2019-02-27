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

Log.println("[000] UploadSelectAudit.jsp by: " + PersFile.getEmailAddress());
String editArray;
   String screenname = "userprimary_edit";
   String tableName = EditDOM.getDOMTableValueFor(screenname,"table"); 
   String sqlTableName = EditDOM.getDOMTableValueFor(screenname,"sqltable"); //JH 2007-05-24
   String schemaFileName = SystemDOM.getDOMTableValueFor("configuration","xmlschema");
   java.io.File schemaFile = new java.io.File(schemaFileName);
   TableDOM.setDOM(schemaFile);
   org.jdom.Element schemaElement = TableDOM.getElement(tableName);

   org.jdom.Element schemaColumns = schemaElement.getChild("columns");
   java.util.List columnList = schemaColumns.getChildren();

   org.jdom.Element schemaKey = schemaElement.getChild("key");
   java.util.List keyList = schemaKey.getChildren();

   org.jdom.Element tag;
   org.jdom.Attribute tagInfo;
   org.jdom.Attribute nameInfo;
   java.util.ArrayList columnValues; 
   String tagName;
   String otherName;
   String physicalName;
   String type;

   java.util.ArrayList logicalFields = new java.util.ArrayList();
   java.util.ArrayList dateFields = new java.util.ArrayList();

   java.util.ArrayList schemaNames = new java.util.ArrayList();
   java.util.ArrayList physicalNames = new java.util.ArrayList();
/*
   for (int i = 0; i < columnList.size(); i++)
   {
      tag = (org.jdom.Element) columnList.get(i);
      tagName = tag.getName();
      nameInfo = tag.getAttribute("physical");
      if (nameInfo == null || nameInfo.getValue().trim().equals(""))
      {
         otherName = tagName;

      } else {
         otherName = nameInfo.getValue().trim();
      }
      physicalNames.add(otherName);
      schemaNames.add(tagName);

      tagInfo = tag.getAttribute("type");
      type = tagInfo.getValue();
      if (type.equals("logical")) logicalFields.add(tagName);
      if (type.equals("date")) dateFields.add(tagName);
   }
   String[] logicals = set2ArrayFromAL(logicalFields); 
   String[] dates = set2ArrayFromAL(dateFields); 
   String[] physicals = set2ArrayFromAL(physicalNames); 
   String[] schemas = set2ArrayFromAL(schemaNames); 
*/
String persnumber = PersFile.getPersNum();
String name = request.getParameter("name");
String id = request.getParameter("id");
String threshold = request.getParameter("threshold");
String image = request.getParameter("image");

String CCode = "";
// Check to see if the personnelSession object is OK

Reg.setConnection(PersFile.getConnection());

Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

%>


<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Create new category</title>
</head>

<body onLoad="initForm()">

<p><u><em><strong><font face="Arial"><big>Edit category</big></font></strong></em></u></p>

<p><font face="Arial">Edit information about the category and the image to upload.</font></p>
<p><img src="<%= PersFile.getAppServer()%>/<%= PersFile.getAppFolder()%>/inventory/category/<%= image%>.jpeg" height="150"></img></p>

<form method="POST" action="" ENCTYPE="multipart/form-data" onSubmit="return checkInput()">
	<input type="hidden" name="id" value=<%= id %>>
	<input type="hidden" name="action" value="update">
	
  <table border="0" cellpadding="10" cellspacing="10">
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Category Name</span>: </font></strong></em></td>
      <td width="85%" align="left"><input type="text" name="leaveReason" value=<%= name %>></td>
    </tr>
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Threshold</span>: </font></strong></em></td>
      <td width="85%" align="left"><input type="text" id="leaveTotal" name="leaveTotal" value=<%= threshold %>></td>
    </tr>
	<tr>
		<td width="15%" align="right"><em><strong><font face="Arial">New Image:</font></strong></em></td>
		<td  width="85%" align="left"><input type="file" name="filename" size="50"></td>
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
  document.forms[0].action = parent.contents.defaultApps + "receipts/inventoryCatUpload.jsp";
  //selectRemoveFiles();
}
function checkInput() {

  return true;
}
</script>
</html>

<%@ include file="../ConstructPVoucher.jsp" %>
