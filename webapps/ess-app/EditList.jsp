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
   Reg.setConnection(PersFile.getConnection());
   Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

   String screenname = request.getParameter("screenname");

   String SQLCommand = EditDOM.getDOMTableValueFor(screenname,"selectlistsql");
   Log.println("[000] EditList.jsp SQL:" + SQLCommand);

   String listTitle = EditDOM.getDOMTableValueFor(screenname,"listtitle");
   String HTMLEditFileName = EditDOM.getDOMTableValueFor(screenname,"editscreen");

   org.jdom.Element specificEditElement = EditDOM.getElement(screenname);
   org.jdom.Element columns2Show = specificEditElement.getChild("showinlist");
   java.util.List columns = columns2Show.getChildren();

// Need to load my schema for later use in conversion

   String tableName = EditDOM.getDOMTableValueFor(screenname,"table");
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

   String searchString = request.getParameter("searchstring");

   String begDate = request.getParameter("begdate");
   String endDate = request.getParameter("enddate");

   if (searchString != null) SQLCommand = Reg.SQLReplace(SQLCommand,"$searchstring$",Reg.repStr(searchString.toUpperCase()) + "%");

   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   String SQLDateReplace = SystemDOM.getDOMTableValueFor("sql","datesql");

   if (begDate != null)
   {
      if (!SQLType.equals("MM/DD/YYYY")) { 
         String begDateSQL = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(begDate)));
         begDate = begDateSQL;
      }
      begDate = Reg.SQLReplace(SQLDateReplace,"$date$",begDate);
      SQLCommand = Reg.SQLReplace(SQLCommand,"$begdate$",begDate);
   }

   if (endDate != null) 
   {
      if (!SQLType.equals("MM/DD/YYYY")) { 
         String endDateSQL = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(endDate)));
         endDate = endDateSQL;
      }
      endDate = Reg.SQLReplace(SQLDateReplace,"$date$",endDate);
      SQLCommand = Reg.SQLReplace(SQLCommand,"$enddate$",endDate);
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

     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
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
            <td width="5%"  <%=backcolor%>><input type="checkbox" name="select_this_item" reference="<%= getKeyDocument(Reg, Log, keyList,tableName) %>"></td>
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
    parent.frames[1].setListBuffer(AddValue);
    parent.frames[1].TransWindow(parent.frames[1].defaultHome + 'edit/<%= HTMLEditFileName %>','ListBuffer');
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
        <input type="hidden" name="status" value>
        <input type="hidden" name="action" value="remove">

      <p><input type="button" value="Remove" name="B1"onClick="Javascript: void Remove()">&nbsp; <span class="ExpenseTag">Click &quot;Remove&quot; to remove checked items from your list</span></p>
      </form>

      <script language="Javascript">

      function initForm() {
        if (parent.frames[1].getDBValue) {
          document.forms[1].name.value = parent.frames[1].getDBValue(parent.Header,"name");
          //reference was here
          document.forms[1].reference.value = "";
          document.forms[1].email.value = parent.frames[1].getDBValue(parent.Header,"email");
          document.forms[1].company.value = parent.company;
          document.forms[1].database.value = parent.database;
          document.forms[1].ccode.value = parent.CCode;
          document.forms[1].status.value = "";
          document.forms[1].action.value = "remove";
        } else {
          setTimeout("parent.frames[2].initForm()",1000);
        }    
      }

      function Remove(){
        var delim = "";
        for (var i = 0; i < document.forms[0].length; i++) {
          if (document.forms[0].elements[i].name == "select_this_item" && document.forms[0].elements[i].checked == true) {
            document.forms[1].reference.value += delim + document.forms[0].elements[i].reference;
            document.forms[1].status.value += delim + document.forms[0].elements[i].value;
            delim = ";";   
          }
        }
        if (delim == ";") {
          if (confirm("Checked items will be permanently removed from your list.  Is it 'OK' to proceed?")) {
            document.forms[1].submit();
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
    <% Log.println("[400] Edit-List.jsp No records where found."); %>
    </div></p>
    </body>
    <p align="right"><a class="ExpenseReturnLink" href="javascript: void history.go(-1)" tabindex="2">Return to previous screen</a></p>
    </html>
<% } //if (Reg.setResultSet(SQLCommand)) 
//Close canApprove when it is changed...
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
            retVal += Dt.getSimpleDate(Dt.getDateFromXBase(columnValue));
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


