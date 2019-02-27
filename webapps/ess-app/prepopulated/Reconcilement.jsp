<%--
Reconcilement.jsp - Reconcilement screen
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
<jsp:useBean id = "DB"
     class="ess.AdisoftDbase"
     scope="page" />     
     
<%@ include file="../DBAccessInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>

<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Reconciliation</title>
<link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
</head>

<body onLoad="init()">

<p><em><strong><font face="Arial"><big>Pre-populated Reconcilement</big></font></strong></em></p>

<p><font face="Arial">Select Items from the list below to be matched against each other.
&nbsp; To select an item, either double click it or highlight the line and select the &quot;Add to reconcilement
list&quot; button.&nbsp; You will normally select one or more items from the expense system
to be matched against one item from the vendors statement.</font></p>
<font face="Arial">Side | Payment | Trans Date | Statement | Amount | Reference</font>
<form method="POST" action="javascript: void addItem(document.forms[0].displayList,document.forms[1].displayList,document.forms[1].balance,1,document.forms[1].message)" onDblClick="javascript: void addItem(document.forms[0].displayList,document.forms[1].displayList,document.forms[1].balance,1,document.forms[1].message)">
  <div align="left"><p><select name="displayList" size="10">

  <jsp:include page="ItemsGather.jsp" flush="true"/>

  </select></p>
  </div><input type="submit" value="Add to reconcilement list" name="Add">
</form>
<input type="button" value="Sort by amount" name="S1" onClick="javascript: void SortList(document.forms[0].displayList,3)">&nbsp;&nbsp;
<input type="button" value="Sort by date" name="S2" onClick="javascript: void SortList(document.forms[0].displayList,4)"></p>



<p><font face="Arial">After you have selected the items that match each other, the
list below should balance to zero.&nbsp; You can then select&nbsp; 
the &quot;Post reconcilement&quot;&nbsp; button below and the reconciliation will be 
posted to the database.</font></p>

<form name="reconciled" method="POST" action="javascript: void postItem(document.reconciled.displayList, document.reconciled.balance)">
  <div align="left"><p><font face="Arial">Reconcilement List:&nbsp; </font></p>
  </div><div align="left"><p>
  <table>
  <tr>
  <td>
  <select name="displayList" size="5">
  </select>
  </td>
  <td>  <input type="text" name="message" value readOnly=true></td>
  </tr>
  </table>

  </div><div align="left"><p><font face="Arial">Balance: </font><input type="text" name="balance" size="14" readOnly=true></p>
  </div><div align="left"><p><input type="submit" value="Post reconcilement" name="Reconcile"> 
  <input type="button" value="Remove" name="Remove" onClick="javascript: void addItem(document.forms[1].displayList,document.forms[0].displayList,document.forms[1].balance,-1,document.forms[1].message)">
  </p>
  </div>
</form>

<p><font face="Arial">After you have finished reconciling the current vendor card, you can
access a new card by entering the personnel number and card type below and then selecting the
&quot;Access account&quot; button.</font></p>

<form name="searchForm" method="POST" action="<%= PersFile.getAppServer()%>/<%= PersFile.getAppFolder()%>/prepopulated/Reconcilement.jsp">
  <input type="hidden" name="email" value>
  <input type="hidden" name="database" value>
  <table>
  <tr>
  <td><font face="Arial">Personnel Number:</font></td><td><input type="text" name="employee" size="16">
  <a class="ExpenseLink" href="javascript:doNothing()" onClick="setLocalJsp(document.forms[2].employee,'UserPersNum',900,300);MerchantType = 'user'"><sm><em>Lookup!</em></sm></a>  
  </td>
  </tr>
  <tr>
  <td><font face="Arial">Vendor/Payment Method:</font></td><td><select name="vendor" size="1">
  <% DB.setConnection(PersFile.getConnection()); 
     String SQLCommand = SystemDOM.getDOMTableValueFor("prepopulateditems","selectpaymenttypes");   
     if (SQLCommand.equals("")) SQLCommand = "SELECT DISTINCT CHARGE FROM CHARGE ORDER BY CHARGE" + PersFile.getSQLTerminator();
     SQLCommand = DB.SQLReplace(SQLCommand,"$company$",PersFile.getCompany());
     if (DB.setResultSet(SQLCommand)) {
    	    do {
    	       %> <option><%= DB.myResult.getString(1) %></option> <%
    	    } while (DB.myResult.next());
     } else {
      %><option selected>No valid payment types!</option><%
     }
  %>
  </select></td>
  </tr>
  <tr>
  <td><input type="submit" font face="Arial" value="Access Account" name="submit"></td><td></td>
  </tr>
  </table>
</form>

<p>&nbsp;</p>

<p>&nbsp;</p>

<script LANGUAGE="JavaScript" SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.js"></script>
<script LANGUAGE="JavaScript" SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/validation.js"></script>
<script LANGUAGE="JavaScript" SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/addmerchant.js"></script>
<script language="javascript">

function init() {
  document.searchForm.email.value = parent.frames[1].getNameValue(parent.Header, "email");
  document.searchForm.database.value = parent.database;
  //parent.frames[1].setList(document.forms[2].vendor, parent.frames[1].getPaymentTypes("2"));
}


function addItem(inputList,outputList, totalField, addOrSubtract, messageField)
{
   var x = inputList.selectedIndex;
   var z = inputList.length;
   if (x == null || x < 0)
   {
      alert("Need to select an item from the list before using this button");
   } else {
      var y = outputList.length;
      outputList.length = y + 1;
      outputList.options[y].text = inputList.options[x].text;
      outputList.options[y].value = inputList.options[x].value;
      for (var i = x; i < z - 1; i++)
      { 
         inputList.options[i].text = inputList.options[i + 1].text;
         inputList.options[i].value = inputList.options[i + 1].value;
      } 
      inputList.length = z - 1;

      if (totalField != null)
      {
         var y;
         y = eval(outputList.options[y].value);
         var amt = totalField.value;
         if (amt == null || amt == "") amt = "0.00";
         amt = parseFloat(amt) + (addOrSubtract * y[2] * y[3]);
         totalField.value = amt;

         if (amt == 0.0)
         {
           messageField.value = "Items are in balance";
         } else {
           messageField.value = "";
         }
      }
   }
}

function postItem(inList, totalField) {

   var amt = totalField.value;
   if (amt == null || amt == "") amt = "0.00";
   amt = parseFloat(amt);

   if ((amt == 0.0) || confirm("Items do not balance to zero.\nIs it OK to post items as reconciled?"))
   {
      parent.activityFlag = true;  //set this before using the Hidden frame for anything...

      var y;
      var z = inList.length;
      var x = new Array(z);
      for (var i = 0; i < z; i++)
      {
         y = eval(inList.options[i].value);
         x[i] = new Array(2);
         x[i][0] = y[0];
         x[i][1] = y[1];
      }

      parent.frames[3].document.open("text/html");
      parent.frames[3].document.write("<html>\n");
      parent.frames[3].document.write("<head><title>Post Reconcilement</title></head>\n");
      parent.frames[3].document.write("<body onLoad=\"JavaScript: void doit()\">\n");
      parent.frames[3].document.write("<form method=\"POST\" action=\"" + parent.frames[1].defaultApps + "prepopulated/Post.jsp\">\n");
      parent.frames[3].document.write("<input type=\"hidden\" name=\"dataElement\" value=\"" + CreateXML(x) + "\">\n");
      parent.frames[3].document.write("<input type=\"hidden\" name=\"email\" value=\"" + parent.frames[1].getNameValue(parent.Header, "email") + "\">\n");
      parent.frames[3].document.write("<input type=\"hidden\" name=\"ccode\" value=\"" + parent.CCode + "\">\n");
      parent.frames[3].document.write("</form>\n");
      parent.frames[3].document.write("<scr" + "ipt>\n");
      parent.frames[3].document.write("function doit(){\n");
      parent.frames[3].document.write("document.forms[0].submit();\n");
      parent.frames[3].document.write("}\n");
      parent.frames[3].document.write("</scr" + "ipt></body></html>\n");
      parent.frames[3].document.close();
   }
}

function CreateXML (x) {
  y = x.length;
  z = "<post>";
  for (var i = 0; i < y; i++) {
    z += "<perform>";
    z += "<table>" + x[i][0] + "</table>";
    z += "<action>statusok</action>";
    z += "<key>" + x[i][1] + "</key>";
    z += "</perform>";
  }
  z +="</post>"
  return z;
}

function SortList(x, column) {
  var y = new Array(x.length);
  var z = new Array(x.length);
  var j;
  for (var i = 0; i < y.length; i++) {
     y[i] = [i, column, eval(x.options[i].value)];
     z[i] = [x.options[i].text, x.options[i].value];
  }
  y.sort(xCompare);
  for (var i = 0; i < y.length; i++) {
     j = y[i][0];
     x.options[i].text = z[j][0];
     x.options[i].value = z[j][1];
  }
}

function xCompare(a, b) {
  var retVal = 0;
  if (a[2][a[1]] > b[2][b[1]]) {
    retVal = 1;
  } else {
    if (a[2][a[1]] < b[2][b[1]]) retVal = -1;
  }
  return retVal;
}

/* 
  function xCompDate(a, b) {
  var retVal = 0;
  var aDate = Date.parse(a[2][a[1]]);
  var bDate = Date.parse(b[2][b[1]]);
  
  if (aDate > bDate) {
    retVal = 1;
  } else {
    if (aDate < bDate) retVal = -1;
  }
  return retVal;
}
*/

</script>

</body>
</html>
