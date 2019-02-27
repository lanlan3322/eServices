<%--
SQLGenerator.jsp - list results of an ad hoc sql statement
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
<jsp:useBean id = "SQLCheck"
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
<%@ include file="DBAccessInfo.jsp" %>
<% 
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
<%@ include file="ReportInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<%
   Reg.setConnection(PersFile.getConnection()); 
   SQLCheck.setConnection(PersFile.getConnection()); 

   java.util.Date currentDate = Dt.getDate();
   String currentDateString = Dt.getSimpleDate(currentDate);
   String currentTimeString = Dt.getSimpleTime(currentDate);
 
// these are used in conjunction with the SQL found in system.xml
   String reportclass = request.getParameter("reportclass"); //corres. to system element/section
   String reporttype = request.getParameter("reporttype"); //corres. to system sub-element of above

   String begDateStr = request.getParameter("begdate");
   String endDateStr = request.getParameter("enddate");
   String field1 = request.getParameter("field1");
   String field2 = request.getParameter("field2");
   String field3 = request.getParameter("field3");
   String field4 = request.getParameter("field4");
   
   String performChecks = request.getParameter("performchecks");
   if (performChecks == null) performChecks = "Yes"; 

   if (begDateStr == null) begDateStr = "01/01/1970";
   if (endDateStr == null) endDateStr = "12/31/2030";
   if (field1 == null) field1 = "";
   if (field2 == null) field2 = "";
   if (field3 == null) field3 = "";
   if (field4 == null) field4 = "";

   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   String SQLDateReplace = SystemDOM.getDOMTableValueFor("sql","datesql");
   String begDateSQL = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(begDateStr)));
   String endDateSQL = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(endDateStr)));

   String begDateXB;
   String endDateXB;
   if (SQLType.equals("MM/DD/YYYY")) { 
	     begDateXB = begDateStr;
	     endDateXB = endDateStr;
   } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
	     begDateXB = Dt.getOracleDate(Dt.getDateFromStr(begDateStr));
	     endDateXB = Dt.getOracleDate(Dt.getDateFromStr(endDateStr));
   } else {    // s/b YYYY-MM-DD
	     begDateXB = begDateSQL;
	     endDateXB = endDateSQL;
   }

   String SQLCommand;
   if (reportclass.equals("form")) {
     SQLCommand = reporttype;
   } else {
     SQLCommand = ReportDOM.getDOMTableValueFor(reporttype,"sql");
   }
   SQLCommand = Reg.SQLReplace(SQLCommand,"$begdate$",SQLDateReplace);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$date$",begDateXB);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$enddate$",SQLDateReplace);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$date$",endDateXB);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$begdatestr$",begDateStr);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$enddatestr$",endDateStr);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$begdatesql$",begDateSQL);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$enddatesql$",endDateSQL);

   SQLCommand = Reg.SQLReplace(SQLCommand,"$field1$",field1);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$field1$",field2);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$field1$",field3);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$field1$",field4);

   Log.println("[000] SQLGenerator.jsp SQL:" + SQLCommand);
   Log.println("[000] SQLGenerator.jsp begDate:" + begDateXB + " SQL: " + begDateSQL);
   Log.println("[000] SQLGenerator.jsp endDate:" + endDateXB + " SQL: " + endDateSQL);

   boolean validCommand = (SQLCommand.toUpperCase().indexOf("SELECT") == 0);
   validCommand = (SQLCommand.toUpperCase().indexOf("PASSWORD") == -1);

   if (validCommand && Reg.setResultSet(SQLCommand)) { %>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <title>Report: + <%=reporttype%></title>
     <link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     <script type="text/javascript">
     if (screen.width < 1024) {
        var link = document.getElementsByTagName( "link" )[ 0 ];
        link.href = "<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense800.css";
     }
     </script>
     <link rel="stylesheet" media="print" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/print.css" type="text/css">
     </head>
     <body>
<%@ include file="StandardTopNR.jsp" %>
<%
     String xTitle = "Ad hoc query";

%>     
     <br><br>
     <strong><em>
     <big>Report: <%= xTitle %></big><br>
     <big>Query: <%= reporttype %></big><br>
     Run date: <%=currentDateString %> at <%=currentTimeString %><br> 
     </em></strong><br><br>
     
<%   String persname; 
     boolean xFlag;
     boolean xfound = false;
     String repdate;
     String display = "";
     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
     String newbackcolor;
     int adjustment = 0; //see status.xml

     java.sql.ResultSetMetaData MetaData = Reg.myResult.getMetaData();
     int numberOfColumns = MetaData.getColumnCount();
%>
     <script>
     //<%= SQLCommand %>//
     </script>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
     <tr>
<%
     for (int k = 1; k <= numberOfColumns; k++) { 
%>
                 <td><u><%= MetaData.getColumnName(k).toUpperCase()%></u></td>
<%   }
%>
     </tr>
<%
   try {
     do { 
     %>          
            <tr>
     <%
            for (int k = 1; k <= numberOfColumns; k++) {
              display = PersFile.getTrim(Reg.myResult.getString(k));
              if (MetaData.getColumnType(k) == java.sql.Types.DATE) {
                   display = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromXBase(display)));
              }
              if (MetaData.getColumnName(k).equalsIgnoreCase("PASSWORD")) {
                   display = "*****";
              }
      %>
            <td <%=backcolor%>><%= display%></td>
      <%
            } 

      %>  
            </tr>
      <%    xfound = true;
            newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;
     } while (Reg.myResult.next());

  } catch (java.lang.Exception ex) {
    Log.println("[500] SQLGenerator.jsp exception : " + ex.toString());
    ex.printStackTrace();
%>
    <strong><em><br>Error in the SQL logic - contact support.<br></em></strong>
    <script>
    // Error: <%= ex.toString() %>
    </script>
<%  
  } //try
  Reg.close();
%>
  </table>
<% if (!xfound) { %>
<strong><em>
No information found in database matching your description.<br>
</em></strong>
<% } %>
          
<br><br><strong><big><em>End of Ad Hoc SQL Query<br>
</em></big></strong><br><br>

<%@ include file="StandardBottomNR.jsp" %>

</body>
</html>

<% } else { %>
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>Introduction Page</title>
    </head>
    <body>
    <p><big><big><strong>No information has been extracted.
    <% if (validCommand)  
       {
          Log.println("[400] SQLGenerator.jsp No information extracted.");
       } else {
          Log.println("[500] SQLGenerator.jsp Invalid Command received.");
       }
    %>
    </strong></big></big></p>
    </body>
    <script>
    //<%= SQLCommand %>//
    </script>
    </html>
<% } //if (Reg.setResultSet(SQLCommand)) 
} else { %>
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 
%>


