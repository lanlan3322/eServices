<%--
EODReport.jsp - List of G/L entries that have been made.  Basically the same a SimpleGL.dat
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
<jsp:useBean id = "ExpenseSummary"
     class="ess.ESSSummary"
     scope="page" />
<jsp:useBean id = "CreditSummary"
     class="ess.ESSSummary"
     scope="page" />
<jsp:useBean id = "Advances"
     class="ess.ESSSummary"
     scope="page" />

<%@ include file="../DBAccessInfo.jsp" %>
<%@ include file="../NumericSetup.jsp" %>
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

     <title>End of Day Journal:</title>
     <link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
     </head>
     <body>
     <%@ include file="../StandardTopNR.jsp" %>
     <h1><u>Journal Entry Report</u></h1>
     <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
     <form>
<%
     String[] rowSet;
     byte[] bArray;    //used for encrypted values
     long totalAmount = (long) 0.0;
     String RP_PERS_NUM;  
     String RP_VOUCHER;
     String RP_NAME; 
     String RP_DEPART; 
     String RC_AMOUNT;
     String RC_ACCOUNT;
     String EX_AMOUNT;
     String EX_ACCOUNT; 
     String EX_DEPART;
     String RP_UP_DATE;
     String EX_BILLTYPE;
     String EX_EXPENSE;
     String EX_COSTCENTER;
     String RC_CHARGE;
     String PR_PROJECT;
     String PR_CLIENTNO;
     String PR_STEPNO;   
     String RP_COMPANY;

     int reportCount = 0;
     String lastReport = null;

     String backcolor = "class=\"offsetColor\"";
     String oldbackcolor = "";
     String newbackcolor;
     //various sets can go here... 
     Advances.setGeneralTitle("Other Debits");
     //Journal.setImportType("EOD");   //jh 20060803
     Journal.init(SystemDOM, PersFile.getConnection(), "EOD");
     //Journal.setupElement();   //jh 20110403

     boolean xFound = Journal.setParser(); 
   if (xFound) {
%>
        <tr>
        <td width="15%" <%=backcolor%> align="center"><u>Voucher</u></td>
        <td width="15%" <%=backcolor%> align="center"><u>Personnel #</u></td>
        <td width="15%" <%=backcolor%> align="center"><u>Release Date</u></td>
       <td width="15%" <%=backcolor%> align="center"><u>Company</u></td>        
        <td width="15%" <%=backcolor%> align="center"><u>Debit</u></td>
        <td width="15%" <%=backcolor%> align="center"><u>Credit</u></td>
        <td width="15%" <%=backcolor%> align="center"><u>Cost Center</u></td>
        <td width="15%" <%=backcolor%> align="right"><u>Amount</u></td>
        </tr>
<%      newbackcolor = backcolor;
        backcolor = oldbackcolor; 
        oldbackcolor = newbackcolor;
   try {
     do { 
        rowSet = Journal.getRow();        
        //if (encrypt.equalsIgnoreCase("YES")) {
        //  bArray = Reg.myResult.getBytes(1);
        //  E = new String(bArray);
        //  persname = unScramble(E,encrypt,encryptKey);   
        //} else {
        //  persname = PersFile.getTrim(Reg.myResult.getString(1));
        //}
        RP_PERS_NUM = rowSet[0];  
        RP_VOUCHER = rowSet[1];
        RP_NAME = rowSet[2]; 
        RP_DEPART = rowSet[3];
        RC_AMOUNT = rowSet[4];
        RC_ACCOUNT = rowSet[5];
//Skipping the receipt costcenter for now....under new schema will reintroduce it
        EX_AMOUNT = rowSet[7];
        EX_ACCOUNT = rowSet[8]; 
        EX_DEPART = rowSet[9];
        EX_COSTCENTER = rowSet[10];
        RP_UP_DATE = rowSet[11];
        EX_BILLTYPE = rowSet[12];
        EX_EXPENSE = rowSet[13];
        RC_CHARGE = rowSet[14];
        PR_PROJECT = rowSet[15];
        PR_CLIENTNO = rowSet[16];
        PR_STEPNO = rowSet[17];    
        RP_COMPANY = rowSet[18];

        //Log.println("[---] RP_PERS_NUM = " + rowSet[0]);  
        //Log.println("[---] RP_VOUCHER = " + rowSet[1]);
        //Log.println("[---] RP_NAME = " + rowSet[2]); 
        //Log.println("[---] RP_DEPART = " + rowSet[3]);
        //Log.println("[---] RC_AMOUNT = " + rowSet[4]);
        //Log.println("[---] RC_ACCOUNT = " + rowSet[5]);
        //Log.println("[---] EX_AMOUNT = " + rowSet[7]);          //money.format(money.parse(EX_AMOUNT))
        //Log.println("[---] EX_ACCOUNT = " + rowSet[8]); 
        //Log.println("[---] EX_DEPART = " + rowSet[9]);
        //Log.println("[---] EX_COSTCENTER = " + rowSet[10]);
        //Log.println("[---] RP_UP_DATE = " + rowSet[11]);
        //Log.println("[---] EX_BILLTYPE = " + rowSet[12]);
        //Log.println("[---] EX_EXPENSE = " + rowSet[13]);
        //Log.println("[---] RC_CHARGE = " + rowSet[14]);
        //Log.println("[---] PR_PROJECT = " + rowSet[15]);
        //Log.println("[---] PR_CLIENTNO = " + rowSet[16]);
        //Log.println("[---] PR_STEPNO = " + rowSet[17]);
  
        if (RP_VOUCHER.indexOf("\"") == 0) RP_VOUCHER = RP_VOUCHER.substring(1,RP_VOUCHER.length()-1);
        if (RP_PERS_NUM.indexOf("\"") == 0) RP_PERS_NUM = RP_PERS_NUM.substring(1,RP_PERS_NUM.length()-1);
        if (RP_UP_DATE.indexOf("\"") == 0) RP_UP_DATE = RP_UP_DATE.substring(1,RP_UP_DATE.length()-1);
        if (RC_ACCOUNT.indexOf("\"") == 0) RC_ACCOUNT = RC_ACCOUNT.substring(1,RC_ACCOUNT.length()-1);
        if (RP_COMPANY.indexOf("\"") == 0) RP_COMPANY = RP_COMPANY.substring(1,RP_COMPANY.length()-1);

        if (EX_AMOUNT.equals("null")) EX_AMOUNT = RC_AMOUNT;

        if (java.lang.Double.valueOf(EX_AMOUNT).doubleValue() != (double) 0.00) {
        
        	if (EX_ACCOUNT.equals("null")) {
        		if (RC_CHARGE.indexOf("\"") == 0) RC_CHARGE = RC_CHARGE.substring(1,RC_CHARGE.length()-1);
        		EX_ACCOUNT = SystemDOM.getDOMTableValueFor("generaloffset",RC_CHARGE.toLowerCase() + "_debit_account","offset");
        		EX_COSTCENTER = SystemDOM.getDOMTableValueFor("generaloffset",RC_CHARGE.toLowerCase() + "_debit_costcenter","offset");
        	} else {
        		if (EX_COSTCENTER.indexOf("\"") == 0) EX_COSTCENTER = EX_COSTCENTER.substring(1,EX_COSTCENTER.length()-1);
        		if (EX_ACCOUNT.indexOf("\"") == 0) EX_ACCOUNT = EX_ACCOUNT.substring(1,EX_ACCOUNT.length()-1);
        	}
        	if (lastReport == null || !lastReport.equals(RP_VOUCHER))
        	{
        		reportCount = reportCount + 1;
        		lastReport = new String(RP_VOUCHER);
        	}

%>          
        <tr>
        <td width="15%" <%=backcolor%> align="center"><%= RP_VOUCHER %></td>
        <td width="15%" <%=backcolor%> align="center"><%= RP_PERS_NUM %></td>
        <td width="15%" <%=backcolor%> align="center"><%= RP_UP_DATE %></td>
        <td width="15%" <%=backcolor%> align="center"><%= RP_COMPANY %></td>
        <td width="15%" <%=backcolor%> align="center"><%= EX_ACCOUNT %></td>
        <td width="15%" <%=backcolor%> align="center"><%= RC_ACCOUNT %></td>
        <td width="15%" <%=backcolor%> align="center"><%= EX_COSTCENTER %></td>
        <td width="15%" <%=backcolor%> align="right"><%= EX_AMOUNT%></td>
        </tr>
<%      
			totalAmount = Journal.addString2LongforCurrency(totalAmount, EX_AMOUNT); 
			if (!EX_EXPENSE.equals("null"))
			{  
				ExpenseSummary.add(RP_COMPANY + "-" + EX_ACCOUNT + "-" + EX_COSTCENTER,EX_AMOUNT,EX_BILLTYPE);
			} else {
				Advances.add(RP_COMPANY + "-" + EX_ACCOUNT,EX_AMOUNT,"");
			}
			CreditSummary.add(RP_COMPANY + "-" + RC_ACCOUNT,EX_AMOUNT,"");

			newbackcolor = backcolor;
			backcolor = oldbackcolor; 
			oldbackcolor = newbackcolor;
        } // checking that it is not zero
     } while (Journal.next());
%>
        <tr>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center"></td>        
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center">Total:</td>
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
        <td width="15%" <%=backcolor%> align="center"></td>
        <td width="15%" <%=backcolor%> align="center">Reports:</td>
        <td width="15%" <%=backcolor%> align="right"><%= Integer.toString(reportCount) %></td>
        </tr>
<%
  } catch (java.lang.Exception ex) {
    Log.println("[500] EODReport.jsp Language Error");
    Log.println("[500] EODReport.jsp - " + ex.toString());
    ex.printStackTrace();
%>
    <h1>Error in report logic - contact support.<br></h1>
<%  
  } //try

  } else {      // if(xFound)
%>

     <h1><br>No entries found in the EOD journal file.</h1>
<%
  }

  ExpenseSummary.sort();
  Advances.sort();
  CreditSummary.sort();

%>
  </form>
  </table>
  <br>
  <%= ExpenseSummary.printExpenseSummary() %>
  <br>
  <%= Advances.printGeneralSummary() %>
  <br>
  <%= CreditSummary.printGeneralSummary() %>
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
Log.println("[000] EODReport.jsp - finished for " + ownersName);
%>
<%@ include file="../UnScramble.jsp" %>



