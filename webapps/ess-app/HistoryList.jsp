<%--
HistoryList.jsp - List out reports from central database
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
<jsp:useBean id = "Reporter"
     class="ess.PersonnelTable"
     scope="page" />
<jsp:useBean id = "CanApprove"
     class="ess.Approver"
     scope="page" />
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
String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
String CCode = "";
String database = request.getParameter("database");

String ownersName = request.getParameter("email");

Log.println("[000] HistoryList.jsp start:" + ownersName);

boolean pFlag = PersFile.setPersInfo(ownersName); 
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
  CanApprove.setApprover(PersFile);
}

if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 

%>
<%@ include file="StatusInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<%
   Reg.setConnection(PersFile.getConnection());
   Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

   Reporter.setConnection(PersFile.getConnection());
   Reporter.setSQLTerminator(PersFile.getSQLTerminator()); 
   Reporter.setSQLStrings();  

   CanApprove.setConnection(PersFile.getConnection());
   CanApprove.setSQLTerminator(PersFile.getSQLTerminator()); 
   CanApprove.setUpFiles();

   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);

   String reportScript = SystemDOM.getDOMTableValueFor("history","screenscript","HistoryReport.jsp");
   
   String downlevel = request.getParameter("level");
   int checkLevelsDown = java.lang.Integer.parseInt(downlevel);

   String persnumber = PersFile.persnum;    //need to replace with a PersFile.get...()

   String reporttype = request.getParameter("reporttype");

   String begDateStr = request.getParameter("begdate");
   String endDateStr = request.getParameter("enddate");

   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   String begDateSQL = Dt.getSQLDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));  //need this format for 2 purposes
   String endDateSQL = Dt.getSQLDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));

   String begDateXB;
   String endDateXB;
   if (SQLType.equals("MM/DD/YYYY")) { 
     begDateXB = begDateStr;
     endDateXB = endDateStr;
   } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
     begDateXB = Dt.getOracleDate(Dt.getDateFromStr(begDateStr,PersFile.getDateFormat()));
     endDateXB = Dt.getOracleDate(Dt.getDateFromStr(endDateStr,PersFile.getDateFormat()));
   } else {    // s/b YYYY-MM-DD
     begDateXB = begDateSQL;
     endDateXB = endDateSQL;
   }

   String approvalType = SystemDOM.getDOMTableValueFor("history","approval");

   String SQLCommand = SystemDOM.getDOMTableValueFor("history",reporttype);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",persnumber);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$begdate$",begDateXB);
   SQLCommand = Reg.SQLReplace(SQLCommand,"$enddate$",endDateXB);
   Log.println("[000] HistoryList.jsp SQL:" + SQLCommand);
   Log.println("[000] HistoryList.jsp begDate:" + begDateXB + " SQL: " + begDateSQL);
   Log.println("[000] HistoryList.jsp endDate:" + endDateXB + " SQL: " + endDateSQL);

   if (Reg.setResultSet(SQLCommand)) { 
%>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <title>Report Selection:</title>
     <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     </head>
     <body>
     <h1>Report History</h1><h2>
     <%= begDateStr %> to <%= endDateStr %></h2><br>
     

<%   String persname;
     byte[] bArray;    //used for encrypted values
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
     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
     String newbackcolor;
     int adjustment = 0; //see status.xml
%>
     <script>
     //<%= SQLCommand %>//
     </script>

     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
     <tr>
 
     <td width="10%" <%=backcolor%> align='center'><u>Central #</u></td>
     <td width="10%" <%=backcolor%> align='center'><u>Your #</u></td>
     <td width="10%" <%=backcolor%> align='center'><u>Date</u></td>
     <td width="20%" <%=backcolor%> align='center'><u>Name</u></td>
     <td width="10%" <%=backcolor%> align='center'><u>Report Amount</u></td>
     <td width="30%" <%=backcolor%> align='left'><u>Payment Status</u></td>
     <td width="10%" <%=backcolor%>></td>
     </tr>
<%
    newbackcolor = backcolor;
    backcolor = oldbackcolor; 
    oldbackcolor = newbackcolor;
 
    try {
     do { 
//SQL order RP_STAT, PERS_NUM, VOUCHER, PVOUCHER, SUB_DATE, NAME,RE_AMT
        repStat = PersFile.getTrim(Reg.myResult.getString(1)); 
        reference = PersFile.getTrim(Reg.myResult.getString(2)); //used for subordinate lookup
        voucher = PersFile.getTrim(Reg.myResult.getString(3));
        pvoucher = PersFile.getTrim(Reg.myResult.getString(4));
        repdate = PersFile.getTrim(Reg.myResult.getString(5));  
        if (encrypt.equalsIgnoreCase("YES")) {
          bArray = Reg.myResult.getBytes(6);
          E = new String(bArray);
          persname = unScramble(E,encrypt,encryptKey);   
        } else {
          persname = PersFile.getTrim(Reg.myResult.getString(6));
        }
        repamt = PersFile.getTrim(Reg.myResult.getString(7)); 

        //Log.println("[000] HistoryList.jsp voucher: " + voucher + ", " + repdate);

        repDBStat = StatXlation(repStat, CompanyName, StatusDOM);

        // This is necessary due to Oracle
        if (repdate != null && !repdate.equals("")) {
           if (SQLType.equals("MM/DD/YYYY")) { 
           } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
             repdate = Dt.getSQLDate(Dt.getOracleSQLDate(repdate));
           } else {    // s/b YYYY-MM-DD
           }
        } else {
           Log.println("[400] HistoryList.jsp repdate is null or blank - " + voucher);
        }
        if (repdate != null && repdate.compareTo(begDateSQL) > -1  && repdate.compareTo(endDateSQL) < 1) { 
          xFlag = true;   
          if (reporttype.equals("subordinates")) {
            if (xFlag = Reporter.setPersNumInfo(reference)) {; 
               xFlag = CanApprove.canApprove(Reporter, approvalType, checkLevelsDown + adjustment);
            }
          } 
          if (xFlag) { 
     %>          
            <tr>
            <td width="10%" <%=backcolor%> align="center"><%= voucher%></td>
            <td width="10%" <%=backcolor%> align="center"><%= pvoucher.substring(1)%></td>
            <td width="10%" <%=backcolor%> align="center"><%= Dt.getSimpleDate(Dt.getDateFromXBase(repdate))%></td>
            <td width="20%" <%=backcolor%> align="center"><%= persname%></td>
            <td width="10%" <%=backcolor%> align="center"><%= money.format(money.parse(repamt))%></td>
            <td width="30%" <%=backcolor%> align="left"><%= repDBStat%></td>
            <td width="10%" <%=backcolor%>><a href="javascript: void parent.contents.writeDelayMsg('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/<%= reportScript %>?email=<%= PersFile.repStr(ownersName,"'","\\'") %>&rcpt2=<%= Reporter.getPrintableEmailAddress()%>&reference=<%= reference%>&voucher=<%= voucher%>&ccode=<%= CCode%>&status=<%= repStat%>&database=<%= database%>')"><span class="ExpenseReturnLink">View</span></a></td>
            </tr>
     <%     xfound = true;
            newbackcolor = backcolor;
            backcolor = oldbackcolor; 
            oldbackcolor = newbackcolor;
          }
        }
     } while (Reg.myResult.next());
  } catch (java.lang.Exception ex) {
    Log.println("[500] HistoryList.jsp java.lang exception possibly voucher: " + voucher);
%>
    <h2>Error in the SQL logic - contact support.<h2>
<%  
  } //try
  Reg.close();
%>
  </table>
<p align="right"><a class="ExpenseReturnLink" href="javascript: void parent.contents.TransWindow(parent.contents.defaultHome + 'historyList.html')" tabindex="2">Return to History Selection</a></p>

<% if (!xfound) { %>
<h2>
No reports found in database matching your description.<br>
</h2>
<% } %>
          

</body>
</html>

<% } else { %>
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>Introduction Page</title>
    <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
    </head>
    <body>
    <p><div class="ExpenseTag">
    <%=PersFile.name%>, No expense reports have been found.
    <% Log.println("[400] HistoryList.jsp No expense reports where found."); %>
    </div></p>
    </body>
    </html>
<% } //if (Reg.setResultSet(SQLCommand)) 

} else { %>
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
Reg.close();      //cleaning up open connections 
Reporter.close();
%>
<%@ include file="UnScramble.jsp" %>
<%@ include file="StatXlation.jsp" %>


