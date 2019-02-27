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
 
<%@ include file="../DBAccessInfo.jsp" %>
<%

Log.println("[000] UploadSelectAudit.jsp by: " + PersFile.getEmailAddress());

String persnumber = PersFile.getPersNum();

String CCode = "";
// Check to see if the personnelSession object is OK

Reg.setConnection(PersFile.getConnection());

Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

%>
<%@ include file="../SystemInfo.jsp" %>


<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Receipt Upload Selection</title>
</head>

<body onLoad="initForm()">

<p><u><em><strong><font face="Arial"><big>Receipt Scan File Upload</big></font></strong></em></u></p>

<p><font face="Arial">Enter information about the scan file to upload.</font></p>

<form method="POST" action="" ENCTYPE="multipart/form-data" onSubmit="return checkInput()">
  
  <p><font face="Arial">Receipt file (use browse button):</font> 
  <input type="file" name="filename" size="50"></p>
  <p><font face="Arial">Attach to report: </font> 
    <select name="pvoucher" size="1">
<%     

       String reference;
       String pvoucher;
       String reporter;
       String voucherViewed;

	   voucherViewed = PersFile.getReportViewed();
       String SQLCommand = SystemDOM.getDOMTableValueFor("receiptmanagement","uploadselectsqlaudit");  //runs against report table
       SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",persnumber);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",persnumber);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$level$",PersFile.getMenuLevel());
       SQLCommand = Reg.SQLReplace(SQLCommand,"$function$",PersFile.getFunction());
       SQLCommand = Reg.SQLReplace(SQLCommand,"$owner$",PersFile.getEmailAddress());
       
       Log.println("[000] UploadSelectAudit.jsp Upload SQL:" + SQLCommand);
       if (PersFile.isAuditor() || PersFile.isGLAdmin()) {
       if (Reg.setResultSet(SQLCommand)) {
        	do{	
        		reference = PersFile.getTrim(Reg.myResult.getString(1));
        		pvoucher = reference;
            	// pvoucher = "0000000" + reference;
            	// pvoucher = contructPVoucher(pvoucher.substring(pvoucher.length() - 8), SysTable);  //adjust for a prefix
       		
        		try {
            		reporter = PersFile.getTrim(Reg.myResult.getString(2));
        		} catch (java.sql.SQLException e) {
        			reporter = persnumber;
        		}
            	if (pvoucher.equals(voucherViewed)) {
                   	%>     <option selected value="<%= pvoucher + ";" + reporter  %>"><%= reference %>*</option>
                   	<%
                	} else{
                	%>     <option value="<%= pvoucher + ";" + reporter  %>"><%= reference %></option>
                	<%
                	}

       		} while (Reg.myResult.next());
       } 
       } else {
    	   Log.println("[500] UploadSelectAudit.jsp Security error:" + persnumber);
       }
%>

  </select></p>
  <p>&nbsp;</p>
  <p><input type="submit" value="Process above file" name="Process"></p>
</form>

<p>&nbsp;</p>

<p><u><em><strong><font face="Arial"><big>Receipt Scan File Management</big></font></strong></em></u></p>

<p><font face="Arial">Enter information about the scan file to view or remove.</font></p>

<form method="GET" action="" ENCTYPE="multipart/form-data">
  
  <p><font face="Arial">Select associated report: </font> 
    <select name="pvoucher" size="1" onChange="Javascript: void selectRemoveFiles()">
    <option value=""></option>
    
<%     

       // Testing SQLCommand = SystemDOM.getDOMTableValueFor("receiptmanagement","removeselectsql");
       // SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",persnumber);
       // SQLCommand = Reg.SQLReplace(SQLCommand,"$level$",PersFile.getMenuLevel());
       // SQLCommand = Reg.SQLReplace(SQLCommand,"$function$",PersFile.getFunction());

       Log.println("[000] UploadSelectAudit.jsp Remove SQL:" + SQLCommand);

       if (Reg.setResultSet(SQLCommand)) {
        	do{	
        		reference = PersFile.getTrim(Reg.myResult.getString(1));
        		pvoucher = reference;
            	// pvoucher = "0000000" + reference;
            	// pvoucher = contructPVoucher(pvoucher.substring(pvoucher.length() - 8), SysTable);  //adjust for a prefix

        		try {
            		reporter = PersFile.getTrim(Reg.myResult.getString(2));
        		} catch (java.sql.SQLException e) {
        			reporter = persnumber;
        		}
            	if (pvoucher.equals(voucherViewed)) {
                   	%>     <option selected value="<%= pvoucher + ";" + reporter  %>"><%= reference %>*</option>
                   	<%
                	} else{
                	%>     <option value="<%= pvoucher + ";" + reporter  %>"><%= reference %></option>
                	<%
                	}
       		} while (Reg.myResult.next());
     } 
%>

  </select></p>
  
    <p> <span id="scanFiles"><font face="Arial">Scan files will appear after report selection.</font></span></p>
  
</form>
<p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p>
</body>
<script LANGUAGE="JavaScript" SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.js"></script>
<script>
function initForm() {
  document.forms[0].action = parent.contents.defaultApps + "receipts/Upload.jsp";
  selectRemoveFiles();
}
function checkInput() {

  return true;
}
  
function selectRemoveFiles() {
    if (document.forms[1].pvoucher.selectedIndex > 0) {
   		var ParamString = "?pvoucher=" + document.forms[1].pvoucher.options[document.forms[1].pvoucher.selectedIndex].value
//   alert("This is selected: " + ParamString);
   		document.getElementById("scanFiles").innerHTML = "<b><i>Searching for scan files...</i></b>";   
   		loadHTMLAJAX(ParamString);
   	} else {
   		document.getElementById("scanFiles").innerHTML = "<font face='Arial'>Scan files will appear after report selection.</font>";
    }
}

//AJAX stuff below here
var httpXMLObj;

function loadHTMLAJAX(params) {
  httpXMLObj = GetXmlHttpObject();
  var LoadJSP = parent.appServer + "/" + parent.appFolder + "/receipts/ReceiptScans.jsp" + params;
//  alert(LoadJSP);
  getInfo(httpXMLObj, LoadJSP, stateChanged, true);
}

function stateChanged() {
  var x = httpXMLObj.readyState;
  if ( x == 4 )
  { 
       var newHTML = httpXMLObj.responseText;
       document.getElementById("scanFiles").innerHTML = newHTML;
  }
}

//AJAX functions for communicating with the server 1/29/2008
// xmlHttp -> HTTP Request Object, define globally in calling object/script (i.e., var xmlHttp;)
// url -> url to execute (i.e., var url="/ess-app/AJAXTest.jsp";)
// stateChanged -> name of routine to run
// aSync -> true runs asynchronously (i.e., parallel), false run serially
function getInfo(xmlHttp, url, stateChanged, aSync)
{
  if (xmlHttp==null)
  {
    alert ("Your browser does not support AJAX!");
    return;
  } 
  if (aSync == null) aSync = true;
  xmlHttp.onreadystatechange=stateChanged;
  xmlHttp.open("GET",url,aSync);
  xmlHttp.send(null);
} 


function GetXmlHttpObject()
{
  var xmlHttp=null;
  try
  {
  // Firefox, Opera 8.0+, Safari
    xmlHttp=new XMLHttpRequest();
  }
  catch (e)
  {
  // Internet Explorer
  try
    {
      xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
    }
    catch (e)
    {
      xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
    }
  }
return xmlHttp;
}

  
  
</script>
</html>

<%@ include file="../ConstructPVoucher.jsp" %>