<%--
Post.jsp - posts reconcilments to prepopulated and receipts file
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
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "DB"
     class="ess.AdisoftDbase"
     scope="session" />
<jsp:useBean id = "TableDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />     
<%

String email = request.getParameter("email"); 

boolean pFlag = PersFile.setPersInfo(email); 
Log.println("[000] Post.jsp by: " + email);
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 

Log.println("[000] Post.jsp security OK");
%>


<%@ include file="../DBAccessInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>
<%

DB.setConnection(PersFile.getConnection()); 
TableDOM.setConnection(PersFile.getConnection()); 
TableDOM.setDOM(request.getParameter("dataElement"));

org.jdom.Element rootElement = TableDOM.getRootElement();
java.util.List perform = rootElement.getChildren();

org.jdom.Element currentAction;
String SQLCommand;

String table;
org.jdom.Element action;
String actionStr;
String key;

org.jdom.Element post = SystemDOM.getElement("post");
org.jdom.Element actionElement;

boolean OKFlag = true;

for (int i = 0; i < perform.size(); i++) {
  
  currentAction = (org.jdom.Element) perform.get(i);

  table = currentAction.getChild("table").getText();
  actionStr = currentAction.getChild("action").getText();
  key = currentAction.getChild("key").getText();
  Log.println("[000] Post.jsp item: " + table + ", " + actionStr + ", " + key);
  
  action = post.getChild(actionStr);
  
  SQLCommand = action.getChild(table).getTextNormalize();

  SQLCommand = DB.SQLReplace(SQLCommand,"$rowkey$",key);
// do something with the auto commit
  if (DB.doSQLExecute(SQLCommand) == -1) {
    OKFlag = false; 
  }     
}

%>

<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Transaction Post</title>
</head>
<body onLoad="Javascript: void PostComplete()">
</body>
<script>
function PostComplete() {
<%
if (OKFlag)
{
%>
parent.frames[2].reconciled.displayList.length = 0;
parent.frames[2].reconciled.message.value = "Post OK";
parent.frames[2].reconciled.balance.value = "";
<%
} else {
%>
parent.frames[2].reconciled.message.value = "Posting Error";
<%
}
%>
}
</script>
</html>
<%
} else {
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Test</title>
</head>
<body>
<script>
parent.frames[2].reconciled.message.value = "Login issue";
</script>
</body>
</html>
<%
} 
%>