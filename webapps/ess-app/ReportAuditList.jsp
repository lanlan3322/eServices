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
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" /> 

<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="NumericSetup.jsp" %>
<% 
Log.println("[000] ReportAuditList.jsp started");
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
   String controlCompany = PersFile.getCompany();
   String cvoucher = request.getParameter("voucher");
   String pvoucher = request.getParameter("pvoucher");
   String refer = request.getParameter("reference");
   String xref = request.getParameter("xref");
   String status = request.getParameter("status");
   String level = PersFile.level;

   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   String SQLDateReplace = SystemDOM.getDOMTableValueFor("sql","datesql");
   
   
 //Need to review how this date stuff is used.

   String begDateSQL = "";
   String endDateSQL = "";

   if (begDateStr != null && !begDateStr.equals("")) begDateSQL = Dt.getSQLDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
   if (endDateStr != null && !endDateStr.equals("")) endDateSQL = Dt.getSQLDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));

   String begDateXB = "";
   String endDateXB = "";

   if (SQLType.equals("MM/DD/YYYY")) { 
     begDateXB = begDateStr;
     endDateXB = endDateStr;
   } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")) {    // oracle
     if (begDateStr != null && !begDateStr.equals("")) begDateXB = Dt.getOracleDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
     if (endDateStr != null && !endDateStr.equals("")) endDateXB = Dt.getOracleDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));
   } else {    // s/b YYYY-MM-DD
     begDateXB = begDateSQL;
     endDateXB = endDateSQL;
   }

   String SQLCommand;
   if (reportclass.equals("form")) {
     SQLCommand = reporttype + DBSQLTerminator;
   } else {
//Want to change this to determine which string from security.xml and PersTable	   
     SQLCommand = SystemDOM.getDOMTableValueFor(reportclass,reporttype);
   }
   SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",persnumber);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$begdate$",SQLDateReplace);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$date$",begDateXB);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$enddate$",SQLDateReplace);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$date$",endDateXB);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$company$",company);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$controlcompany$",controlCompany);
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
     <link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     <script type="text/javascript">
     if (screen.width < 1024) {
       var link = document.getElementsByTagName( "link" )[ 0 ];
       link.href = "<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense800.css";
     }
     </script>
     <link rel="stylesheet" media="print" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/print.css" type="text/css">
     <title>Report Selection:</title>
     </head>
     <body onLoad="initForm()">
     <strong><big><em><%= Lang.getString("centralData")%><br>
<%
if (!begDateStr.equals(""))
{
%>
     <%= begDateStr %> <%= Lang.getString("to")%> <%= endDateStr %>
<%
}   
%>
</em></big></strong><br><br>
<%  
   byte[] bArray;    //used for encrypted values
     String E;         //     ditto
     String persname; 
     boolean xFlag;
     boolean xfound = false;
     String voucher = "";
     String preference = "";
     String reference;
     String repdate;
     String repamt;
     String dueamt;
     String repStat;
     String repDBStat;
     String backcolor = "class=\"TableData offsetColor\"";
     String oldbackcolor = "class=\"TableData\"";
     String newbackcolor;
	 String depart;
     int adjustment = 0; //see status.xml
     int reportCount = 0;

%>
 
     <script>
     //<%= SQLCommand %>//
     </script>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
     <tr>
     <td width="5%" <%=backcolor%> align='center'></td>
     <td width="10%" <%=backcolor%> align='center'><u><%= Lang.getString("centralNum")%></u></td>
     <td width="10%" <%=backcolor%> align='center'><u><%= Lang.getString("usersNum")%></u></td>
     <td width="10%" <%=backcolor%> align='center'><u><%= Lang.getString("curDat")%></u></td>
     <td width="21%" <%=backcolor%> align='center'><u><%= Lang.getString("name")%></u></td>
     <td width="08%" <%=backcolor%> align='center'><u><%= Lang.getString("total")%></u></td>
     <td width="08%" <%=backcolor%> align='center'><u><%= Lang.getString("due")%></u></td>
     <td width="20%" <%=backcolor%> align='left'><u><%= Lang.getString("paymentStat")%></u></td>
     <td width="8%" <%=backcolor%>></td>
     </tr>
     <form>
<%  newbackcolor = backcolor;
    backcolor = oldbackcolor; 
    oldbackcolor = newbackcolor;
    try {
     
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
        preference = PersFile.getTrim(Reg.myResult.getString("PVOUCHER"));
        repStat = PersFile.getTrim(Reg.myResult.getString("RP_STAT")); 
        reference = PersFile.getTrim(Reg.myResult.getString("PERS_NUM")); //used for subordinate lookup
        repdate = PersFile.getTrim(Reg.myResult.getString("CUR_DATE")); //original submission date 
		depart = PersFile.getTrim(Reg.myResult.getString("DEPART"));
        if (repdate == null) repdate = "";
        if (!repdate.equals("")) repdate = Dt.getStrFromDate(Dt.getDateFromXBase(repdate), PersFile.getDateFormat());      //Dt.getSimpleDate(Dt.getDateFromXBase(repdate));
        repamt = PersFile.getTrim(Reg.myResult.getString("RC_AMT")); 
        dueamt = PersFile.getTrim(Reg.myResult.getString("RE_AMT")); 

        repDBStat = StatXlation(repStat, CompanyName, StatusDOM);
     
        //if (repdate != null && repdate.compareTo(begDateSQL) > -1  && repdate.compareTo(endDateSQL) < 1) 
        if (repdate != null) {
          xFlag = true;   
          if (xFlag) { 
            reportCount = reportCount + 1;
     %>          
            <tr>
<%          if (PersFile.isAuditor() && !PersFile.getPersNum().equals(reference)) {  
%>          <td width="5%"  <%=backcolor%>><input type="checkbox" name="select_this_report" value="<%= repStat%>;<%= voucher.trim() %>"></td> 
<%          } else { 
%>          <td width="5%"  <%=backcolor%>></td> 
<%          }
%>          <td width="10%" <%=backcolor%> align="center"><%= voucher %></td>
            <td width="10%" <%=backcolor%> align="center"><%= preference %></td>
            <td width="10%" <%=backcolor%> align="center"><%= repdate %></td>
            <td width="21%" <%=backcolor%> align="center"><a href="javascript: void parent.contents.writeDelayMsg('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/HistoryReportPrint.jsp?email=<%= ownersName%>&voucher=<%= voucher%>&depart=<%= depart%>&ccode=<%= CCode%>&persnumber=<%= reference%>&database=<%= database%>&begdate=<%= begDateStr%>&enddate=<%= endDateStr%>')"><%= persname %></a></td>
            <td width="08%" <%=backcolor%> align="center"><%= money.format(money.parse(repamt))%></td>
            <td width="08%" <%=backcolor%> align="center"><%= money.format(money.parse(dueamt))%></td>
            <td width="20%" <%=backcolor%> align="left"><%= Lang.getDataString(repDBStat)%></td>
            <td width="8%" <%=backcolor%>><a href="javascript: void parent.contents.writeDelayMsg('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/HistoryReport.jsp?email=<%= ownersName%>&voucher=<%= voucher%>&depart=<%= depart%>&ccode=<%= CCode%>&status=<%= repStat%>&database=<%= database%>')"><%= Lang.getString("select")%></a></td>
<!--<%          if (StatusDOM.getDOMTableValueWhere("default","translation",repStat,"usereditallowed").equalsIgnoreCase("yes") && (PersFile.isAuditor() || PersFile.isProcessor()) && !PersFile.getPersNum().equals(reference)) {  
%>            <td width="8%" <%=backcolor%>><a href="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/AuditReport.jsp?email=<%= ownersName%>&voucher=<%= voucher%>&ccode=<%= CCode%>&status=<%= repStat%>&database=<%= database%>"><%= Lang.getString("select")%></a></td>
<%          } else { 
%>            <td width="8%" <%=backcolor%>><a href="javascript: void parent.contents.writeDelayMsg('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/HistoryReport.jsp?email=<%= ownersName%>&voucher=<%= voucher%>&ccode=<%= CCode%>&status=<%= repStat%>&database=<%= database%>')"><%= Lang.getString("select")%></a></td>
<%          }
%>-->
			</tr>
<%          xfound = true;
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
        <input type="hidden" name="xaction" value="remove">

      <p><input type="button" value="<%= Lang.getString("remove")%>" name="B1"onClick="Javascript: void Remove()">&nbsp; <span class="ExpenseTag"><%= Lang.getString("clickRemSelIt")%></span></p>
      </form>

      <p align="right"><a href="javascript: void parent.contents.TransWindow(parent.contents.defaultHome + 'reportAuditDisplay.html')" tabindex="2"><em><strong><%= Lang.getString("goRepSel")%></strong></em></a></p>


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
          document.forms[1].xaction.value = "remove";

          parent.contents.initStacks();
          parent.contents.setLastSQL("<%=SQLCommand %>"); 
          parent.contents.setLastDisplay("ReportAuditList.jsp");

        } else {
          setTimeout("parent.main.initForm()",1000);
        }    
      }

      function Remove(){
        var delim = "";
        for (var i = 0; i < document.forms[0].length; i++) {
          if (document.forms[0].elements[i].name == "select_this_report" && document.forms[0].elements[i].checked == true) {
            if (document.forms[0].elements[i].reference == "") document.forms[0].elements[i].reference = "X"; 
            document.forms[1].status.value += delim + breakApart(document.forms[0].elements[i].value,1);
            document.forms[1].reference.value += delim + breakApart(document.forms[0].elements[i].value,2);
            delim = ";";   
          }
        }
        if (delim == ";") {
          if (confirm("<%= Lang.getString("checkRepRemDB")%>")) {
            document.forms[1].submit();
          }
        } else {
          alert("<%= Lang.getString("checkRepRem")%>");
        }
      }

      function breakApart(x,n) {
         var retVal = "";
         var semi = x.indexOf(";")
         var firstpart = x.substring(0,semi);
         var secondpart = x.substring(semi+1);
         if (n == 1) {
            retVal = firstpart;
         } else {
            retVal = secondpart;
         }
         return retVal
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
<%= Lang.getString("noRepFou")%><br>
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
    <p><big><big><strong><%=PersFile.name%>, <%= Lang.getString("noExpFou")%>
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



