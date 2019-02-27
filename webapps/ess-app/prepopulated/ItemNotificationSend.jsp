<%--
ItemNotificactionSend.jsp - Sends notices to delinquent approvals
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
     scope="session" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "Notify"
     class="ess.PersonnelTable"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="page" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" /> 

<%@ include file="../DBAccessInfo.jsp" %>

<%
String owner = request.getParameter("email");
boolean pFlag = PersFile.setPersInfo(owner); 

if (pFlag  && PersFile.active.equals("1")) {        //add in a level check
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
%>

<%@ include file="../StatusInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>
<%@ include file="../DepartInfo.jsp" %>
<%@ include file="../NumericSetup.jsp" %>

<%


String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)


Notify.setConnection(PersFile.getConnection());
Notify.setSQLTerminator(PersFile.getSQLTerminator()); 
Notify.setSQLStrings();

SysTable.setConnection(PersFile.getConnection());
SysTable.setSQLTerminator(PersFile.getSQLTerminator());

Reg.setConnection(PersFile.getConnection()); 
Reg.setSQLTerminator(PersFile.getSQLTerminator());

boolean errorCondition = false; 

String pal_address = SysTable.getSystemString("PAL_EMAIL_ADDRESS","expense@adisoft-inc.com");

String msgdata = request.getParameter("msgdata");
String rcpt2 = request.getParameter("rcpt2");
String reply2 = request.getParameter("reply2");

%>

<html>
<head>
<title>Follow-up Notification</title>
<link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
</head>

<body>
<%@ include file="../StandardTop.jsp" %>
<h1>Item Notifications Sent</h1>
<em>Started: <%= Dt.entryDate() %></em><br><br>
<%
   String backcolor = "class=\"offsetColor\"";
   String oldbackcolor = "";
   String newbackcolor;
   
   String SQLCommand;
   
   String statemnt_xref;
   String persname = "";
   String card = "";
   String transdate = ""; 
   String reference = "";
   String amount = "";
   String status = "";
   String info = "";
   String persnum = ""; 

   String sendTo;
   String notifyMsg;
   
   String SQLDate = SystemDOM.getDOMTableValueFor("sql","datesql");
   String SQLType = SystemDOM.getDOMTableValueFor("sql","dateformat");
   if (SQLType.equalsIgnoreCase("MM/DD/YYYY")) { 
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",Dt.simpleDate.format(Dt.date));
   } else if (SQLType.equalsIgnoreCase("DD-MMM-YYYY")){    // oracle
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",Dt.getOracleDate(Dt.date));
   } else { //generate YYYY-MM-DD
     SQLDate = Reg.SQLReplace(SQLDate,"$date$",Dt.xBaseDate.format(Dt.date));
   } 

   java.util.StringTokenizer rp = new java.util.StringTokenizer(request.getParameter("xref"), ";"); 
   java.util.StringTokenizer st = new java.util.StringTokenizer(request.getParameter("status"), ";"); 

   String notifyText = SystemDOM.getDOMTableValueFor("prepopulatedmessages","notifymessage");
   Log.println("[000] ItemNotificactionSend.jsp notifymessage - " + notifyText);
   String itemText = SystemDOM.getDOMTableValueFor("prepopulatedmessages","itemlist");
   Log.println("[000] ItemNotificactionSend.jsp notifymessage - " + itemText);
   
   String warningStati = SystemDOM.getDOMTableValueFor("prepopulatedmessages","warningstatus");
   String warningMsg = SystemDOM.getDOMTableValueFor("prepopulatedmessages","warningmessage");

   
   
   String action = request.getParameter("action");
%>   
   
<table>
<tr>
<td><u>Employee</u></td>
<td><u>transdate</u></td>
<td><u>reference</u></td>
<td><u>amount</u></td>
<td><u>info</u></td>
<td><u>message</u></td></tr>
<% 

   String SQLText = SystemDOM.getDOMTableValueFor("prepopulatedmessages","messagesendsql","");
   boolean xFlag = false;
   boolean keepGoing = true;
   String xref = ""; 
   String oldXref;
   String items = "";
   String oldPersnum = "";	
   String oldCard = "";
   String oldStatus = "ZZ";
   String sendConfirm = "Start";
   int messagesSent = 0;
   int messagesFailed = 0;
   String itemList = "";
   
   while (keepGoing) {  

%>      <tr <%=backcolor%>><td><%= persname %></td><td><%= transdate%></td><td><%= reference %></td><td><%= amount %></td><td><%= info %></td>
<%	 
     items += itemList;
     oldXref = xref;
	 oldPersnum = persnum;
	 oldCard = card;
	 oldStatus = status;
	 if (rp.hasMoreTokens()) {
     	xref = rp.nextToken().trim() ;
     	status = st.nextToken().trim() ;
	 } else {
    	 xref = "";
		 status = "";
		 keepGoing = false;
	 }
     xFlag = true;
	 if (keepGoing) {
     	if (SQLText.equals("")) {
    		 SQLCommand = "SELECT XREF, EMPLOYEE, STATEMNT.CHARGE, STATEMNT.CARD, TDATE, REFERENCE, AMOUNT, STATUS, INFO, CARD.PERS_NUM FROM STATEMNT LEFT JOIN CARD ON STATEMNT.CARD = CARD.CARD WHERE XREF = '$xref$' ORDER BY EMPLOYEE" + PersFile.getSQLTerminator();
     	} else {
    		 SQLCommand = SQLText;
     	}

     	SQLCommand = Reg.SQLReplace(SQLCommand,"$xref$",xref);

     	xFlag = Reg.setResultSet(SQLCommand);
     	if (xFlag) {
    	 
        	statemnt_xref = PersFile.getTrim(Reg.myResult.getString(1)); 
         	persname = PersFile.getTrim(Reg.myResult.getString(2));
         	card = PersFile.getTrim(Reg.myResult.getString(4));
         	transdate = PersFile.getTrim(Reg.myResult.getString(5)); 
         	reference = PersFile.getTrim(Reg.myResult.getString(6));
         	amount = money.format(money.parse(PersFile.getTrim(Reg.myResult.getString(7))));
         	status = PersFile.getTrim(Reg.myResult.getString(8));
         	info = PersFile.getTrim(Reg.myResult.getString(9));
         	persnum = PersFile.getTrim(Reg.myResult.getString(10)); 
                 
        	itemList = "\n" + Reg.SQLReplace(itemText,"$xref$",xref);
        	itemList = Reg.SQLReplace(itemList,"$persname$",persname);
        	itemList = Reg.SQLReplace(itemList,"$card$",card);
        	itemList = Reg.SQLReplace(itemList,"$transdate$",transdate);
        	itemList = Reg.SQLReplace(itemList,"$reference$",reference);
        	itemList = Reg.SQLReplace(itemList,"$amount$",amount);
        	itemList = Reg.SQLReplace(itemList,"$status$",status);
        	itemList = Reg.SQLReplace(itemList,"$info$",info);
        	
        	if (warningStati.indexOf(oldStatus) > -1) {
        		itemList = Reg.SQLReplace(itemList,"$warning$",warningMsg);
        	} else {
        		itemList = Reg.SQLReplace(itemList,"$warning$","");
        	}
        	

     	}
	 }
	 

     if (xFlag && !oldCard.equals("") && (!card.equals(oldCard)) || !keepGoing) {
//determine the followup type

        Log.println("[000] ItemNotificactionSend.jsp - persnum: " + oldPersnum);

        if (Notify.setPersNumInfo(oldPersnum)) {
            sendTo = Notify.getEmailAddress();
        } else {
        	sendTo = "";
        }

        notifyMsg = Reg.SQLReplace(notifyText,"$items$","\n\n"+items+"\n\n");
        notifyMsg = Reg.SQLReplace(notifyMsg,"$card$",oldCard);
         
        Log.println("[000] ItemNotificactionSend.jsp - msg: " + notifyMsg);
        
        if (!sendTo.equals("")) {
        	if (SendAnEmail(sendTo, pal_address, "charge card - expense report outstanding items", notifyMsg, SysTable)) {
                sendConfirm = "Delivered";
                Log.println("[000] ItemNotificactionSend.jsp - delivery OK to " + sendTo + " for " + xref);
                messagesSent++;
          	} else {
          		sendConfirm = "Failed";
                Log.println("[400] ItemNotificactionSend.jsp - delivery failure to " + sendTo + ", item: " + xref);
                messagesFailed++;
          	}
       	} else { 
       		sendConfirm = "Failed - no recipient";
            Log.println("[400] ItemNotificactionSend.jsp - item: " + xref + " could not locate user");
            messagesFailed++;
       	} 
        items = "";
        %><td><%= sendConfirm %></td></tr><%
     } else if (!xFlag) { 
       %>
       <tr <%=backcolor%>><td><%= xref %></td><td></td><td></td><td></td><td></td><td></td><td>message not sent due to database access problem</td>
       <%  Log.println("[500] ItemNotificactionSend.jsp - item: " + xref + " had a database access error");
       sendConfirm = "Database error";
       items = "";
       messagesFailed++;
     } else if (oldXref.equals("")) {
    	 Log.println("[000] ItemNotificactionSend.jsp - item: " + xref + " start of mail generation process");
    	 items = "";
         %><td><%= sendConfirm %></td></tr><%
     } else {
    	sendConfirm = ""; 
        %><td></td></tr><%
     }
   newbackcolor = backcolor;
   backcolor = oldbackcolor; 
   oldbackcolor = newbackcolor;
   }   //while keepGoing loop 
%>
</table>
<br><em>Finished: <%= Dt.entryDate() %>, Messages sent: <%= messagesSent %> Errors: <%= messagesFailed %></em><br><br>
<%@ include file="../StandardBottom.jsp" %>
</body>
</html>
<% 
} else { 
   java.lang.Integer loginAttempts = (java.lang.Integer) session.getValue("loginAttempts");
   int numTrys = loginAttempts.intValue() + 1;
   if (numTrys > 3) {
     Log.println("[400] ApprovalSave.jsp Invalid password (3X) for " + owner); %>
     <%@ include file="../ReloginRedirectMsg.jsp" %>
<% } else { 
%>     <%@ include file="../InvalidPasswordMsg.jsp" %>
<% }
 }
%>

<%@ include file="../SendAnEmail.jsp" %>


