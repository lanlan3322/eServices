<%--
ReportList.jsp - List reports in the central database for editing, viewing or removal
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

<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="page" />
<jsp:useBean id = "Reg2"
     class="ess.AdisoftDbase"
     scope="page" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" /> 
<jsp:useBean id = "SendInfo"
     class="ess.ServerSystemTable"
     scope="page" />
<jsp:useBean id = "TableDOM"
     class="ess.AdisoftDOM"
     scope="page" />

<%@ include file="SystemInfo.jsp" %>
<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="NumericSetup.jsp" %>
<%@ include file="edit/EditInfo.jsp" %>
<% 
Log.println("[000] ReportAuditList.jsp started");
String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String CCode = "";
String database = request.getParameter("database");

String ownersName = request.getParameter("email");
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

boolean pFlag = PersFile.setPersInfo(ownersName); 
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
}

if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
Reg.setConnection(PersFile.getConnection()); 
   Reg2.setConnection(PersFile.getConnection()); 
   Reg2.setSQLTerminator(PersFile.getSQLTerminator()); 
%>
<%@ include file="StatusInfo.jsp" %>
<%
Log.println("[000] ReportList.jsp 2");
%>
<%@ include file="../SendAnEmail.jsp" %>
<%

// these are used in conjunction with the SQL found in system.xml
   //String persnumber = PersFile.persnum;    //need to replace with a PersFile.get...()
	String SQLCommand = request.getParameter("reporttype");
	if(SQLCommand.equals(""))
	{
		String persnumber = request.getParameter("newLeavePer");
		String newLeaveStatue = "Pending";
		String newLeaveType = request.getParameter("newLeaveType");
		String newLeaveFrom = request.getParameter("newLeaveFrom");
		String newLeaveFromAMPM = request.getParameter("newLeaveFromAMPM");
		String newLeaveTo = request.getParameter("newLeaveTo");
		String newLeaveToAMPM = request.getParameter("newLeaveToAMPM");
		String newLeaveTotal = request.getParameter("newLeaveTotal");
		String newLeaveReason = request.getParameter("newLeaveReason");
		String currentDate = Dt.xBaseDate.format(Dt.date);
		String currentTime = Dt.getLocalTime();
		String newLeaveNum = persnumber.replace("0","") + currentTime.replace(":","");
		if(newLeaveNum.length() > 8){
			newLeaveNum = newLeaveNum.substring(0,8);
		}
		String email = "services@elc.com.sg";
		String manager = PersFile.getManager();
		String depart = PersFile.getDepartment();
		SQLCommand = "SELECT MANAGER, DEPART FROM USER WHERE PERS_NUM = '" + persnumber + "'" + PersFile.getSQLTerminator();
		if (Reg.setResultSet(SQLCommand)) {
			manager = PersFile.getTrim(Reg.myResult.getString(1));
			depart = PersFile.getTrim(Reg.myResult.getString(2));
		}

		newLeaveFrom = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(newLeaveFrom,PersFile.getDateFormat())));
		newLeaveTo = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(newLeaveTo,PersFile.getDateFormat())));
		SQLCommand = SystemDOM.getDOMTableValueFor("history","reporter_leave_new");
       SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",persnumber);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$depart$",depart);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavevo$",manager);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavenum$",newLeaveNum);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavetotal$",newLeaveTotal);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavecreated$",currentDate);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavetype$",newLeaveType);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavefrom$",newLeaveFrom);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavefromampm$",newLeaveFromAMPM);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leaveto$",newLeaveTo);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavetoampm$",newLeaveToAMPM);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavestatus$",newLeaveStatue);
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavereason$",newLeaveReason);
	   int SQLResult = Reg.doSQLExecute(SQLCommand);
	   SQLResult = 0;
	   if(SQLResult > -1){
			String SQLCommand2 = "SELECT EMAIL FROM USER WHERE PERS_NUM = '" + persnumber + "'" + PersFile.getSQLTerminator();
			if (Reg.setResultSet(SQLCommand2)) {
				email = PersFile.getTrim(Reg.myResult.getString(1));
				String pal_address = SendInfo.getSystemString("PAL_EMAIL_ADDRESS","services@elc.com.sg");
				String subject = "New pending leave created by HR: " + newLeaveReason;
				String msg = "There is a new pending leave created for you to apply.\nPlease submit it from http://services.elc.com.sg";
				SendAnEmail(email, pal_address, subject, msg, SendInfo);
			}
		   
%>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
<script type="text/javascript">
     if (screen.width < 1024) {
       var link = document.getElementsByTagName( "link" )[ 0 ];
       link.href = "<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense800.css";
     }
</script>     
<link rel="stylesheet" media="print" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/print.css" type="text/css">
     <title>New pending leave created:</title>
     </head>
     <body>
		<p><big><em><strong><font face="Arial">New pending leave created:</font></strong></em></big></p>
	<table border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="5%" align="right"><em><strong><font face="Arial"><span>User ID</span>: </font></strong></em></td>
      <td width="95%" align="left<span"><%= persnumber%></span></td>
    </tr>
    <tr>
      <td width="5%" align="right"><em><strong><font face="Arial"><span>User email</span>: </font></strong></em></td>
      <td width="95%" align="left<span"><%= email%></span></td>
    </tr>
    <tr>
      <td width="5%" align="right"><em><strong><font face="Arial"><span>Ref</span>: </font></strong></em></td>
      <td width="95%" align="left<span"><%= newLeaveNum%></span></td>
    </tr>
    <tr>
      <td width="5%" align="right"><em><strong><font face="Arial"><span>Type</span>: </font></strong></em></td>
      <td width="95%" align="left<span"><%= newLeaveType%></span></td>
    </tr>
    <tr>
      <td width="5%" align="right"><em><strong><font face="Arial"><span>From</span>: </font></strong></em></td>
      <td width="95%" align="left<span"><%= newLeaveFrom%></span><span><%= newLeaveFromAMPM%></span></td>
    </tr>
    <tr>
      <td width="5%" align="right"><em><strong><font face="Arial"><span>To</span>: </font></strong></em></td>
      <td width="95%" align="left<span"><%= newLeaveTo%></span><span><%= newLeaveToAMPM%></span></td>
    </tr>
    <tr>
      <td width="5%" align="right"><em><strong><font face="Arial"><span>Total</span>: </font></strong></em></td>
      <td width="95%" align="left<span"><%= newLeaveTotal%></span></td>
    </tr>
    <tr>
      <td width="5%" align="right"><em><strong><font face="Arial"><span>Comments</span>: </font></strong></em></td>
      <td width="95%" align="left<span"><%= newLeaveReason%></span></td>
    </tr>
  </table>

</body>
</html>

<% } else { %>
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>Introduction Page</title>
    </head>
    <body>
    <p><big><big><strong>Create new pending leave failed!</strong></big></big></p>
    </body>
    <script>
    //<%= SQLCommand %>//
    </script>
    </html>
<% } //if (Reg.setResultSet(SQLCommand)) 
	}//if create leave
	else
	{
	   String begDateStr = request.getParameter("begdate");
	   String endDateStr = request.getParameter("enddate");
	   String begDateSQL = "";
	   String endDateSQL = "";
	   if (begDateStr != null && !begDateStr.equals("")) begDateSQL = Dt.getSQLDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
	   if (endDateStr != null && !endDateStr.equals("")) endDateSQL = Dt.getSQLDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));
		SQLCommand = SQLCommand + DBSQLTerminator;
	   SQLCommand = Reg.SQLReplace(SQLCommand,"$begdate$",begDateSQL);
	   SQLCommand = Reg.SQLReplace(SQLCommand,"$enddate$",endDateSQL);
	   if (Reg.setResultSet(SQLCommand)) { %>
     <h1><%= Lang.getString("LEAVE_HISTORY")%></h1>
<%
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
     int adjustment = 0; //see status.xml
     java.sql.ResultSetMetaData MetaData = Reg.myResult.getMetaData();
     int numberOfColumns = MetaData.getColumnCount();
%>

<script type="text/javascript">
function x(AddValue) {
  if (AddValue.length > 0) {
    parent.contents.setListBuffer(AddValue);
    parent.contents.TransWindow(parent.contents.defaultHome + 'edit/edit_leave.html','ListBuffer');
  } else {
    alert("System is not able to fulfill this request.\nPlease try again.\nIf problem persists, contact support.");
  }
}

</script>     
     <table id="previousTable" border="1" cellspacing="0" cellpadding="0">
     <thead>
         <tr>
             <th width="5%" <%=backcolor%>>Name</th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_CREATED") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TYPE") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_FROM") %></th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_FROM_AMPM") %></th>
             <th width="10%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TO") %></th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_TO_AMPM") %></th>
             <th width="5%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_STATUS") %></th>
             <th width="5%" <%=backcolor%>>Total</th>
             <th width="25%" <%=backcolor%>><%= Lang.getColumnTitle("LEAVE_REASON") %></th>
             <th width="5%" <%=backcolor%>>Receipts</th>
             <th width="5%" <%=backcolor%>></th>
         </tr>
     </thead>
<%
    newbackcolor = backcolor;
    backcolor = oldbackcolor; 
    oldbackcolor = newbackcolor;
 
    try {
     do { 
        persname = PersFile.getTrim(Reg.myResult.getString(10));
        repStat = PersFile.getTrim(Reg.myResult.getString(12)); 
        reference = PersFile.getTrim(Reg.myResult.getString(1)); //used for subordinate lookup
        voucher = PersFile.getTrim(Reg.myResult.getString(7));
        pvoucher = PersFile.getTrim(Reg.myResult.getString(8));
        repdate = PersFile.getTrim(Reg.myResult.getString(9));  
        repamt = PersFile.getTrim(Reg.myResult.getString(11)); 
		reason = PersFile.getTrim(Reg.myResult.getString(13)); 
		created = PersFile.getTrim(Reg.myResult.getString(6)); 
		total = PersFile.getTrim(Reg.myResult.getString(5));
		String leaveNum = PersFile.getTrim(Reg.myResult.getString(4)); 
        editArray = getArrayString(MetaData, Reg, Log, schemas, physicals, logicals, dates, Dt);
     %>          
            <tr>
<%
			String SQLCommand3 = "SELECT FNAME FROM USER WHERE PERS_NUM =";
			SQLCommand3 += reference + PersFile.getSQLTerminator();
			if (Reg2.setResultSet(SQLCommand3)) {
%>
			<td width="5%" <%=backcolor%>><%= PersFile.getTrim(Reg2.myResult.getString(1))%></td>
			<%}else{%>
            <td width="5%" <%=backcolor%>><%= reference%></td>
			<%}%>
            <td width="10%" <%=backcolor%>><%= created%></td>
            <td width="10%" <%=backcolor%>><%= voucher%></td>
            <td width="10%" <%=backcolor%>><%= pvoucher%></td>
            <td width="5%"  <%=backcolor%>><%= repdate%></td>
            <td width="10%" <%=backcolor%>><%= persname%></td>
            <td width="5%"  <%=backcolor%>><%= repamt%></td>
            <td width="5%" <%=backcolor%>><%= repStat %></td>
            <td width="5%" <%=backcolor%>><%= total%></td>
            <td width="30%" <%=backcolor%>><%= reason%></td>
<%
			String SQLCommand2 = "SELECT PERS_NUM FROM SCAN WHERE SCAN_REF =";
			SQLCommand2 += leaveNum + PersFile.getSQLTerminator();
			if (Reg2.setResultSet(SQLCommand2)) {
				if(PersFile.getTrim(Reg2.myResult.getString(1)).equalsIgnoreCase(reference)){
%>
            <td width="5%" <%=backcolor%>><a href="javascript: void window.open('<%= PersFile.getAppServer()%>/<%= PersFile.getAppFolder()%>/receipts/ReceiptView.jsp?image=<%= leaveNum%>','Receipt_<%= leaveNum%>','dependent=yes, width=700, height=540, screenX=580, screenY=420, resizable, titlebar=yes, menubar=yes, status=no, scrollbars=yes')"><%= leaveNum%></a></td>
			<%}
			else{
%>
            <td width="5%" <%=backcolor%>></td>
			<%}}else{
%>
            <td width="5%" <%=backcolor%>></td>
			<%}%>
            <td width="5%" <%=backcolor%>><a href="javascript: void x(<%= editArray %>)"><span class="ExpenseReturnLink">Edit</span></a></td>
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

<% if (!xfound) { %>
<h2>
<%= Lang.getString("REPORTS_NOT_FOUND") %><br>
</h2>
<% } %>
<% } else { %>
    <div class="ExpenseTag">
    <%=PersFile.name%>, <%= Lang.getString("REPORTS_NOT_FOUND") %>
    <% Log.println("[400] ajax/HistoryList.jsp No expense reports where found."); %>
    </div>
<% } //if (Reg.setResultSet(SQLCommand)) 
%>          
<%   }//if enquiry leave
} else { %>
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 

%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>
<%!
private String getArrayString(java.sql.ResultSetMetaData x, ess.AdisoftDbase y, ess.AuditTrail l, String[] schemas, String[] physicals, String[] booleans, String[] dates, ess.CustomDate Dt)
{
 String comma = "";
 String retVal = "[";
 String columnName = "";
 String otherName = "";
 String columnValue = "";

 try {
   int numberOfColumns = x.getColumnCount();
   for (int i = 1; i <= numberOfColumns; i++)
   {
       retVal += comma;
       retVal += "['";
       columnName = x.getColumnName(i);
       columnName = columnName.toUpperCase();  //check why I need uppercase.
       otherName = returnOtherName(columnName, physicals, schemas);
       retVal += otherName;     
       retVal += "','";
       columnValue = y.myResult.getString(columnName);
       if (ess.Utilities.findString(otherName, booleans) > -1)
       {
         retVal += getBooleanValue(columnValue);
       } else if (ess.Utilities.findString(otherName, dates) > -1)
       {
         if (columnValue != null && !columnValue.equals("1899-12-30")) 
         {
            // retVal += Dt.getSimpleDate(Dt.getDateFromXBase(columnValue));
            retVal += Dt.getUserDateString(Dt.getDateFromXBase(columnValue));
         } 
       } else { 
         columnValue = y.getTrim(columnValue);
         retVal += repStr(columnValue);
       }
       retVal += "']";
       comma = ",";
   }
   retVal += "]"; 

 } catch (java.sql.SQLException e) {
   retVal = "[]";
   l.println("[500] EditList.getArrayString - error in extracting column information for: " + columnName);
   l.println("[500] " + e.toString());
 }
 return retVal;
}

private String returnOtherName(String name, String[] lookup, String[] return_name)
{
  String retVal = name;
  for (int i = 0; i < lookup.length; i++)
  {
     if (lookup[i].equalsIgnoreCase(name))
     {
       retVal = return_name[i];
       i = lookup.length; 
     }
  }
  return retVal;
}

private String getBooleanValue(String X) {
   String Default = "";
   if (X == null) X = "";
   if (X.equals("1")) {
      X = "Yes";
   } else {
      X = "No";
   }
   return X;
}

private String[] set2ArrayFromAL(java.util.ArrayList x)
{  
   String[] retArray = new String[x.size()];
   for (int i = 0; i < x.size(); i++)
   {
     retArray[i] = (String) x.get(i);
   }
   return retArray;
}

public static String repStr(String x) {
   x = repStr(x, "\"","'");
   x = repStr(x, "\\","\\\\"); // was "&#92"
   x = repStr(x, "\n","\\n");  // was "&#10;"
   x = repStr(x, "\r","");
   x = repStr(x, "'","\\'");

   return x; 
}
   
public static String repStr(String x, String oldChar, String newChar) 
{
   int startLocate = 0;
   int oldLength = oldChar.length();
   int newLength = newChar.length();
      
   int locate = x.indexOf(oldChar, startLocate);
   while (locate != -1) {
      x = x.substring(0,locate) + newChar + x.substring(locate + oldLength);
      startLocate = locate + newLength;
      locate = x.indexOf(oldChar, startLocate);
   }
   return x;
}

private String getKeyDocument(ess.AdisoftDbase y, ess.AuditTrail l, java.util.List keyList, String table)
{
 String retVal = "<remove table='" + table + "'>";
 String columnName;
 String columnValue;
 org.jdom.Element x;
 try {
   for (int i = 0; i < keyList.size(); i++)
   {
       x = (org.jdom.Element) keyList.get(i);
       columnName = x.getName();
       columnName = columnName.toUpperCase();
       columnValue = y.myResult.getString(columnName);
//       columnValue = ess.Utilities.getXMLString(y.getTrim(columnValue));
       columnValue = y.getTrim(columnValue);
       retVal += "<" + columnName + ">";
       retVal += columnValue;
       retVal += "</" + columnName + ">";
   }

 } catch (java.sql.SQLException e) {
   retVal = "[]";
   l.println("[500] EditList.getKeyDocument - error in extracting key document information");
   l.println("[500] " + e.toString());
   e.printStackTrace();
 }
 retVal += "</remove>";
 return retVal;
}

%>


