<%--
FeedScreen.jsp - displays prepopulated infor in list for selection to post
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
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" /> 
          
<%@ include file="../../DBAccessInfo.jsp" %>

<% 
String email = request.getParameter("email"); 
boolean pFlag = PersFile.setPersInfo(email); 
String CCode = "";
Log.println("[000] FeedScreen.jsp: email:" + email);

if (pFlag) {
Log.println("[000] FeedScreen.jsp: pFlag is true");
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
%>
<%@ include file="../../SystemInfo.jsp" %>
<%
String database = request.getParameter("database");
DB.setConnection(PersFile.getConnection()); 
Reporter.setConnection(PersFile.getConnection()); 
Reporter.setSQLTerminator(PersFile.getSQLTerminator());
Reporter.setSQLStrings();
String reporterNum = request.getParameter("reporter");
boolean rFlag = Reporter.setPersNumInfo(reporterNum);
String selectItems = SystemDOM.getDOMTableValueFor("prepopulateditems","selectallitems","SELECT recno(),* FROM STATEMNT WHERE (VND_STAT = 'NW' OR RTRIM(VND_STAT) = '') AND RTRIM(EXP_CODE) = '$card$' AND RTRIM(CARD_NUM) = '$number$'" + PersFile.getSQLTerminator());

/// Need to change this to handle an infinite number from the CARD table

String[] Cards = new String[100];
String[] Numbers = new String[100]; 
String SQLCommand = SystemDOM.getDOMTableValueFor("prepopulateditems","selectcards");
SQLCommand = DB.SQLReplace(SQLCommand,"$email$",Reporter.getEmailAddress());
SQLCommand = DB.SQLReplace(SQLCommand,"$persnum$",Reporter.getPersNum());
int current_card = -1;
int total_cards = -1;
boolean breakout = false;

if (rFlag && DB.setResultSet(SQLCommand)) {
 do {
    total_cards = total_cards + 1;
    Cards[total_cards] = DB.myResult.getString("CHARGE").trim();
    Numbers[total_cards] = DB.myResult.getString("CARD").trim();
 } while (DB.myResult.next());
 if (total_cards > -1) {
   do {
     current_card = current_card + 1;
     breakout = DB.setResultSet( DB.SQLReplace( DB.SQLReplace(selectItems,"$card$",Cards[current_card]) ,"$number$",Numbers[current_card]) );
   } while (!breakout && current_card < total_cards);
 }
} 

if (current_card > -1) { %>

<form method="post" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ajax/prepopulated/FeedPost.jsp">
<input type="hidden" name="email" value="<%=email%>">
<input type="hidden" name="database" value="<%=database%>">
<input type="hidden" name="ccode" value="<%=CCode%>">
<input type="hidden" name="xref" value>
<input type="hidden" name="purpose" value>
<% String status; 
   String reference;
   String cardtype;
   String amount;
   String vendorReference;
   String commentInfo;
   String scanRef;
   String recordCursor;
   String backcolor = "class=\"TableData OffsetColor\"";
   String oldbackcolor = "class=\"TableData\"";
   String newbackcolor; 
   try { %>
    <table border="0" cellspacing="0" id="processingTable">
    <tr>
      <td width="5%"><strong>Add </strong></td>
      <td width="10%"><strong>Status</strong></td>
      <td width="14%"><strong>Card/Method</strong></td>
      <td width="13%"><strong>Date</strong></td>
      <td width="19%"><div align="right"><strong>Amount</strong></div></td>
      <td width="50%"><strong>Detail</strong></td>
    </tr>
<%    breakout = false;
      while (current_card <= total_cards) {  
      do { 
        status = DB.myResult.getString("STATUS"); 
        cardtype = DB.myResult.getString("CHARGE").trim();
        amount = makeCurrency(DB.myResult.getString("AMOUNT").trim());
        commentInfo = ess.Utilities.getXMLString(ensureSpace(DB.myResult.getString("INFO")));
        
        
        //scanInfo = 
        
  		//  <a href="<%= PersFile.SQLReplace(HrefString, "$link$", "/ess-app/receipts/ReceiptView.jsp?image=" + receiptRefs[i])%>"><img SRC="/ess/images/ess-View.gif" title='<%= Lang.getString("view")%>' /></a>&nbsp;&nbsp;
        	
        	
        vendorReference = ess.Utilities.getXMLString(ensureSpace(DB.myResult.getString("REFERENCE").trim()));
        recordCursor = DB.myResult.getString(1).trim();
        reference = ensureSpace(status)+";"+cardtype + ";"+ Numbers[current_card].trim() + ";" + vendorReference + ";" + amount + ";" + commentInfo + ";" + recordCursor ; %>
          <tr>
          <td width="5%" <%=backcolor%>><input type="checkbox" name="Trx" value="<%=reference%>" ></td>
          <td width="10%" <%=backcolor%>><%= status %></td>
          <td width="14%" <%=backcolor%>><%= cardtype%></td>
          <td width="13%" <%=backcolor%>><%= DD.getUserDateStr(DD.getSimpleDate(DD.adjustEpoch(DD.getDateFromXBase(DB.myResult.getString("TDATE")))),PersFile.getDateFormat())%></td>
          <td width="19%" <%=backcolor%>><div align="right"><%= amount %></div></td>
          <td width="50%" <%=backcolor%>><%= commentInfo %></td>
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
      } while(current_card <= total_cards && !breakout);   
    } 
   } catch (java.lang.Exception ex) {
      System.out.println("Error in the result set");
   }
%>
    </table>
<p>&nbsp;</p>    
<p><input id="btShow" type="button" value="Add checked items to report" name=" " onClick="Javascript: void SubmitRec()" onDblClick="dupFlagOK = false"></p>
</form>
<span language=JavaScript id="script" file="shared/feed.js" />

<% } else { %>
<p align="right"><a class-"ExpenseReturnLink" href="javascript: void parent.contents.ListDelay()">Return to report</a></p>
<p><h1> Sorry <%=request.getParameter("email")%>.  There are no credit card receipts for <%=Reporter.getEmailAddress()%> to process.
</h1></p>
<% 
} // no cards

} else { %>
   <%@ include file="../ReloginRedirectMsg.jsp" %>
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


