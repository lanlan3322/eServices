<%--
FeedPost.jsp - converts prepopulated items into receipts for report
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
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />  

<%@ include file="../../DBAccessInfo.jsp" %>
<% 
request.setCharacterEncoding("UTF-8");     //Using encodeURIComponent on the upload so this is necessary
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
<%@ include file="../../SystemInfo.jsp" %>
<%@ include file="../../PrepopInfo.jsp" %>
<%
Log.println("[000] FeedPost.jsp: start");

String VendorExpType = "";
String paymentMethod = "";
String ParamName;
String ParamValue;
String[] ParamArray;
String XMLString = "<register><report>";
String SQLCommand;
int update_error = 0;

String updateItem = SystemDOM.getDOMTableValueFor("prepopulateditems","updateitem","UPDATE STATEMNT SET VND_STAT = 'XX' WHERE recno() = $recordcursor$" + PersFile.getSQLTerminator());
String selectItem = SystemDOM.getDOMTableValueFor("prepopulateditems","selectitem","SELECT * FROM STATEMNT WHERE recno() = $recordcursor$" + PersFile.getSQLTerminator());
String lodgingType = SystemDOM.getDOMTableValueFor("process","defaultlodging","LODGING");
Log.println("[000] FeedPost.jsp - lodging expense type: " + lodgingType);

%>  
<%@ page contentType="text/html" %>
<%

       
for (java.util.Enumeration e = request.getParameterNames(); e.hasMoreElements();){
   ParamName = (String) e.nextElement();
   ParamArray = request.getParameterValues(ParamName); 
   for(int i = 0; i < ParamArray.length; i++) { 
     ParamValue = ParamArray[i];
     if (ParamName.equals("Trx") && !ParamValue.equals("")) {
    	 Log.println("[000] FeedPost.jsp - paramvalue: " + ParamValue);    	 
       java.util.StringTokenizer st = new java.util.StringTokenizer(ParamValue,";");
       StatementLineItem S = new StatementLineItem();
       S.status = st.nextToken();  //Think of moving these to the SQL statement down below.
       S.charge = st.nextToken();
       S.originalCharge = S.charge;
       S.acctno = st.nextToken();
       S.reference = ess.Utilities.getXMLString(st.nextToken());
       S.amount = st.nextToken();
       S.expensecomment = st.nextToken();   //JH 2014-9-23
       S.scanref = st.nextToken();
       S.xref = xref;
       S.purpose = purpose;
       S.recordCursor = st.nextToken();
       Log.println("[000] FeedPost.jsp - trx: " + S.reference + ", " + S.amount);
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

       Mapping.setAmount(S.amount);     //object defined in ../../PrepopInfo.jsp
       Mapping.setReference(S.reference);
       Mapping.setVendorCardSIC(S.charge,VendorExpType);

       if (!Mapping.getStatus()) update_error = 1;    //Mapping error
       
       S.screen = Mapping.getScreen();
       S.expensetype = Mapping.getExpenseType();  
       S.expensetypename = Lang.getDataString(S.expensetype);
       S.expenseamount = Mapping.getExpenseAmount();
       // S.expensecomment = Mapping.getExpenseComment();
       paymentMethod = Mapping.getPaymentMethod();
       if (paymentMethod != null && !paymentMethod.equals("")) S.charge = paymentMethod;
       
       if (lodgingType.equals(S.expensetype))
       {
    	   Log.println("[000] FeedPost.jsp - lodging detected");
    		S.subtype = "1";
    		S.begdate = S.rcptdate;
    		S.enddate = S.rcptdate;
       }

       XMLString += S.toString();
       
       SQLCommand = DB.SQLReplace(updateItem,"$recordcursor$",S.recordCursor);

//Do we need to check for a zero or not a 1????
       if (DB.doSQLExecute(SQLCommand) == -1)  update_error = 2; //Technical error
        
     }
   }
}
XMLString += "</report></register>";
Log.println("[000] FeedPost.jsp - XMLString: " + XMLString);
DOM.setDOM(XMLString);
Rep2.setReportStrings(DOM.getDOM());

Log.println("[000] FeedPost.jsp - finished");

if (update_error == 0) { 
    Log.println("[000] FeedPost.jsp - finished cleanly: " + Rep2.getReceipts());
    %><%= Rep2.getReceipts() %><%
} else if (update_error == 1){
	Log.println("[500] FeedPost.jsp - finished with error 1 - mapping issue");
	%>ERROR<%
}  else if (update_error == 2){
	Log.println("[500] FeedPost.jsp - finished with error 2 - database update problem");
	%>ERROR<%
} else {
	Log.println("[500] FeedPost.jsp - finished with unknown errors");
	%>ERROR<%
}

} else { %>
   <%@ include file="../ReloginRedirectMsg.jsp" %>
<% } %>


<%!

public String makeCurrency(String f) {
   String s = f + "00";
   int i = s.indexOf(".");
   return s.substring(0, i + 3);     
}

%>

<%@ include file="../../StatementLineItem.jsp" %>

