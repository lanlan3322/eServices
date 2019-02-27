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
<%@ include file="NumericSetup.jsp" %>
<% 
Log.println("[000] ReportList.jsp started");
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
Reg.setConnection(PersFile.getConnection()); 
%>
<%@ include file="StatusInfo.jsp" %>
<%
Log.println("[000] ReportList.jsp 2");
%>
<%@ include file="SystemInfo.jsp" %>
<%
   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);

// these are used in conjunction with the SQL found in system.xml
   String persnumber = PersFile.persnum;    //need to replace with a PersFile.get...()
   String reportclass = request.getParameter("reportclass"); //corres. to system element/section
   String reporttype = request.getParameter("reporttype"); //corres. to system sub-element of above
   String begDateStr = request.getParameter("begdate");
   String endDateStr = request.getParameter("enddate");
   String company = request.getParameter("company");
   String cvoucher = request.getParameter("voucher");
   String pvoucher = request.getParameter("pvoucher");
   String refer = request.getParameter("reference");
   String xref = request.getParameter("xref");
   String status = request.getParameter("status");
   String level = PersFile.level;

   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   String SQLDateReplace = SystemDOM.getDOMTableValueFor("sql","datesql");
   
   String begDateSQL = "";
   String endDateSQL = "";

   if (begDateStr != null && !begDateStr.equals("")) begDateSQL = Dt.getSQLDate(Dt.getDateFromStr(begDateStr));
   if (endDateStr != null && !endDateStr.equals("")) endDateSQL = Dt.getSQLDate(Dt.getDateFromStr(endDateStr));

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
     SQLCommand = reporttype + DBSQLTerminator;
   } else {
     SQLCommand = SystemDOM.getDOMTableValueFor(reportclass,reporttype);
   }
   SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",persnumber);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$begdate$",SQLDateReplace);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$date$",begDateXB);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$enddate$",SQLDateReplace);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$date$",endDateXB);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$company$",company);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$voucher$",cvoucher);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$pvoucher$",pvoucher);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$reference$",refer);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$xref$",xref);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$status$", status);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$level$", level);

   Log.println("[000] ReportList.jsp SQL:" + SQLCommand);
   Log.println("[000] ReportList.jsp begDate:" + begDateXB + " SQL: " + begDateSQL);
   Log.println("[000] ReportList.jsp endDate:" + endDateXB + " SQL: " + endDateSQL);

   if (Reg.setResultSet(SQLCommand)) { %>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <link rel="stylesheet" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder()%>/expense.css" type="text/css">
     <title>Report Selection:</title>
     </head>
     <body onLoad="initForm()">
     <strong><big><em>Central Database<br>
     <%= begDateStr %> to <%= endDateStr %></em></big></strong><br><br>
     
<%   
     byte[] bArray;    //used for encrypted values
     String E;         //     ditto
     String persname; 
     boolean xFlag;
     boolean xfound = false;
     String voucher = "";
     String reference;
     String repdate;
     String repamt;
     String repStat;
     String repDBStat;
     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
     String newbackcolor;
     int adjustment = 0; //see status.xml
     int reportCount = 0;

%>
 
     <script>
     //<%= SQLCommand %>//
     </script>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
     <form>
<% try {
     
     do { 
        if (encrypt.equalsIgnoreCase("YES")) {
          bArray = Reg.myResult.getBytes("NAME");
          E = new String(bArray);
          persname = unScramble(E,encrypt,encryptKey);   
        } else {
          persname = PersFile.getTrim(Reg.myResult.getString("NAME"));
        }
        //persname = unScramble(Reg.myResult.getString("NAME"),encrypt,encryptKey);   

        voucher = PersFile.getTrim(Reg.myResult.getString("VOUCHER"));
        repStat = PersFile.getTrim(Reg.myResult.getString("RP_STAT"));  
        reference = PersFile.getTrim(Reg.myResult.getString("PERS_NUM")); //used for subordinate lookup
        repdate = PersFile.getTrim(Reg.myResult.getString("CUR_DATE")); //original submission date 
        repamt = PersFile.getTrim(Reg.myResult.getString("RC_AMT")); 

        repDBStat = StatXlation(repStat, CompanyName, StatusDOM);
     
        //if (repdate != null && repdate.compareTo(begDateSQL) > -1  && repdate.compareTo(endDateSQL) < 1) 
        if (repdate != null) {
          xFlag = true;   
          if (xFlag) { 
            reportCount = reportCount + 1;
     %>          
            <tr>
            <td width="5%"  <%=backcolor%>><input type="checkbox" name="select_this_report" reference="<%= voucher.trim() %>" value="<%= repStat%>"></td> 
            <td width="15%" <%=backcolor%> align="center"><%= voucher%></td>
            <td width="15%" <%=backcolor%>><%= Dt.getSimpleDate(Dt.getDateFromXBase(repdate))%></td>
            <td width="20%" <%=backcolor%> align="center"><%= persname %></td>
            <td width="10%" <%=backcolor%> align="center"><%= money.format(money.parse(repamt))%></td>
            <td width="25%" <%=backcolor%>><%= repDBStat%></td>
            <td width="10%" <%=backcolor%>><a href="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/getDBReport.jsp?email=<%= ownersName%>&voucher=<%= voucher%>&ccode=<%= CCode%>&status=<%= status%>&database=<%= database%>">Select</a></td>
            </tr>
     <%     xfound = true;
            newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;
          }
        }
     } while (Reg.myResult.next());
     %>
      </form>
        <tr>
        <td width="5%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="20%" <%=backcolor%> align="center"></td>
        <td width="10%" <%=backcolor%> align="center"></td>
        <td width="25%" <%=backcolor%> align="center">Reports:</td>
        <td width="10%" <%=backcolor%> align="right"><%= Integer.toString(reportCount) %></td>
        </tr>

      </table>
      <!-- <form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/parameterList.jsp"> -->
      <form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/RemoveFromDbaseCheck.jsp">
        <input type="hidden" name="email" value>
        <input type="hidden" name="database" value>
        <input type="hidden" name="company" value>
        <input type="hidden" name="ccode" value>
        <input type="hidden" name="reference" value>
        <input type="hidden" name="status" value>
        <input type="hidden" name="action" value="remove">

      <p><input type="button" value="Remove" name="B1"onClick="Javascript: void Remove()">&nbsp; <span class="ExpenseTag">Click &quot;Remove&quot; to begin removal of selected items from the central database permanently</span></p>
      </form>

      <p align="right"><a href="javascript: void parent.contents.TransWindow(parent.contents.defaultHome + 'reportGeneral.html')" tabindex="2"><em><strong>Go to Report Selection</strong></em></a></p>


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
          document.forms[1].status.value = "";
          document.forms[1].action.value = "remove";
        } else {
          setTimeout("parent.main.initForm()",1000);
        }    
      }

      function Remove(){
        var delim = "";
        for (var i = 0; i < document.forms[0].length; i++) {
          if (document.forms[0].elements[i].name == "select_this_report" && document.forms[0].elements[i].checked == true) {
            if (document.forms[0].elements[i].reference == "") document.forms[0].elements[i].reference = "X"; 
            document.forms[1].reference.value += delim + document.forms[0].elements[i].reference;
            document.forms[1].status.value += delim + document.forms[0].elements[i].value;
            delim = ";";   
          }
        }
        if (delim == ";") {
          if (confirm("Checked reports will be selected for removal from the central database.  Is it 'OK' to proceed?")) {
            document.forms[1].submit();
          }
        } else {
          alert("Must check report(s) that you wish to remove");
        }
      }

      </script>
<%

  } catch (java.lang.Exception ex) {
    Log.println("[500] ReportList.jsp java.lang exception possibly voucher : " + voucher);
%>
    </table>
    </form>
    <strong><em><br>Error in the SQL logic - contact support.<br></em></strong>
<%  
  } //try
  Reg.close();
%>

<% if (!xfound) { %>
<strong><em>
No reports found in database matching your description.<br>
</em></strong>
<% } %>
          

</body>
</html>

<% } else { %>
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>Introduction Page</title>
    </head>
    <body>
    <p><big><big><strong><%=PersFile.name%>, No expense reports have been found.
    <% Log.println("[400] ReportList.jsp No expense reports where found."); %>
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
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>



