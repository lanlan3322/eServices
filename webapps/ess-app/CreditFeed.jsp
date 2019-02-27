<%--
CreditFeed.jsp - displays prepopulated infor in list for selection to post
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
<%@ include file="DBAccessInfo.jsp" %>
<% 
String email = request.getParameter("email"); 
boolean pFlag = PersFile.setPersInfo(email); 
String CCode = "";
Log.println("[000] CreditFeed.jsp: email:" + email);

if (pFlag) {
Log.println("[000] CreditFeed.jsp: pFlag is true");
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
%>
<%@ include file="SystemInfo.jsp" %>
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
/// End of the change //////

%>  
<%@ page contentType="text/html" %>
<html>
<% if (current_card > -1) { %>
<head>
<title>Credit Card Feed</title>
<link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
</head>

<body onLoad="javascript:void FillForm()">
<div align="right"><a href="javascript: void parent.contents.helpWindow('hprepopulate.html')"><span class="ExpenseLink">Screen Help?</span></a></div>

<table border="0" cellpadding="0" cellspacing="1" width="100%" class="offsetColor">
  <tr>
    <td width="100%"><h1>Enter the purpose for these receipts</h1></td>
  </tr>
</table>
<%
// Get the methodology from the disconnected version and put it into here.
%>
<form>
  <input type="hidden" name="xref" value>
  <table border="0" cellpadding="0" cellspacing="0" width="100%">
   <tr>
      <td align="right" width="100%" class="offsetColor"><div class="ExpenseTag">Select purpose:&nbsp;<select name="this_purpose" size="1" mysubst="11" onChange="cPurposeLoad()" subtype="nosave">
      </select></div></td>
   </tr>
   <tr>
      <td width="100%">
       <table border="0" cellpadding="0" cellspacing="0" width="100%" height="240">
       <tr>
          <td width="25%" class="offsetColor" height="25"><div class="ExpenseTag">Visit From:</div></td>
          <td width="40%" class="offsetColor" height="25"><input type="text" name="begdate" size="8" value="mm/dd/yy" mysubst="1" onChange="checkdate(document.forms[0].begdate)"><a HREF="javascript:doNothing()" mysubst="2" onClick="setDateField(document.forms[0].begdate); top.newWin = window.open('<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.html', 'cal', 'dependent=yes, width=210, height=230, screenX=200, screenY=300, titlebar=yes')"><img SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.gif" BORDER="0" WIDTH="16" HEIGHT="16"></a><span class="ExpenseTinyLink">Popup Calendar</span></td>
          <td width="35%" class="offsetColor"></td>        
       </tr>
       <tr>
          <td width="25%" height="25"><div class="ExpenseTag">To:</div></td>
          <td width="40%" height="25"><input type="text" name="enddate" size="8" value="mm/dd/yy" mysubst="3" onChange="checkdate(document.forms[0].enddate)"><a HREF="javascript:doNothing()" mysubst="4" onClick="setDateField(document.forms[0].enddate); top.newWin = window.open('<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.html', 'cal', 'dependent=yes, width=210, height=230, screenX=200, screenY=300, titlebar=yes')"><img SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.gif" BORDER="0" WIDTH="16" HEIGHT="16"></a><span class="ExpenseTinyLink">Popup Calendar</span></td>
          <td width="35%"></td>         
       </tr>
       <tr>
          <td width="25%" class="offsetColor"><div class="ExpenseTag">Acct/Project #:</div></td>
          <td width="40%" class="offsetColor"><input type="text" name="project" size="12" mysubst="5">
          </td>
          <td width="35%" class="offsetColor" align="right">
          <a class="ExpenseLink" href="javascript:doNothing()" mysubst="6" onClick="setLocalObj(document.forms[0].projectname,'addproject2',400,200); MerchantType = 'file'; top.newWin = window.open('<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/addproject2.html', 'merchant', 'dependent=yes, width=360, height=200 screenX=100, screenY=100, titlebar=yes, menubar=no, status=no')">New&nbsp;Acct/Project&nbsp;</a>
          <select name="projectname" size="1" mysubst="5" onChange="populateProject()" onReturn="populateProject()" subtype="nosave">
          </select>
          </td>     
       </tr>
       <tr>
          <td width="25%" height="26"><div class="ExpenseTag">Client #:</div></td>
          <td width="40%" height="26"><input type="text" name="clientno" size="12" mysubst="7" onChange="populateClient()">
          </td>
          <td width="35%" align="right">
          <a class="ExpenseLink" href="javascript:doNothing()" mysubst="8" onClick="setLocalObj(document.forms[0].clientLookup,'addclient',400,450); MerchantType = 'client'; top.newWin = window.open('<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/addclient.html', 'merchant', 'dependent=yes, width=400, height=400, screenX=100, screenY=100, titlebar=yes, menubar=no, status=no')">New&nbspClient&nbsp;</a>
          <select name="clientLookup" size="1" mysubst="5" onChange="populateClient()" onReturn="populateClient()">
          </select>
          </td>
        </tr>
        <tr>
          <td width="25%" class="offsetColor" height="25"><div class="ExpenseTag">Client Name:</div></td>
          <td width="40%" class="offsetColor" height="25"><input type="text" name="client" size="31" mysubst="9"></td>
          <td width="25%" class="offsetColor"></td>
        </tr>
        <tr>
          <td width="25%" height="26"><div class="ExpenseTag">Location:</div></td>
          <td width="40%" height="26">
          <input type="text" name="location" size="30" mysubst="10">
          </td>
          <td width="25%" align="right">
          <a class="ExpenseLink" href="javascript:doNothing()" mysubst="11" onClick="setLocalObj(document.forms[0].locationname); MerchantType = 'locationname'; top.newWin = window.open('<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/addmerchant.html', 'merchant', 'dependent=yes, width=200, height=150, screenX=100, screenY=100, titlebar=yes, menubar=no, status=no')">New&nbsp;Location&nbsp;</a>
          <select name="locationname" size="1" mysubst="10" onChange="populateLocation()" onReturn="populateLocation()" subtype="nosave">
          </select>
          </td>
        </tr>
        <tr>
          <td width="25%" class="offsetColor" height="113"><div class="ExpenseTag">Trip Purpose or Reason for Expense:</div></td>
          <td width="40%" class="offsetColor" height="113"><textarea rows="4" name="comment" cols="37" mysubst="12"></textarea></td>
          <td width="25%" class="offsetColor"></td>
        </tr>
        <tr>
          <td width="25%"><div class="ExpenseTag">Aircraft type:</div></td>
          <td width="40%"><select name="stepno" size="1">
            <option selected>None</option>
            <option>Commercial</option> 
            <option>Corporate</option>
          </select>
          </td>
          <td width="25%"></td>
        </tr>
       </table>
      </td>
    </tr>
  </table>
</form>
<p><strong>Enter purpose and then check the transactions that you wish to add to your expense report under this purpose.  When finished click on the button below.</strong></p>
<form method="post" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/CreditPost.jsp">
<input type="hidden" name="email" value="<%=email%>">
<input type="hidden" name="database" value="<%=database%>">
<input type="hidden" name="ccode" value="<%=CCode%>">
<input type="hidden" name="xref" value>
<input type="hidden" name="purpose" value>
<% String status; 
   String reference;
   String cardtype;
   String amount;
   String vendoreference;
   String commentInfo;
   String recordCursor;
   String backcolor = "class=\"offsetColor\"";
   String oldbackcolor = "";
   String newbackcolor; 
   try { %>
    <table border="0" cellspacing="0" width="90%" bordercolordark="#008080">
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
        vendorReference = ess.Utilities.getXMLString(ensureSpace(DB.myResult.getString("REFERENCE").trim()));
        recordCursor = DB.myResult.getString(1).trim();
        reference = ensureSpace(status)+";"+cardtype + ";"+ Numbers[current_card].trim() + ";" + vendorReference + ";" + amount + ";" + commentInfo + ";" + recordCursor ; %>
          <tr>
          <td width="5%" <%=backcolor%>><input type="checkbox" name="Trx" value="<%=reference%>" ></td>
          <td width="10%" <%=backcolor%>><%= status %></td>
          <td width="14%" <%=backcolor%>><%= cardtype%></td>
          <td width="13%" <%=backcolor%>><%= DD.getSimpleDate(DD.adjustEpoch(DD.getDateFromXBase(DB.myResult.getString("TDATE"))))%></td>
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
<p><input type="button" value="Add purpose and checked receipts to report" name=" " onClick="Javascript: void SubmitRec()" onDblClick="dupFlagOK = false"></p>
</form>

<p align="right"><a class-"ExpenseReturnLink" href="javascript: void parent.contents.ListDelay()">Return to report</a></p>
<script LANGUAGE="JavaScript" SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.js"></script>
<script LANGUAGE="JavaScript" SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/addmerchant.js"></script>
<script language="JavaScript">
function FillForm() {
  parent.contents.setListWKeyWPers(document.forms[0].projectname,parent.contents.getProjectNos("1"),"file","project","title");
  parent.contents.setListWValueWPers(document.forms[0].clientLookup, parent.contents.getClientNos("2"),"client","client","clientno")
  
  //Sets the purpose pulldown from the HeadList
  var SelectObj = document.forms[0].this_purpose;
  parent.contents.setDfltFrmHdWSplit(SelectObj);
  var index = document.forms[0].this_purpose.length;
  if (index > 0) {
     document.forms[0].this_purpose.length = index + 1
     for (var i = index; i > 0; i--) {
      SelectObj.options[i].text = SelectObj.options[i-1].text;
      SelectObj.options[i].value = SelectObj.options[i-1].value;
     }
  } else {
    SelectObj.length = 1;
  }
  SelectObj.options[0].text = "New Purpose";
  SelectObj.options[0].value = "";   // can I set xref=XXX here?
  SelectObj.selectedIndex = 0;

  MerchantType = "location";
  parent.contents.setListWithPers(document.forms[0].locationname, parent.contents.getLocations("1"),MerchantType);
  parent.contents.setDefaultDate(document.forms[0].begdate,-2);
  parent.contents.setDefaultDate(document.forms[0].enddate,-1);
  document.forms[0].xref.value = "XXX";
  parent.contents.setTransaction(document.forms[0]);
  document.forms[0].begdate.focus();
}

function populateClient() { 
  document.forms[0].client.value = document.forms[0].clientno.options[document.forms[0].clientno.selectedIndex].value;
}   
          
var dupFlagOK = true;
function SubmitRec() {
 if (dupFlagOK) {
  dupFlagOK = false;
  if (document.forms[0].xref.value.length == 0) document.forms[0].xref.value = "XXX";
  var projx = parent.contents.rtrim(document.forms[0].project.value);
  if (doDateCheck(document.forms[0].begdate.value, document.forms[0].enddate.value) 
      && checkdate(document.forms[0].begdate)
      && checkdate(document.forms[0].enddate)
      && checkPurpComment(document.forms[0].comment)
      && (projx.length == 0 || checkProject(projx))) {  
     
     var x = document.forms[0].comment.value;
     var regexp = /&/g ;
     x = x.replace(regexp,"+");
     document.forms[0].comment.value = x; 

    if (document.forms[0].xref.value == "XXX") document.forms[0].xref.value = "" + parent.contents.NextXref();

    parent.contents.UpdateReport('1','head2a'); 
// update purpose references etc. here
    document.forms[1].xref.value = document.forms[0].xref.value;
    var index = document.forms[0].this_purpose.selectedIndex - 1;
    if (index > -1) {
      document.forms[1].purpose.value = parent.contents.getStringFmHead(index);
    } else {
      document.forms[1].purpose.value = parent.contents.getStringFmHead(parent.contents.HeadList.length - 1);
      
    }
    dupFlagOK = true;
    document.forms[1].submit();
  }
  dupFlagOK = true;
 }
}

function checkPurpComment(object) {
        check = parent.contents.alltrim(object.value);
        if (check.length > 9) {
                return true;
        } else
        alert("Need to supply a purpose of at least 10 characters");
        object.focus();
        object.select();
        return false;
}

function checkProject(x) {
  return parent.contents.checkProject(x);
}

function checkClientNo(x) {
  return parent.contents.checkClientNo(x);
}

function cPurposeLoad() {
  var index = document.forms[0].this_purpose.selectedIndex - 1
  if (index > -1) {
    if (parent.contents.getItemValue(parent.contents.HeadList[index], "multiclient") == "Yes") {
      alert("Not able to process a split-project/client purpose.\n\nAttach to another purpose and then\nedit receipt and set to correct\npurpose as a work around."); 
    } else {
      parent.contents.ListBuffer = parent.contents.HeadList[index][parent.contents.$items$];
      parent.contents.ListIndex = index;
      parent.contents.setTransaction(document.forms[0]);
    }
  } else {
    parent.contents.ListBuffer = new Array();
    parent.contents.setDefaultDate(document.forms[0].begdate,-2);
    parent.contents.setDefaultDate(document.forms[0].enddate,-1);
    document.forms[0].xref.value = "XXX";
    document.forms[0].projectname.selectedIndex = 0;
    document.forms[0].clientLookup.selectedIndex = 0;
    document.forms[0].project.value = "";
    document.forms[0].clientno.value = "";
    document.forms[0].client.value = "";
    document.forms[0].location.selectedIndex = 0;
    document.forms[0].comment.value = "";
    document.forms[0].stepno.selectedIndex = 0;
    parent.contents.setTransaction(document.forms[0]);
    document.forms[0].begdate.focus();
  }
}

function LookupCleanup() {
  document.forms[0].clientLookup.selectedIndex = 0;
}

function populateClient() {
  if (document.forms[0].clientLookup.selectedIndex > -1) {
    document.forms[0].clientno.value = document.forms[0].clientLookup.options[document.forms[0].clientLookup.selectedIndex].value;
    document.forms[0].client.value = document.forms[0].clientLookup.options[document.forms[0].clientLookup.selectedIndex].text;
    var X = parent.contents.getDBSingle(parent.PersDBase,"client","clientno",document.forms[0].clientno.value);
    var Y;
    if (X[0] && X[0].length != null) {
    for (var i = 0; i < X[0].length; i++) {
      Y = X[0][i][0];
      if(Y == "location") {
        document.forms[0].location.value = X[0][i][1];
      }
    }
    }
    document.forms[0].clientLookup.selectedIndex = 0;
  }
}   

function populateLocation() {
  with (document.forms[0]) {
    if (locationname.selectedIndex > -1) {  
      location.value = locationname.options[locationname.selectedIndex].text;
      locationname.selectedIndex = 0;
    }
  }
}

function populateProject() {
  if (document.forms[0].projectname.selectedIndex > -1) {
    document.forms[0].project.value = document.forms[0].projectname.options[document.forms[0].projectname.selectedIndex].value;
    var X = parent.contents.getDBSingle(parent.PersDBase,"file","project",document.forms[0].project.value);
    var Y;
    if (X[0] && X[0].length != null) {
      for (var i = 0; i < X[0].length; i++) {
        Y = X[0][i][0];
        if(Y == "clientno") {
            document.forms[0].clientno.value = X[0][i][1];
            i = X[0].length;
        }
      }
    }
    for (var i = 0; i < document.forms[0].clientLookup.options.length; i++) {
        if (document.forms[0].clientno.value == document.forms[0].clientLookup.options[i].value) {
            document.forms[0].clientLookup.selectedIndex = i;
            populateClient();
            i = document.forms[0].clientLookup.options.length;
        }
    }
    document.forms[0].projectname.selectedIndex = 0;
  }
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
<p><h1> Sorry <%=request.getParameter("email")%>.  There are no credit card receipts for <%=Reporter.getEmailAddress()%> to process.
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


