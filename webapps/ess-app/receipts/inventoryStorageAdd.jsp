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

<p><u><em><strong><font face="Arial"><big>Create new storage</big></font></strong></em></u></p>

<p><font face="Arial">Enter information about the new storage.</font></p>

<form method="POST" action="" onSubmit="return checkInput()">
	<input type="hidden" name="action" value="create">
  <table border="0" cellpadding="10" cellspacing="10">
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Storage Name</span>: </font></strong></em></td>
      <td width="85%" align="left"><input type="text" name="leaveReason"></td>
    </tr>
    <tr>
      <td width="15%" align="right"><em><strong><font face="Arial"><span id="comments">Description</span>: </font></strong></em></td>
      <td width="85%" align="left"><input type="text" name="leaveTotal"></td>
    </tr>

	<tr>
		<td width="15%"/>
		<td  width="85%" align="left"><input id="butLeaveCreate" type="submit" value="Submit" name="B1"></td>
    </tr>
  </table>  

</form>
<p><u><em><strong><font face="Arial"><big>Storage List:</big></font></strong></em></u></p>
<%
String SQLCommand = "SELECT * FROM db_storage" + PersFile.getSQLTerminator();
if (Reg.setResultSet(SQLCommand)) { 
     String persname;
     String E;         //     ditto
     boolean xFlag;
     boolean xfound = false;
     String voucher = "";
     String pvoucher = "";
     String reference;
     String repdate;
     String repamt;
     String repStat;
     String repDBStat;
	 String total;
	 String reason;
	 String created;
     String backcolor = "class=\"TableData offsetColor\"";
     String oldbackcolor = "class=\"TableData\"";
     String newbackcolor;

%>

     <table id="previousTable" border="1" cellspacing="0" cellpadding="0">
     <thead>
         <tr>
             <th width="10%" <%=backcolor%>>ID</th>
             <th width="10%" <%=backcolor%>>Name</th>
             <th width="70%" <%=backcolor%>>Description</th>
             <th width="10%" <%=backcolor%>></th>
         </tr>
     </thead>
<%
    newbackcolor = backcolor;
    backcolor = oldbackcolor; 
    oldbackcolor = newbackcolor;
 
    try {
     do { 
        persname = PersFile.getTrim(Reg.myResult.getString(2));
        reference = PersFile.getTrim(Reg.myResult.getString(1)); //used for subordinate lookup
        repamt = PersFile.getTrim(Reg.myResult.getString(3)); 
     %>          
            <tr>

            <td width="10%" <%=backcolor%>><%= reference%></td>
            <td width="10%" <%=backcolor%>><%= persname%></td>
            <td width="70%" <%=backcolor%>><%= repamt%></td>
            <td width="10%" <%=backcolor%>><a href="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/receipts/inventoryStorageEdit.jsp?id=<%= reference%>&name=<%= persname%>&threshold=<%= repamt%>">Edit</a></td>
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
  document.forms[0].action = parent.contents.defaultApps + "receipts/inventoryStorageUpload.jsp";
  //selectRemoveFiles();
}
function checkInput() {

  return true;
}
</script>
</html>
