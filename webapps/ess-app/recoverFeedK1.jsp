<%--
recoverFeedK1.jsp - list prepops (e.g., credit card items) that haven't been reconciled so they can be reset
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

<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "DB"
     class="ess.AdisoftDbase"
     scope="page" />
<jsp:useBean id = "DD"
     class="ess.CustomDate"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Reporter"
     class="ess.PersonnelTable"
     scope="page" />

<% 

String email = request.getParameter("email"); 

boolean pFlag = PersFile.setPersInfo(email); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
%>
<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<%
String database = request.getParameter("database");
DB.setConnection(PersFile.getConnection()); 
Reporter.setConnection(PersFile.getConnection()); 
Reporter.setSQLTerminator(PersFile.getSQLTerminator());
Reporter.setSQLStrings();

String reporterNum = request.getParameter("reporter");
boolean rFlag = Reporter.setPersNumInfo(reporterNum);

String selectItems = SystemDOM.getDOMTableValueFor("prepopulatedrecovery","selectallitems","SELECT recno(),* FROM STATEMNT WHERE (VND_STAT = 'NW' OR RTRIM(VND_STAT) = '') AND RTRIM(EXP_CODE) = '$card$' AND RTRIM(CARD_NUM) = '$number$'" + PersFile.getSQLTerminator());

String[] Cards = new String[3];
String[] Numbers = new String[3]; 
String SQLCommand = SystemDOM.getDOMTableValueFor("personneltable","persinfosql");
SQLCommand = DB.SQLReplace(SQLCommand,"$email$",Reporter.getEmailAddress().toUpperCase());
int current_card = -1;
boolean breakout = false;
if (rFlag && DB.setResultSet(SQLCommand)) {
    Cards[0] = DB.myResult.getString("CHARGE1").trim();
    Numbers[0] = DB.myResult.getString("CARD1").trim();
    Cards[1] = DB.myResult.getString("CHARGE2").trim();
    Numbers[1] = DB.myResult.getString("CARD2").trim();
    Cards[2] = DB.myResult.getString("CHARGE3").trim();
    Numbers[2] = DB.myResult.getString("CARD3").trim();
} 
//Need to change below for selectItems to make processor independent
if (!Cards[0].equals("") && !Numbers[0].equals("") && DB.setResultSet( DB.SQLReplace( DB.SQLReplace(selectItems,"$card$",Cards[0]) ,"$number$",Numbers[0]) )) {
    current_card = 0;  
} else if (!Cards[1].equals("") && !Numbers[1].equals("") && DB.setResultSet( DB.SQLReplace( DB.SQLReplace(selectItems,"$card$",Cards[1]) ,"$number$",Numbers[1]) )) {
    current_card = 1;
} else if (!Cards[2].equals("") && !Numbers[2].equals("") && DB.setResultSet( DB.SQLReplace( DB.SQLReplace(selectItems,"$card$",Cards[2]) ,"$number$",Numbers[2]) )) {
    current_card = 2;
}
%>  
<%@ page contentType="text/html" %>
<html>
<% if (current_card > -1) { %>
<head>
<title>Charge Recovery I</title>
<link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
</head>

<body>
<div align="right"><a href="javascript: void parent.frames[1].helpWindow('hrecoverfeed.html')"><span class="ExpenseLink">Screen Help?</span></a></div>

<table border="0" cellpadding="0" cellspacing="1" width="100%" class="offsetColor">
  <tr>
    <td width="100%"><h1>Charge Recovery</h1></td>
  </tr>
</table>


<p><strong>Check the transactions that you wish to recover.  When finished click on the button below. After the transactions have been recovered, you will be transfered to the Pre-populated Charges wizard. </strong></p>
<form method="post" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/recoverPostK1.jsp">
<input type="hidden" name="email" value="<%=email%>">
<input type="hidden" name="database" value="<%=database%>">
<input type="hidden" name="ccode" value="<%=CCode%>">
<% String status; 
   String reference;
   String cardtype;
   String amount;
   String recordCursor;
   String backcolor = "class=\"offsetColor\"";
   String oldbackcolor = "";
   String newbackcolor; 
   try { %>
    <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
    <tr>
      <td width="5%" align="center"><u><strong>Recover</strong></u></td>
      <td width="10%" align="center"><u><strong>Status</strong></u></td>
      <td width="14%" align="center"><u><strong>Card/Method</strong></u></td>
      <td width="13%" align="center"><u><strong>Date</strong></u></td>
      <td width="19%" align="center"><u><strong>Amount</strong></u></td>
      <td width="50%" align="center"><u><strong>Detail</strong></u></td>
    </tr>
<%    while (current_card < 3) {
      do { 
        status = DB.myResult.getString("VND_STAT").trim(); 
        cardtype = DB.myResult.getString("EXP_CODE").trim();
        amount = makeCurrency(DB.myResult.getString("VND_AMT").trim());
        recordCursor = DB.myResult.getString(1).trim();
        reference = status+";"+cardtype + ";"+ Numbers[current_card].trim() + ";" +  ess.Utilities.getXMLString(ensureSpace(DB.myResult.getString("VND_REF").trim())) + ";" + amount + ";" + recordCursor ; %>
          <tr>
          <td width="5%" <%=backcolor%> align="center"><input type="checkbox" name="Trx" value="<%=reference%>" ></td>
          <td width="10%" <%=backcolor%> align="center"><%= status %></td>
          <td width="14%" <%=backcolor%> align="center"><%= cardtype%></td>
          <td width="13%" <%=backcolor%> align="center"><%= DD.getSimpleDate(DD.adjustEpoch(DD.getDateFromXBase(DB.myResult.getString("VND_TDATE"))))%></td>
          <td width="19%" <%=backcolor%> align="center"><%= amount %></td>
          <td width="50%" <%=backcolor%> align="center"><%= DB.myResult.getString("VND_INFO")%></td>
          </tr>
     <% newbackcolor = backcolor;
        backcolor = oldbackcolor; 
        oldbackcolor = newbackcolor;
      } while (DB.myResult.next());
      do {
        current_card += 1;
        if (!Cards[current_card].trim().equals("") && !Numbers[current_card].trim().equals("") && DB.setResultSet( DB.SQLReplace( DB.SQLReplace(selectItems,"$card$",Cards[current_card]) , "$number$",Numbers[current_card]) )) {
          breakout = true;    
        } else {
          breakout = false;
        }
      } while(current_card < 3 && !breakout);
    } 
   } catch (java.lang.Exception ex) {
      System.out.println("Error in the result set");
   }
%>
    </table>
<p><input type="button" value="Recover checked receipts to reuse" name=" " onClick="Javascript: void SubmitRec()"></p>
</form>

<p align="right"><a class-"ExpenseReturnLink" href="javascript: void parent.frames[1].ListDelay()">Return to report</a></p>
<script language="JavaScript">

function SubmitRec() {
    document.forms[0].submit();
}


</script>

</body>
<% } else { %>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Introduction Page</title>
<link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
</head>
<body>
<p><h1> Sorry <%=request.getParameter("email")%>.  There are no prepopulated charges for <%=Reporter.getEmailAddress()%> to recover.
</h1></p>

<p>&nbsp;</p>
</body>
<% } %>
</html>

<% } else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } %>




<%!
public String makeCurrency(String f) {
    String retVal = "";
    int i = f.indexOf(".");
    if (i > -1) {
        String s = f + "00";
        retVal = s.substring(0, i + 3);     
    } else {
        retVal = f + ".00";
    }
    return retVal;
}  
public String ensureSpace(String f) {
   if (f == null || f.equals("")) {
     f = " ";
   }
   return f;
}
%>


