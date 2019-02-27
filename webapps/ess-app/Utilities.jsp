<%--
Report.jsp - Main ESS frameset 
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
<jsp:useBean id = "Extract"
     class="ess.EditTables"
     scope="page" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />
                    
<%-- See Login.jsp for other beans being used --%>
<%
Extract.setConnection(PersFile.getConnection()); 
Extract.setSQLTerminator(PersFile.getSQLTerminator());

Lang.setLanguage(PersFile.getLanguage());

String essCustomFolder = SystemDOM.getDOMTableValueFor("configuration","customfolder","ess");
String essAppFolder = SystemDOM.getDOMTableValueFor("configuration","appfolder","ess-app");
String essWebFolder = SystemDOM.getDOMTableValueFor("configuration","webfolder","ess");
String essDateFormat = SystemDOM.getDOMTableValueFor("configuration","dateformat","MM/dd/yyyy"); //Not yet used

%>
<html>
<!-- Copyright Adisoft, Inc. 2002, All rights reserved -->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Main Report Frame</title>
</head>
<script language = "Javascript">
var database = "<%= database %>";
var company = "<%= company %>";
var syslevel = "ess 8.0.0";
var DateObj = new Date();

var Header = new Array();  //Report header information
Header[0] = ["persnum","<%= PersFile.getPersNum() %>"];
Header[1] = ["name","<%= PersFile.getName() %>"];
Header[2] = ["phone","<%= PersFile.getPhone() %>"];
Header[3] = ["location","<%= PersFile.getLocation() %>"];
Header[4] = ["depart","<%= PersFile.getDepartment() %>"];
Header[5] = ["credate","<%= CD.getStrFromDate(CD.date,PersFile.getDateFormat()) %>"];
Header[6] = ["cretime","<%= CD.getSimpleTime(CD.date) %>"];
Header[7] = ["admin1","<%= PersFile.getPersNum() %>"];
Header[8] = ["email","<%= PersFile.getEmailAddress() %>"];
Header[9] = ["status","New"];
Header[10] = ["currency","<%= PersFile.getCurrency() %>"];
Header[11] = ["company","<%= PersFile.getCompany() %>"];
Header[12] = ["dateformat","<%= PersFile.getDateFormat() %>"];
Header[13] = ["numberformat","<%= PersFile.getNumberFormat() %>"];

var Vehicle = "<%= PersFile.vehicle %>";
<% if (!PersFile.getServiceDate().equals("")) { %>
var Servdate ="<%= CD.getSimpleDate(CD.getDateFromXBase(PersFile.getServiceDate())) %>";
<% } else { %>
var Servdate ="";
<% } %>
var Weekend = "<%= CD.getPreviousWeekend(CD.date) %>";
var Mileage = "<%= PersFile.getMileage() %>"; 
var MList = <%= Extract.getMileage(PersFile.getCompany()) %>;
var Category = "<%= PersFile.getCategory() %>";
var Level = "<%= PersFile.getSecurityLevel() %>";
var PersDBase = <%= Rep2.getDBase() %>;
var PersDBSave = false;
var WorkDBase = [];
var defPurpose = "0";  //used in calendar.js
var defDateStr = ""
var CCode = "<%= PersFile.getChallengeCode()%>";

var CommOK = false;
var activityFlag = true;
var messageFlag = true;

var webServer = "<%= PersFile.getWebServer() %>";
var appServer = "<%= PersFile.getAppServer() %>";
var customFolder = "<%= essCustomFolder %>";
var webFolder = "<%= essWebFolder %>";
var appFolder = "<%= essAppFolder %>";
<% if (PersFile.isAuditor()) {%>var isAuditor = true; <%} else {%>var isAuditor = false;<%}%> 
<% if (PersFile.isAdmin() || PersFile.isClerk(PersFile.getDepartment())) {%>var isClerk = true; <%} else {%>var isClerk = false;<%}%>
var language  = "<%= PersFile.getLanguage() %>";
var dateFormat  = "<%= PersFile.getDateFormat() %>";
var numberFormat  = "<%= PersFile.getNumberFormat() %>";
var decimal = "<%= PersFile.getDecimal() %>";
var separator = "<%= PersFile.getSeparator() %>";

window.defaultStatus = "Please wait, javascript is loading...";
function SetCommOK() {
  CommOK = true;
  window.defaultStatus = "Expense client is ready.";
  sendLog();

  parent.contents.setGeneralLimit("<%= PersFile.getCurrency() %>");
  parent.contents.DirectEdit = false;  
  parent.contents.setDBPair(parent.PersDBase,"last_report", "");

}

function SetLogoutOK() {
  if (parent.contents.HeadList.length > 0 && !parent.contents.ReportIsSaved && parent.contents.getDBValue(parent.PersDBase,"cookie").toUpperCase() != "NO") {
      parent.contents.CreateCookies();
      newWin = window.open('<%= PersFile.getWebServer() %>/<%= essWebFolder %>/' + parent.contents.getCustomFolder() + '/recover.html', 'InvalidExit', 'dependent=no, width=580, height=440, screenX=580, screenY=420, titlebar=yes, menubar=no, status=no, scrollbars=yes');
  }
}

function sendLog() {
  if (!activityFlag) {
    parent.hidden.location = "<%= PersFile.getAppServer() %>/<%= essAppFolder %>/logging/Log.jsp?email=<%=email%>&database=<%=database%>&ccode=<%=PersFile.getChallengeCode()%>";
  } else {
    activityFlag = false;  
  }
  var timehandle = setTimeout("sendLog()", 900000);
}

</script>

<frameset framespacing="0" border="false" frameborder="0" rows="70,*" onLoad="SetCommOK()"  onUnLoad="SetLogoutOK()">
  <frame name="banner" scrolling="no" noresize src="<%= PersFile.getWebServer() %>/<%= essWebFolder %>/<%= essCustomFolder %>/banner.html" target="contents">
  <frameset cols="160,*,1">
    <frame name="contents" src="<%= PersFile.getWebServer() %>/<%= essWebFolder %>/<%= SystemDOM.getDOMTableValueFor("configuration","customfolder","ess") %>/content<%= PersFile.getMenuLevel() %>.html" target="main">
    <frame name="main" src="">
    <frame name="hidden" src="<%= PersFile.getAppServer() %>/<%= essAppFolder %>/logging/InitialMessageCheck.jsp?email=<%=email%>&database=<%=database%>&ccode=<%=PersFile.getChallengeCode()%>">
  </frameset>
  <noframes>
  <body>
  <p>This page uses frames, but your browser doesn't support them.</p>
  </body>
  </noframes>
</frameset>
</html>

