<!--
SimpleReport.jsp - Runs a simple report (MIS) 
Copyright (C) 2004,2005 R. James Holton

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
<%@ page contentType="text/html" %>
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />
<!-- Later on need to add the login check stuff -->
<%  String  webserver = PersFile.getWebServer() + "/" + PersFile.getWebFolder() + "/";
String check = "[";
String field1name = "[";
String field2name = "[";
String field3name = "[";
String field4name = "[";
String Q = "\"";
String C = ",";
String Delim = "";
%><html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title><%= Lang.getString("genericSimDatInq")%></title>
<link rel="stylesheet" href="expense.css" type="text/css"></head>

<body onLoad="init()">

<p align="center"><big><em><strong><font face="Arial"><%= Lang.getString("simpleDatInq")%></font></strong></em></big></p>

<form method="POST" action="ReportGenerator.jsp">
  <input type="hidden" name="email" value>
  <input type="hidden" name="ccode" value>
  <input type="hidden" name="database" value>
  <input type="hidden" name="field3" value>
  <input type="hidden" name="field4" value>
  <input type="hidden" name="reportclass" value>
  <div align="center"><center><table border="0" cellpadding="0" cellspacing="0" width="80%">
    <tr>
      <td width="49%" align="right"><em><strong><font face="Arial"><%= Lang.getString("reportRun")%>:</font></strong></em></td>
      <td width="51%"><select name="reporttype" size="1" onChange="javascript: void setLabels()">
<%@ include file="ReportInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<%      String element_name;
        String title_of_report;
        String class_of_report;
        String userFunction = PersFile.getFunction().toUpperCase();
        org.jdom.Element r;
        org.jdom.Element r2;
        org.jdom.Element x = ReportDOM.getRootElement();
        java.util.List reports = x.getChildren();
        for (int i = 0; i < reports.size(); i++) {
           r = (org.jdom.Element) reports.get(i);
           element_name = r.getName();
           title_of_report = r.getChild("pulldown").getText();
           class_of_report = ";AUDITOR;";
           r2 = r.getChild("users"); 
           if (r2 != null) {
               class_of_report = r2.getText().toUpperCase();
           } 
           if (class_of_report.indexOf(userFunction) > -1 || class_of_report.indexOf("ALL") > -1) {
%>     <option value="<%= element_name %>"><%= title_of_report %></option><% 
             check = BuildArray(check, r.getChild("check"), Delim, Q);
             field1name = BuildArray(field1name, r.getChild("field1name"), Delim, Q);
             field2name = BuildArray(field2name, r.getChild("field2name"), Delim, Q);
             field3name = BuildArray(field3name, r.getChild("field3name"), Delim, Q);
             field4name = BuildArray(field4name, r.getChild("field4name"), Delim, Q);
             Delim = C;
          }
       } 
       check += "]";
       field1name += "]";
       field2name += "]";
       field3name += "]";
       field4name += "]";
%>
      </select></td>
    </tr>
    <tr>
      <td width="49%" align="right"><em><strong><font face="Arial"><%= Lang.getString("firstDat")%>: </font></strong></em></td>
      <td width="51%"><input type="text" name="begdate" size="11" onChange="checkdate(document.forms[0].begdate)"><a HREF="javascript:doNothing()" mysubst="2" onClick="setDateField(document.forms[0].begdate); top.newWin = window.open('<%= webserver %>calendar.html', 'cal', 'dependent=yes, width=210, height=230, screenX=200, screenY=300, titlebar=yes')"><img SRC="<%= webserver %>calendar.gif" BORDER="0" WIDTH="16" HEIGHT="16"></a></td>
    </tr>
    <tr>
      <td width="49%" align="right"><em><strong><font face="Arial"><%= Lang.getString("secondDat")%>: </font></strong></em></td>
      <td width="51%"><input type="text" name="enddate" size="11" onChange="checkdate(document.forms[0].enddate)"><a HREF="javascript:doNothing()" mysubst="2" onClick="setDateField(document.forms[0].enddate); top.newWin = window.open('<%= webserver %>calendar.html', 'cal', 'dependent=yes, width=210, height=230, screenX=200, screenY=300, titlebar=yes')"><img SRC="<%= webserver %>calendar.gif" BORDER="0" WIDTH="16" HEIGHT="16"></a></td>
    </tr>
    <tr>
      <td width="49%" align="right" ID="label1"><em><strong><font face="Arial"><%= Lang.getString("fieldOne")%>: </font></strong></em></td>
      <td width="51%" ID="fld1"><input type="text" name="field1" size="11"></td>
    </tr>
    <tr>
      <td width="49%" align="right" ID="label2"><em><strong><font face="Arial"><%= Lang.getString("fieldTwo")%>: </font></strong></em></td>
      <td width="51%" ID="fld2"><input type="text" name="field2" size="11"></td>
    </tr>
    
    
  </table>
  </center></div><div align="center"><center><p><input type="button" value="<%= Lang.getString("displayLis")%>" name="B1" onClick="submitReport()"></p>
  </center></div>
</form>

<p><big>&nbsp;</big></p>

<p><big><%= Lang.getString("instructions")%>:&nbsp; </big>

<ul>
  <li><%= Lang.getString("selectTypRep")%></li>
  <li><%= Lang.getString("enterReqDatVal")%></li>
  <li><%= Lang.getString("clickDisLisBut")%></li>
</ul>

<p>&nbsp;</p>
<script LANGUAGE="JavaScript" SRC="<%= webserver %>calendar.js"></script>
<script LANGUAGE="JavaScript">

var check = <%= check %>;
var field1name = <%= field1name %>;
var field2name = <%= field2name %>;
var field3name = <%= field3name %>;
var field4name = <%= field4name %>;

function init() {
  document.forms[0].action = parent.contents.defaultApps + "ReportGenerator.jsp";
  parent.contents.setDefaultDate(document.forms[0].begdate,-30);
  parent.contents.setDefaultDate(document.forms[0].enddate,0);
  setLabels();
}


function submitReport() {
  if (checkdate(document.forms[0].begdate) 
   && checkdate(document.forms[0].enddate)) {

      document.forms[0].email.value = parent.contents.getNameValue(parent.Header, "email");
      document.forms[0].database.value = parent.database;
      document.forms[0].ccode.value = parent.CCode;
      document.forms[0].reportclass.value = "simplereports";
      document.forms[0].field3.value = "";
      document.forms[0].field4.value = "";
      document.forms[0].submit();
  }
}

function setLabels()
{
  var ptr = document.forms[0].reporttype.selectedIndex;  
  setAField(document.all.label1, field1name[ptr], document.all.fld1, "field1");
  setAField(document.all.label2, field2name[ptr], document.all.fld2, "field2");
}

function setAField(ylabel, xLabel, xfield, xfldname)
{
    if (xLabel != "")
    {
       ylabel.innerHTML = "<em><strong><font face=\"Arial\">" + xLabel + ":&nbsp;<\/font><\/strong><\/em>"; 
       xfield.innerHTML = "<input type=\"text\" name=\"" + xfldname + "\" size=\"11\">";

    } else {
       ylabel.innerHTML = "";
       xfield.innerHTML = "";
    }
}        
</script>
</body>
</html>

<%@ include file="BuildArray.jsp" %>

