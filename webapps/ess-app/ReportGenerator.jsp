<%--
ReportGenerator.jsp - prints out a list based on a collection of SQL statement found in Report.xml 
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

<%@ page isThreadSafe="false" %>
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
<jsp:useBean id = "Summary"
     class="ess.ESSSummary"
     scope="page" />
<jsp:useBean id = "MyWorld"
     class="ess.MyWorld"
     scope="session" />
<jsp:useBean id = "Lang"
     class="ess.Language"
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

// these are used in conjunction with the SQL found in system.xml
   String reportclass = request.getParameter("reportclass"); //corres. to system element/section
   String reporttype = request.getParameter("reporttype"); //corres. to system sub-element of above

   String mwc = ReportDOM.getDOMTableValueFor(reporttype,"myworldcheck");
   boolean myWorldCheck = mwc.equalsIgnoreCase("YES");
   if (myWorldCheck && !MyWorld.isSetup()) {
     MyWorld.setConnection(PersFile.getConnection());
     MyWorld.setSQLTerminator(PersFile.getSQLTerminator());
     MyWorld.setUpFiles();
     MyWorld.setMe(PersFile.getPersNum());
   }
   String encrypt = "No";
   int encryptKey = 253;
   String encryptBase = "Hex";
   String encryptHead = "0x";
   String encryptTail = "";
   String encryptDelimiter = "";
   encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   if (encrypt.equalsIgnoreCase("YES")) {
      String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
      encryptKey = Integer.parseInt(encryptKeyStr);
      encryptBase = SystemDOM.getDOMTableValueFor("encrypt","base","Hex");
      encryptHead = SystemDOM.getDOMTableValueFor("encrypt","head","0x");
      encryptTail = SystemDOM.getDOMTableValueFor("encrypt","tail","");
      encryptDelimiter = SystemDOM.getDOMTableValueFor("encrypt","delimit","");
   }

   java.util.Date currentDate = Dt.getDate();
   String currentDateString = Dt.getSimpleDate(currentDate);
   String currentTimeString = Dt.getSimpleTime(currentDate);

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

   String SQLType =  ReportDOM.getDOMTableValueFor(reporttype,"datetypeoverride","");
   String SQLDateReplace;
   if (SQLType.equals("")) {
     SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
     SQLDateReplace = SystemDOM.getDOMTableValueFor("sql","datesql");
   } else {
     SQLDateReplace = "";
   }
   String begDateSQL = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat())));
   String endDateSQL = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat())));

   String begDateXB;
   String endDateXB;
   if (SQLType.equals("MM/DD/YYYY")) { 
     begDateXB = Dt.getSimpleDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
     endDateXB = Dt.getSimpleDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));
   } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // Oracle
     begDateXB = Dt.getOracleDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
     endDateXB = Dt.getOracleDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));
   } else if (SQLType.equalsIgnoreCase("WEB")){    // Web GMT format primarily for REGISTER table
     begDateXB = Dt.getGMTDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
     endDateXB = Dt.getGMTDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));
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

   SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",PersFile.getPersNum());
   SQLCommand = Reg.SQLReplace(SQLCommand,"$email$",PersFile.getEmailAddress());
   SQLCommand = Reg.SQLReplace(SQLCommand,"$company$",PersFile.getCompany());
   
   SQLCommand = Reg.SQLReplace(SQLCommand,"$field1$",field1);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$field2$",field2);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$field3$",field3);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$field4$",field4);

   Log.println("[000] ReportGenerator.jsp SQL:" + SQLCommand);
   Log.println("[000] ReportGenerator.jsp begDate:" + begDateXB + " SQL: " + begDateSQL);
   Log.println("[000] ReportGenerator.jsp endDate:" + endDateXB + " SQL: " + endDateSQL);

   String summaryReport =  ReportDOM.getDOMTableValueFor(reporttype,"summaryreport");
   boolean summarize = false;
   if (summaryReport.equalsIgnoreCase("YES")) summarize = true;
   if (summarize) {
      Summary.setPrimaryTitle(ReportDOM.getDOMTableValueFor(reporttype,"primarytitle"));      
      Summary.setAmountTitle(ReportDOM.getDOMTableValueFor(reporttype,"amounttitle"));      
      Summary.setSecondary1Title(ReportDOM.getDOMTableValueFor(reporttype,"secondary1title"));      
      Summary.setSecondary2Title(ReportDOM.getDOMTableValueFor(reporttype,"secondary2title"));      
   }
   String SQLCheck1Plus;
   String SQLCheck2Plus;
   String SQLCheck3Plus;

   String SQLCheck1Minus;
   String SQLCheck2Minus;
   String SQLCheck3Minus;

   if (!performChecks.equalsIgnoreCase("NO"))
   {
      SQLCheck1Plus =  ReportDOM.getDOMTableValueFor(reporttype,"sqlcheck1plus");
      SQLCheck2Plus =  ReportDOM.getDOMTableValueFor(reporttype,"sqlcheck2plus");
      SQLCheck3Plus =  ReportDOM.getDOMTableValueFor(reporttype,"sqlcheck3plus");
      SQLCheck1Minus =  ReportDOM.getDOMTableValueFor(reporttype,"sqlcheck1minus");
      SQLCheck2Minus =  ReportDOM.getDOMTableValueFor(reporttype,"sqlcheck2minus");
      SQLCheck3Minus =  ReportDOM.getDOMTableValueFor(reporttype,"sqlcheck3minus");
   } else
   {
      SQLCheck1Plus =  "";
      SQLCheck2Plus =  "";
      SQLCheck3Plus =  "";
      SQLCheck1Minus =  "";
      SQLCheck2Minus =  "";
      SQLCheck3Minus =  "";
   }

   String SQL1Plus = "";
   String SQL2Plus = "";
   String SQL3Plus = "";
   String SQL1Minus = "";
   String SQL2Minus = "";
   String SQL3Minus = "";
   String Column1 = "";
   String Column2 = "";
   String Column3 = "";
   
   String EncryptedItems =  ";" + ReportDOM.getDOMTableValueFor(reporttype,"encrypteditems","") + ";";
   String IgnoreDates =  ReportDOM.getDOMTableValueFor(reporttype,"ignoredaterange","NO");
   if (myWorldCheck) IgnoreDates = "YES";  //Overrides usage of the first column.

   if (Reg.setResultSet(SQLCommand)) { %>
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
<%@ include file="StandardTop1RI.jsp" %>
<%
     String xTitle = ReportDOM.getDOMTableValueFor(reporttype,"title");
     if (xTitle == null) xTitle = "Ad hoc query";

%>     
     <br><br><strong><em>
     <big>Report: <%= xTitle %><br>
     <%= begDateStr %> to <%= endDateStr %></big><br>
     Run date: <%=currentDateString %> at <%=currentTimeString %> 
     </em></strong><br><br>
     
<%   String persname; 
     boolean xFlag;
     boolean xfound = false;
     String repdate = null;
     String display = "";
     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
     String newbackcolor;
     int adjustment = 0; //see status.xml
     String throwAway = "";
     int sumField = 0;
     String[] v = new String[4];
     String reporter = null;
     

     java.sql.ResultSetMetaData MetaData = Reg.myResult.getMetaData();
     int numberOfColumns = MetaData.getColumnCount();
%>
     <script>
     //<%= SQLCommand %>//
     </script>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
     <tr>
<%
     Log.println("[000] ReportGenerator.jsp Ignore Dates: " + IgnoreDates);
     int startAt = 1;
     if (myWorldCheck || IgnoreDates.equalsIgnoreCase("No")) startAt = 2; 
     Log.println("[000] ReportGenerator.jsp number of columns: " + Integer.toString(numberOfColumns));
     Log.println("[000] ReportGenerator.jsp Start with column: " + Integer.toString(startAt));
     if (!summarize) {
       for (int k = startAt; k <= numberOfColumns; k++) { 
%>
                 <td><u><%= MetaData.getColumnName(k).toUpperCase()%></u></td>
<%     }
     }
%>
     </tr>
<%
   try {
     do { 
        xFlag = true;
        if (myWorldCheck) {
            reporter = PersFile.getTrim(Reg.myResult.getString(1));
            xFlag = MyWorld.isInMyWorld(reporter);
        } else {
          if (IgnoreDates.equalsIgnoreCase("No")) repdate = PersFile.getTrim(Reg.myResult.getString(1)); 
          if (IgnoreDates.equalsIgnoreCase("No") && repdate == null) repdate = "00/00/0000";
          if (IgnoreDates.equalsIgnoreCase("No")) {
            if (SQLType.equals("MM/DD/YYYY")) { 
              repdate = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromXBase(repdate)));
            } else if (SQLType.equalsIgnoreCase("WEB")){    // Web GMT format primarily for REGISTER table
              repdate = Dt.getSQLDate(Dt.getDateFromGMTDate(repdate));
            } // Don't need to worry about the SQL standard YYYY-MM-DD
          }
        }
        // if ( IgnoreDates.equalsIgnoreCase("YES"))
        if ( xFlag && (IgnoreDates.equalsIgnoreCase("YES") || repdate.compareTo(begDateSQL) > -1  && repdate.compareTo(endDateSQL) < 1 )) 
        { 
          if (myWorldCheck) {
             if (reporter == null) reporter = "";
             Column1 = reporter;
          } else {
             if (repdate == null) {
                Column1 = PersFile.getTrim(Reg.myResult.getString(1));
             } else {
                Column1 = repdate;  //Looks like first column is always a date
             }
          }
          Column2 = PersFile.getTrim(Reg.myResult.getString(2));
          if (numberOfColumns > 2) Column3 = PersFile.getTrim(Reg.myResult.getString(3)); 

          SQL1Plus = Reg.SQLReplace(SQLCheck1Plus,"$column1$",Column1);
          SQL1Plus = Reg.SQLReplace(SQL1Plus,"$column2$",Column2);
          if (numberOfColumns > 2) SQL1Plus = Reg.SQLReplace(SQL1Plus,"$column3$",Column3);
          SQL2Plus = Reg.SQLReplace(SQLCheck2Plus,"$column1$",Column1);
          SQL2Plus = Reg.SQLReplace(SQL2Plus,"$column2$",Column2);
          if (numberOfColumns > 2) SQL2Plus = Reg.SQLReplace(SQL2Plus,"$column3$",Column3);
          SQL3Plus = Reg.SQLReplace(SQLCheck3Plus,"$column1$",Column1);
          SQL3Plus = Reg.SQLReplace(SQL3Plus,"$column2$",Column2);
          if (numberOfColumns > 2) SQL3Plus = Reg.SQLReplace(SQL3Plus,"$column3$",Column3);

          SQL1Minus = Reg.SQLReplace(SQLCheck1Minus,"$column1$",Column1);
          SQL1Minus = Reg.SQLReplace(SQL1Minus,"$column2$",Column2);
          if (numberOfColumns > 2) SQL1Minus = Reg.SQLReplace(SQL1Minus,"$column3$",Column3);
          SQL2Minus = Reg.SQLReplace(SQLCheck2Minus,"$column1$",Column1);
          SQL2Minus = Reg.SQLReplace(SQL2Minus,"$column2$",Column2);
          if (numberOfColumns > 2) SQL2Minus = Reg.SQLReplace(SQL2Minus,"$column3$",Column3);
          SQL3Minus = Reg.SQLReplace(SQLCheck3Minus,"$column1$",Column1);
          SQL3Minus = Reg.SQLReplace(SQL3Minus,"$column2$",Column2);
          if (numberOfColumns > 2) SQL3Minus = Reg.SQLReplace(SQL3Minus,"$column3$",Column3);
          xFlag = false;
          if (SQL1Plus.equals("") || SQLCheck.setResultSet(SQL1Plus)) {
             xFlag = true;
          } else {
             if (!SQL2Plus.equals("") && SQLCheck.setResultSet(SQL2Plus)) {
                xFlag = true;
             } else {
                if (!SQL3Plus.equals("") && SQLCheck.setResultSet(SQL3Plus)) {
                   xFlag = true;
                }
             } 
          }

          if (!SQL1Minus.equals("") && SQLCheck.setResultSet(SQL1Minus)) {
             xFlag = false;
          } else {
             if (!SQL2Minus.equals("") && SQLCheck.setResultSet(SQL2Minus)) {
                xFlag = false;
             } else {
                if (!SQL3Minus.equals("") && SQLCheck.setResultSet(SQL3Minus)) {
                   xFlag = false;
                }
             } 
          }
          
          if (xFlag) {
            if (!summarize) { 
%><tr><%
            }
            sumField = 0;
            v[0] = "";   // Primary Sort
            v[1] = "";   // Secondary 1 Sort
            v[2] = "";   // Secondary 2 Sort
            v[3] = "";   // Amount
            if (startAt == 2 ) throwAway = Reg.myResult.getString(1);
            for (int q = startAt; q <= numberOfColumns; q++) {
                display = PersFile.getTrim(Reg.myResult.getString(q));
                if (MetaData.getColumnType(q) == java.sql.Types.DATE) {
                	try {
                     display = Dt.getSQLDate(Dt.adjustEpoch(Dt.getDateFromXBase(display)));
                	} catch (java.lang.NullPointerException e) {
                		display = "";
                	}
                }
                if (encrypt.equalsIgnoreCase("YES") && EncryptedItems.indexOf(MetaData.getColumnName(q).toUpperCase()) > -1)
                { 
                   display = ess.Utilities.unScramble(display, encryptKey).trim(); 
                }
                if (summarize) {
                   v[sumField++] = display;
                } else {
%><td <%=backcolor%>><%= display%></td><%
                }
            }
            if (!summarize) {
%></tr><%
            } else {
                Summary.add4Report(v[0], v[3], v[1], v[2]);
            }
            xfound = true;
            newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;
          }
        }
     } while (Reg.myResult.next());

     if (summarize) {
        Summary.sort();
%>      <br>
        <%= Summary.printReport() %>
        <br>
        <br><%
     } 


  } catch (java.lang.Exception ex) {
    Log.println("[500] ReportGenerator.jsp exception : " + ex.toString());
    ex.printStackTrace();
%>
    <strong><em><br>Error in the SQL logic - contact support.<br></em></strong>
    <script>
    // Error: <%= ex.toString() %>
    </script>
<%  
  } //try
%>
  </table>
<% if (!xfound) { %>
<strong><em>
No information found in database matching your description.<br>
</em></strong>
<% } %>
          
<br><br><strong><big><em>End of <%=ReportDOM.getDOMTableValueFor(reporttype,"title")%><br>
</em></big></strong><br><br>

<%@ include file="StandardBottom1RI.jsp" %>

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
    <% Log.println("[400] ReportGenerator.jsp No information extracted."); %>
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


