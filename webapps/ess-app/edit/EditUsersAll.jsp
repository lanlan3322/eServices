<%--
EditList.jsp - Show list of items to select for an edit
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
<jsp:useBean id = "TableDOM"
     class="ess.AdisoftDOM"
     scope="page" />


<%@ include file="../DBAccessInfo.jsp" %>
<% 
String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String CCode = "";
String database = request.getParameter("database");

String ownersName = request.getParameter("email");

boolean pFlag = PersFile.setPersInfo(ownersName); 
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
}

if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 

%>
<%@ include file="../SystemInfo.jsp" %>
<%@ include file="EditInfo.jsp" %>
<%
   Dt.setUserDateFormat(PersFile.getDateFormat());

   Reg.setConnection(PersFile.getConnection());
   Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

   String screenname = "userprimary_edit";//request.getParameter("screenname");

   String SQLCommand = EditDOM.getDOMTableValueFor(screenname,"selectlistsql");
   

   String listTitle = EditDOM.getDOMTableValueFor(screenname,"listtitle");
   String HTMLEditFileName = EditDOM.getDOMTableValueFor(screenname,"editscreen");

   org.jdom.Element specificEditElement = EditDOM.getElement(screenname);
   org.jdom.Element columns2Show = specificEditElement.getChild("showinlist");
   java.util.List columns = columns2Show.getChildren();

// Need to load my schema for later use in conversion

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

   String compareString = request.getParameter("comparestring");
   String searchString = request.getParameter("searchstring");

   //Log.println("[---] EditList.jsp $comparestring$: " + compareString);
   //Log.println("[---] EditList.jsp $searchstring$: " + searchString);

   if (compareString != null) SQLCommand = Reg.SQLReplace(SQLCommand,"$comparestring$",compareString); //compare needs to come in good - no Reg.repStr() performed.
   //if (searchString != null) SQLCommand = Reg.SQLReplace(SQLCommand,"$searchstring$",Reg.repStr("%"));
   SQLCommand = Reg.SQLReplace(SQLCommand,"$searchstring$",Reg.repStr("%"));
   SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",Reg.repStr(PersFile.getPersNum()));
   SQLCommand = Reg.SQLReplace(SQLCommand,"$company$",Reg.repStr(PersFile.getCompany()));
   SQLCommand = Reg.SQLReplace(SQLCommand,"$depart$",Reg.repStr(PersFile.getDepartment()));

   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   String SQLDateReplace = SystemDOM.getDOMTableValueFor("sql","datesql");

   String begDateStr = request.getParameter("begdate");
   String endDateStr = request.getParameter("enddate");
   String othDateStr = request.getParameter("otherdate");

   String begDate = null;
   String endDate = null;
   String othDate = null;

   if (SQLType.equals("MM/DD/YYYY")) { 
     if (begDateStr != null && !begDateStr.equals("")) begDate = begDateStr;
     if (endDateStr != null && !endDateStr.equals("")) endDate = endDateStr;
     if (othDateStr != null && !othDateStr.equals("")) othDate = othDateStr;
   } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
     if (begDateStr != null && !begDateStr.equals("")) begDate = Dt.getOracleDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
     if (endDateStr != null && !endDateStr.equals("")) endDate = Dt.getOracleDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));
     if (othDateStr != null && !othDateStr.equals("")) othDate = Dt.getOracleDate(Dt.getDateFromStr(othDateStr,PersFile.getDateFormat()));
   } else {    // s/b YYYY-MM-DD
     if (begDateStr != null && !begDateStr.equals("")) begDate = Dt.getSQLDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
     if (endDateStr != null && !endDateStr.equals("")) endDate = Dt.getSQLDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));
     if (othDateStr != null && !othDateStr.equals("")) othDate = Dt.getSQLDate(Dt.getDateFromStr(othDateStr,PersFile.getDateFormat()));
   }

   if (begDate != null)
   {
      begDate = Reg.SQLReplace(SQLDateReplace,"$date$",begDate);
      SQLCommand = Reg.SQLReplace(SQLCommand,"$begdate$",begDate);
   }

   if (endDate != null) 
   {
      endDate = Reg.SQLReplace(SQLDateReplace,"$date$",endDate);
      SQLCommand = Reg.SQLReplace(SQLCommand,"$enddate$",endDate);
   }
   if (othDate != null)
   {
      othDate = Reg.SQLReplace(SQLDateReplace,"$date$",othDate);
      SQLCommand = Reg.SQLReplace(SQLCommand,"$otherdate$",othDate);
   }

   if (Reg.setResultSet(SQLCommand)) { 

%>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <title><%= listTitle %></title>
     <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     </head>
     <body onLoad="initForm()">
     <h1><%= listTitle %></h1><h2>
<%   
//Define column variables here
     String columnValue; 
     String columnName;
     org.jdom.Element columnElement;

     String backcolor = "class=\"TableData offsetColor\"";
     String oldbackcolor = "class=\"TableData\"";
     String newbackcolor;
     int adjustment = 0; //see status.xml

     String editArray;

     java.sql.ResultSetMetaData MetaData = Reg.myResult.getMetaData();
     int numberOfColumns = MetaData.getColumnCount();
%>
     <script>
     //<%= SQLCommand %>//
     </script>
     <form>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">

            <tr>
            <td width="5%"></td>
     <%
            for (int i = 0; i < columns.size(); i++)
            { 
              columnElement = (org.jdom.Element) columns.get(i);
              columnName = columnElement.getName();   //put in a title attribute later
     %>     <td><u><%= Reg.getTrim(columnName) %></u></td>
     <%
            }

     %>
            <td width="5%"></td>
            </tr>

<% try {
     do { 
//Do the retrieve from the result set here - below is the row
            
            columnValues = new java.util.ArrayList();
            for (int i = 0; i < columns.size(); i++)
            { 
              columnElement = (org.jdom.Element) columns.get(i);
              columnName = columnElement.getName();
              columnValues.add(Reg.myResult.getString(columnName));
            }
            editArray = getArrayString(MetaData, Reg, Log, schemas, physicals, logicals, dates, Dt);

     %>     <tr>
            <td width="5%"  <%=backcolor%>><input type="checkbox" name="select_this_item" value="<%= getKeyDocument(Reg, Log, keyList,sqlTableName) %>"></td>
     <%
            for (int i = 0; i < columns.size(); i++)
            { 
              columnElement = (org.jdom.Element) columns.get(i);
              columnName = columnElement.getName();
              columnValue = (String) columnValues.get(i);
     %>     <td <%=backcolor%>><%= Reg.getTrim(columnValue) %></td>
     <%
            }

     %>
            <td width="5%" <%=backcolor%>><a href="javascript: void x(<%= editArray %>)"><span class="ExpenseReturnLink">Edit</span></a></td>
            </tr>
     <%     newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;

     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] EditList.jsp java.lang exception");
    ex.printStackTrace();
%>
    <h2>Error in the SQL logic - contact support.</h2>
<%  
  } //try
  Reg.close();
%>
  </table>
  </form>

<p align="right"><a class="ExpenseReturnLink" href="javascript: void history.go(-1)" tabindex="2">Return to previous screen</a></p>
<script>
function x(AddValue) {
  if (AddValue.length > 0) {
    parent.contents.setListBuffer(AddValue);
    parent.contents.TransWindow(parent.contents.defaultHome + 'edit/<%= HTMLEditFileName %>','ListBuffer');
  } else {
    alert("System is not able to fulfill this request.\nPlease try again.\nIf problem persists, contact support.");
  }
}

</script>
      <form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/edit/EditRemove.jsp">
        <input type="hidden" name="email" value>
        <input type="hidden" name="database" value>
        <input type="hidden" name="company" value>
        <input type="hidden" name="ccode" value>
        <input type="hidden" name="reference" value>
        <input type="hidden" name="xaction" value="remove">

      <p><input type="button" value="Remove" name="B1"onClick="Javascript: void Remove()">&nbsp; <span class="ExpenseTag">Click &quot;Remove&quot; to remove checked items from your list</span></p>
      </form>

      <script language="Javascript">

      function initForm() {
        if (parent.contents.getDBValue) {
          document.forms[1].name.value = parent.contents.getDBValue(parent.Header,"name");
          //reference was here
          document.forms[1].reference.value = "";
          document.forms[1].email.value = parent.contents.getDBValue(parent.Header,"email");
          document.forms[1].company.value = parent.company;
          document.forms[1].database.value = parent.database;
          document.forms[1].ccode.value = parent.CCode;
          document.forms[1].xaction.value = "remove";
        } else {
          setTimeout("parent.main.initForm()",1000);
        }    
      }

      function Remove(){
        var delim = "";
        var isIE = false;
        if (navigator.appVersion.indexOf("MSIE") > -1) isIE = true;
        for (var i = 0; i < document.forms[0].length; i++) {
          //if (isIE) {
             if (document.forms[0].elements[i].name == "select_this_item" && document.forms[0].elements[i].checked == true) {
               document.forms[1].reference.value += delim + document.forms[0].elements[i].value;
               delim = ";";   
             }
          //} else {  //otherwise the browser is assumed to be Mozilla comp.
          //   if (document.forms[0].elements[i].name == "select_this_item" && document.forms[0].elements[i].checked == true) {
          //     document.forms[1].reference.value += delim + document.forms[0].elements[i].value;
          //     delim = ";";   
          //   }
          //}
        }
        if (delim == ";") {
          if (confirm("Checked items will be permanently removed from your list.  Is it 'OK' to proceed?")) {
            document.forms[1].submit();
          } else {
            document.forms[1].reference = "";
          }
        } else {
          alert("Must check item(s) that you wish to remove");
        }
      }

      </script>

</body>
</html>

<% } else { %>
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>No employees</title>
    <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
    </head>
    <body>
    <p><div class="ExpenseTag">
    <%=PersFile.name%>, No records have been found matching the specified description.
    <% Log.println("[400] EditList.jsp No records where found."); %>
    </div></p>
    </body>
    <p align="right"><a class="ExpenseReturnLink" href="javascript: void history.go(-1)" tabindex="2">Return to previous screen</a></p>
    </html>
<% } //if (Reg.setResultSet(SQLCommand)) 

} else { %>
  <%@ include file="../ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 
%>

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


