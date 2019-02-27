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
boolean notbreakout = false;

if (rFlag && DB.setResultSet(SQLCommand)) {
 do {
    total_cards = total_cards + 1;
    Cards[total_cards] = DB.myResult.getString("CHARGE").trim();
    Numbers[total_cards] = DB.myResult.getString("CARD").trim();
 } while (DB.myResult.next());
}
total_cards = total_cards + 1;
Cards[total_cards] = "CASH";
Numbers[total_cards] = Reporter.getPersNum();
total_cards = total_cards + 1;
Cards[total_cards] = "ADVANCE";
Numbers[total_cards] = Reporter.getPersNum();

if (total_cards > -1) {  //In case the above code is removed
   do {
     current_card = current_card + 1;
     notbreakout = notbreakout || DB.setResultSet( DB.SQLReplace( DB.SQLReplace(selectItems,"$card$",Cards[current_card]) ,"$number$",Numbers[current_card]) );
   } while ((!notbreakout) && (current_card < total_cards));
}
if (notbreakout) {
	Log.println("[000] FeedScreen.jsp: true total_cards: " + java.lang.Integer.toString(total_cards + 1));
} else {
	Log.println("[000] FeedScreen.jsp: false total_cards: " + java.lang.Integer.toString(total_cards + 1));	
}	
Log.println("[000] FeedScreen.jsp: current cards at start: " + java.lang.Integer.toString(current_card));
if (notbreakout) { %>

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
   String scanref;
   String recordCursor;
   String backcolor = "class=\"TableData OffsetColor\"";
   String oldbackcolor = "class=\"TableData\"";
   String newbackcolor; 
   String magnify;
   try { %>
    <table border="0" cellspacing="0" id="processingTable">
    <tr>
      <td width="5%"><strong><%= Lang.getDataString("Add") %></strong></td>
      <td width="10%"><strong><%= Lang.getDataString("Status") %></strong></td>
      <td width="14%"><strong><%= Lang.getDataString("Card/Method") %></strong></td>
      <td width="13%"><strong><%= Lang.getDataString("Date") %></strong></td>
      <td width="19%"><div align="right"><strong><%= Lang.getDataString("Amount") %></strong></div></td>
      <td width="50%"><strong><%= Lang.getDataString("Detail") %></strong></td>
      <td width="8%"></td>
    </tr>
<%    notbreakout = true;
      while ((notbreakout) && (current_card <= total_cards)) {  
      do { 
        status = DB.myResult.getString("STATUS"); 
        cardtype = DB.myResult.getString("CHARGE");
        amount = makeCurrency(DB.myResult.getString("AMOUNT"));
        commentInfo = ensureSpace(DB.myResult.getString("INFO"));      
		//commentInfo = ess.Utilities.getXMLString(ensureSpace(commentInfo));
        vendorReference = ess.Utilities.getXMLString(ensureSpace(DB.myResult.getString("REFERENCE")));
        scanref = ess.Utilities.getXMLString(ensureSpace(DB.myResult.getString("SCAN_REF")));
        recordCursor = DB.myResult.getString(1).trim();
        reference = ensureSpace(status)+";"+cardtype + ";"+ Numbers[current_card].trim() + ";" + vendorReference + ";" + amount + ";" + commentInfo + ";" + scanref + ";" + recordCursor ; %>
          <tr>
          <td width="5%" <%=backcolor%>><input type="checkbox" name="Trx" value="<%=reference%>" ></td>
          <td width="10%" <%=backcolor%>><%= status %></td>
          <td width="14%" <%=backcolor%>><%= cardtype%></td>
          <td width="13%" <%=backcolor%>><%= DD.getUserDateStr(DD.getSimpleDate(DD.adjustEpoch(DD.getDateFromXBase(DB.myResult.getString("TDATE")))),PersFile.getDateFormat())%></td>
          <td width="19%" <%=backcolor%>><div align="right"><%= amount %></div></td>
          <td width="50%" <%=backcolor%>><%= commentInfo %></td>  
          <% if ((scanref == null) || (scanref.trim().equals("")))
   		  {
            magnify = "";      	  
   		  } else {
          	magnify = "<a href=\"javascript: void window.open('" + "/ess-app/receipts/ReceiptView.jsp?image=" + scanref + "' , 'Receipt Image', 'dependent=yes, width=700, height=540, screenX=580, screenY=420, resizable, titlebar=yes, menubar=yes, status=no, scrollbars=yes')\">";
            magnify += "<img SRC='/ess/images/ess-View.gif' title='" + Lang.getString("view") + "' /></a>";
   		  }
          %><td width="8%" <%=backcolor%>><%= magnify %></td>
          </tr>
     <% newbackcolor = backcolor;
        backcolor = oldbackcolor; 
        oldbackcolor = newbackcolor;
      } while (DB.myResult.next());
      current_card += 1;
      do {
        if (!Cards[current_card].equals("") && !Numbers[current_card].equals("")) { 
        	if (DB.setResultSet( DB.SQLReplace( DB.SQLReplace(selectItems,"$card$",Cards[current_card]) , "$number$",Numbers[current_card]) )) {
        		notbreakout = true;  //probably useless    
        	} else {
        		notbreakout = false;
        		current_card += 1;
        	}
        } else {
        	notbreakout = false;
        	current_card += 1;
        }
      } while((!notbreakout) && (current_card <= total_cards)); 
      // } while(current_card <= total_cards && !breakout);    
      Log.println("[000] FeedScreen.jsp: current cards at bottom: " + java.lang.Integer.toString(current_card));
    } 
   } catch (java.lang.Exception ex) {
	  Log.println("[500] FeedScreen.jsp: Error in the result set: " + Cards[current_card]);
	  Log.println("[500] FeedScreen.jsp error : " + ex.toString());
	  ex.printStackTrace();
   }
%>
    </table>
<p>&nbsp;</p>    
<p><input id="btShow" type="button" value='<%= Lang.getDataString("AddToReport","Add checked items to report") %>' name=" " onClick="Javascript: void SubmitRec()" onDblClick="dupFlagOK = false"></p>
</form>
<span language=JavaScript id="script" file="shared/feed.js" />

<% } else { %>
<p><h1> Sorry <%=request.getParameter("email")%>.  There are no credit card receipts to process.
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


