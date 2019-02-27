<%--
PaymentReport.jsp - lists out SimplePayment.dat
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
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "Journal"
     class="ess.GeneralJournal"
     scope="page" />
<jsp:useBean id = "PaymentSummary"
     class="ess.ESSSummary"
     scope="page" />

<%@ include file="../DBAccessInfo.jsp" %>
<% 
java.text.DecimalFormat money = new java.text.DecimalFormat("0.00");
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
<%
   String encrypt = SystemDOM.getDOMTableValueFor("encrypt","apply","No");
   String encryptKeyStr = SystemDOM.getDOMTableValueFor("encrypt","key","15");
   int encryptKey = Integer.parseInt(encryptKeyStr);

   String DateStr = request.getParameter("update");
   if (DateStr == null || DateStr.equals("")) DateStr = Dt.getSimpleDate(Dt.date); 

   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   String DateSQL = Dt.getSQLDate(Dt.getDateFromStr(DateStr));

   String DateXB;
   if (SQLType.equals("MM/DD/YYYY")) { 
     DateXB = DateStr;
   } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
     DateXB = Dt.getOracleDate(Dt.getDateFromStr(DateStr));
   } else {    // s/b YYYY-MM-DD
     DateXB = DateSQL;
   }
%>
     <html>
     <head>
     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
     <meta http-equiv="Pragma" content="no-cache">
     <meta http-equiv="Expires" content="-1">

     <title>Payment Report</title>
     <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     </head>
     <body>
     <%@ include file="../StandardTopNR.jsp" %>
     <h1><u>Payment Report</u></h1>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
     <form>
<%
     String[] rowSet;
     byte[] bArray;    //used for encrypted values
     long totalAmount = (long) 0.0;
     long recalcAmount = (long) 0.0;
     String RP_PERS_NUM;  
     String RP_VOUCHER;
     String RP_NAME; 
     String RP_RE_AMT; 
     String REIMBURSE_CHECK;
     String RP_UP_DATE;
     String USER_CASH;
     String USER_BANKCODE; 
     String USER_BANKACCT;
     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
     String newbackcolor;

     int reportCount = 0;

     //various sets can go here... 
     PaymentSummary.setGeneralTitle("Payments/Feeds");
     PaymentSummary.setAccountTitle("Handoff");
     Journal.setJournalName("SimplePayment.dat");
     Journal.setImportType("Payment");
     String[] columnsWanted = {"RP_PERS_NUM","RP_VOUCHER","RP_NAME","RP_RE_AMT","REIMBURSE_CHECK","RP_UP_DATE","USER_CASH","USER_BANKCODE","USER_BANKACCT"};
     
     Journal.setColumnsWanted(columnsWanted);
     Journal.init(SystemDOM, PersFile.getConnection());

     boolean xFound = Journal.setParser(); 

   if (xFound) {
%>
        <tr>
        <td width="15%" <%=backcolor%> align="center"><u>Voucher</u></td>
        <td width="15%" <%=backcolor%> align="center"><u>Name</u></td>
        <td width="15%" <%=backcolor%> align="center"><u>Personnel #</u></td>
        <td width="15%" <%=backcolor%> align="center"><u>Release Date</u></td>
        <td width="15%" <%=backcolor%> align="center"><u>Method</u></td>
        <td width="15%" <%=backcolor%> align="center"><u>Bank</u></td>
        <td width="15%" <%=backcolor%> align="right"><u>Recalc</u></td>
        <td width="15%" <%=backcolor%> align="right"><u>Payment</u></td>
        </tr>
<%      newbackcolor = backcolor;
        backcolor = oldbackcolor; 
        oldbackcolor = newbackcolor;
   try {
     do { 
        rowSet = Journal.getRow();        
        
        RP_PERS_NUM = rowSet[0];  
        RP_VOUCHER = rowSet[1];
        RP_NAME = rowSet[2]; 
        RP_RE_AMT = rowSet[3]; 
        REIMBURSE_CHECK = rowSet[4];
        RP_UP_DATE = rowSet[5];
        USER_CASH = rowSet[6];
        USER_BANKCODE = rowSet[7]; 
        USER_BANKACCT = rowSet[8];

        RP_VOUCHER = RP_VOUCHER.substring(1,RP_VOUCHER.length()-1);
        RP_NAME = RP_NAME.substring(1,RP_NAME.length()-1);
        RP_PERS_NUM = RP_PERS_NUM.substring(1,RP_PERS_NUM.length()-1);
        RP_UP_DATE = RP_UP_DATE.substring(1,RP_UP_DATE.length()-1);
        if (USER_CASH.equals("null")) {
           USER_CASH = "";
        } else {
           USER_CASH = USER_CASH.substring(1,USER_CASH.length()-1);
        }
        if (USER_BANKCODE.equals("null")) {
           USER_BANKCODE = "";
        } else { 
           USER_BANKCODE = USER_BANKCODE.substring(1,USER_BANKCODE.length()-1);
        } 
        if (USER_BANKACCT.equals("null")) {
           USER_BANKACCT = "";
        } else { 
           USER_BANKACCT = USER_BANKACCT.substring(1,USER_BANKACCT.length()-1);
        } 
        reportCount = reportCount + 1;
%>          
        <tr>
        <td width="15%" <%=backcolor%> align="center"><%= RP_VOUCHER %></td>
        <td width="15%" <%=backcolor%> align="center"><%= RP_NAME %></td>
        <td width="15%" <%=backcolor%> align="center"><%= RP_PERS_NUM %></td>
        <td width="15%" <%=backcolor%> align="center"><%= RP_UP_DATE %></td>
        <td width="15%" <%=backcolor%> align="center"><%= USER_CASH %></td>
        <td width="15%" <%=backcolor%> align="center"><%= USER_BANKCODE %></td>
        <td width="15%" <%=backcolor%> align="right"><%= REIMBURSE_CHECK %></td>
        <td width="15%" <%=backcolor%> align="right"><%= RP_RE_AMT%></td>
        </tr>
<%      
        totalAmount = Journal.addString2LongforCurrency(totalAmount, RP_RE_AMT);
        recalcAmount = Journal.addString2LongforCurrency(recalcAmount, REIMBURSE_CHECK); 
        PaymentSummary.add(USER_CASH,REIMBURSE_CHECK,"");

        newbackcolor = backcolor;
        backcolor = oldbackcolor; 
        oldbackcolor = newbackcolor;
     } while (Journal.next());
%>
        <tr>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center">Totals:</td>
        <td width="15%" <%=backcolor%> align="right"><u><%= Journal.makeLong2Currency(recalcAmount) %></u></td>
        <td width="15%" <%=backcolor%> align="right"><u><%= Journal.makeLong2Currency(totalAmount) %></u></td>
        </tr>
<%
        newbackcolor = backcolor;
        backcolor = oldbackcolor; 
        oldbackcolor = newbackcolor;
%>
        <tr>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center">Reports:</td>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="right"><%= Integer.toString(reportCount) %></td>
        </tr>

<%
  } catch (java.lang.Exception ex) {
    Log.println("[500] PaymentReport.jsp Language Error");
    Log.println("[500] PaymentReport.jsp - " + ex.toString());
    ex.printStackTrace();
%>
    <h1>Error in report logic - contact support.<br></h1>
<%  
  } //try
  PaymentSummary.sort();
  } else {      // if(xFound)
%>

     <h1><br>No entries found in the payment summary file.</h1>
<%
  }

%>
  </form>
  </table>
  <br>
  <%= PaymentSummary.printGeneralSummary() %>
  <br>
  <%@ include file="../StandardBottomNR.jsp" %>
  </body>
     <head>
     <meta http-equiv="Pragma" content="no-cache">
     <meta http-equiv="Expires" content="-1">
     </head>
  </html>
<%
} else { %>
  <%@ include file="../ReloginRedirectMsg.jsp" %>
<%
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
%>
<%
     //cleaning up open connections 
Log.println("[000] PaymentReport.jsp - finished for " + ownersName);
%>
<%@ include file="../UnScramble.jsp" %>



