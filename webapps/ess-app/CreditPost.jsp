<%--
CreditPost.jsp - converts prepopulated items into receipts for report
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
     scope="session" />
<jsp:useBean id = "DOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "Rep2"
     class="ess.Report2Client"
     scope="page" />
<jsp:useBean id = "DD"
     class="ess.CustomDate"
     scope="session" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />

<%@ include file="DBAccessInfo.jsp" %>
<% 
String database = request.getParameter("database");

DB.setConnection(PersFile.getConnection());
DB.setSQLTerminator(PersFile.getSQLTerminator()); 

DOM.setConnection(PersFile.getConnection());
DOM.setSQLTerminator(PersFile.getSQLTerminator()); 

String email = request.getParameter("email");
String xref = request.getParameter("xref"); 
String purpose = request.getParameter("purpose");

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
<%@ include file="SystemInfo.jsp" %>
<%@ include file="PrepopInfo.jsp" %>
<%
String VendorExpType = "";
String paymentMethod = "";
String ParamName;
String ParamValue;
String[] ParamArray;
String XMLString = "<register><report>";
String SQLCommand;
boolean update_error = false;

String updateItem = SystemDOM.getDOMTableValueFor("prepopulateditems","updateitem","UPDATE STATEMNT SET VND_STAT = 'XX' WHERE recno() = $recordcursor$" + PersFile.getSQLTerminator());
String selectItem = SystemDOM.getDOMTableValueFor("prepopulateditems","selectitem","SELECT * FROM STATEMNT WHERE recno() = $recordcursor$" + PersFile.getSQLTerminator());

response.setHeader("Pragma", "No-cache");
response.setHeader("Cache-Control","no-cache, max-age=0, must-revalidate, no-store");
response.setDateHeader("Expires", 0);

%>  

<%@ page contentType="text/html" %>

<html>
<head>
<title>Credit Card Feed II</title>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">
</head>

<body onLoad="Javascript: void setReceipts()">
<strong><big> These are the parameters </big></strong><br>
<%
Log.println("[000] CreditPost.jsp: start");
       
for (java.util.Enumeration e = request.getParameterNames(); e.hasMoreElements();){
   ParamName = (String) e.nextElement(); %>
   <big><%= ParamName %></big><br>
<% ParamArray = request.getParameterValues(ParamName); 
   for(int i = 0; i < ParamArray.length; i++) { 
     ParamValue = ParamArray[i];
%>
     <%= ParamValue %><br> 
<% 
     if (ParamName.equals("Trx")) {
       java.util.StringTokenizer st = new java.util.StringTokenizer(ParamValue,";");
       StatementLineItem S = new StatementLineItem();
       S.status = st.nextToken();  //Think of moving these to the SQL statement down below.
       S.charge = st.nextToken();
       S.originalCharge = S.charge;
       S.acctno = st.nextToken();
       S.reference = ess.Utilities.getXMLString(st.nextToken());
       S.amount = st.nextToken();
       S.expensecomment = ess.Utilities.getXMLString(st.nextToken());
       S.xref = xref;
       S.purpose = purpose;
       S.recordCursor = st.nextToken();
       Log.println("[000] CreditPost.jsp: trx: " + S.reference + ", " + S.amount);
       //
       SQLCommand = DB.SQLReplace(selectItem,"$recordcursor$",S.recordCursor);
       
       DB.setResultSet(SQLCommand);
       S.amount = makeCurrency(S.amount);

       VendorExpType = DB.myResult.getString(1); //TRANS_TYPE
       S.rcptdate = DD.getUserDateStr(DD.getSimpleDate(DD.adjustEpoch(DD.getDateFromXBase(DB.myResult.getString(2)))),PersFile.getDateFormat()); //VND_TDATE
       
       S.prepopstatus = "XX";
       S.prepopreference = DB.myResult.getString(3);  //xref generated when item is imported.

       if (VendorExpType == null) VendorExpType = "0";  
       //This map corresponds to each customer

       Mapping.setAmount(S.amount);
       Mapping.setReference(S.reference);
       Mapping.setVendorCardSIC(S.charge,VendorExpType);

       if (!Mapping.getStatus()) {
         update_error = true; %>
         <br><br>Mapping Error in statement file - contact technical support<br><br>
<%     }

       
       S.screen = Mapping.getScreen();
       S.expensetype = ess.Utilities.getXMLString(Mapping.getExpenseType());  
       S.expenseamount = Mapping.getExpenseAmount();
       // S.expensecomment = Mapping.getExpenseComment();
       paymentMethod = Mapping.getPaymentMethod();
       if (paymentMethod != null && !paymentMethod.equals("")) S.charge = paymentMethod;

       XMLString += S.toString();
       
       SQLCommand = DB.SQLReplace(updateItem,"$recordcursor$",S.recordCursor);

//Do we need to check for a zero or not a 1????
       if (DB.doSQLExecute(SQLCommand) == -1) {
         update_error = true; %>
         <br><br>Error update status in statement file - contact technical support<br><br>
<%     }
     }
   }
}
XMLString += "</report></register>";
DOM.setDOM(XMLString);
Rep2.setReportStrings(DOM.getDOM());

Log.println("[000] CreditPost.jsp: finished");

%>

<script language="JavaScript">
function setReceipts() {

var ReceiptString = <%= Rep2.getReceipts() %>;

parent.contents.ProcessRepList('2',ReceiptString);
<% if (!update_error) { %>
parent.contents.ListDelay();
<% } %>
}
</script>
</body>
<head>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">
</head>
</html>

<% } else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } %>


<%!

public String makeCurrency(String f) {
   String s = f + "00";
   int i = s.indexOf(".");
   return s.substring(0, i + 3);     
}

%>

<%@ include file="StatementLineItem.jsp" %>

