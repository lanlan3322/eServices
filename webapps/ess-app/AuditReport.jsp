
<%--
AuditReport.jsp - displays report for audit
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
<jsp:useBean id = "ESS"
     class="ess.DB2Audit"
     scope="session" />
<jsp:useBean id = "GL"
     class="ess.Guideline"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Sys"
     class="ess.ServerSystemTable"
     scope="page" />
<!-- check on the scope of the ServerSystemTable -->
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Currency"
     class="ess.Currency"
     scope="session" />     
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" /> 
<jsp:useBean id = "Scan"
     class="ess.Scan"
     scope="session" />     
     
<%@ include file="DBAccessInfo.jsp" %>
<%@ include file="SystemInfo.jsp" %>
<%@ include file="NoCaching.jsp" %>
<% 
   String database = request.getParameter("database");
   String reference  = request.getParameter("reference");
   String voucher  = request.getParameter("voucher");
   String status = request.getParameter("status");  // don't really need this JH 2005-12-16
   String reply2 = request.getParameter("email");
   String rcpt2 = request.getParameter("rcpt2");

boolean pFlag = PersFile.setPersInfo(reply2); 
boolean inUse = false;
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
   Sys.setConnection(PersFile.getConnection()); 
   Sys.setSQLTerminator(PersFile.getSQLTerminator()); //JH 2006-3-1

   String NeedPassword = Sys.getSystemString("pwd_approval","yes");

   Log.println("[000] AuditReport.jsp - Auditor: " + reply2); 

   if (!ESS.isSameReport(voucher))
   {
     ESS.setConnection(PersFile.getConnection());
     ESS.setSQLTerminator(PersFile.getSQLTerminator());
     ESS.setUpFiles();
     ESS.setLanguage(PersFile.getLanguage());
     ESS.setDateFormat(PersFile.getDateFormat());
     ESS.setDecimal(PersFile.getDecimal());
     ESS.setSeparator(PersFile.getSeparator());
     ESS.reset();
     ESS.setDenormalizeClient(true);
     ESS.set(voucher);
     ESS.setReportReferenceName("voucher");  //uses ess.properties values
     ESS.setReportInstance();
     PersFile.setReportViewed(ESS.getPreviousNumber());
     Log.println("[000] AuditReport.jsp - (new) Voucher: " + voucher); 
   } else {
     Log.println("[000] AuditReport.jsp - (same) Voucher: " + voucher); 
   }

   //status = ESS.getReportStatus();  //JH 2005-12-16 Need to really test this out because of reset
   Log.println("[000] AuditReport.jsp - Report Status: "  + status); 
   inUse = (Log.isReportInUse(voucher,session.getId()) && !Log.isReportInMyUse(voucher,session.getId()));
   if (inUse) Log.println("[000] AuditReport.jsp - Report in use: "  + voucher); 
   Log.setRemoveReports(session.getId());   
   Log.setAddReport(voucher, session.getId(),PersFile.getName());
   if (!Currency.isAlreadyLoaded()) {
     Currency.setConnection(PersFile.getConnection());
     Currency.setSQLTerminator(PersFile.getSQLTerminator()); 
     Currency.setSQLStrings();
   }

   GL.setConnection(PersFile.getConnection());
   GL.setSQLTerminator(PersFile.getSQLTerminator());
   GL.setLanguage(PersFile.getLanguage());
   GL.setDateFormat(PersFile.getDateFormat());
   GL.setDecimal(PersFile.getDecimal());
   GL.setSeparator(PersFile.getSeparator());
   GL.setSystemTable(Sys); // JH 2006-03-01
   GL.setUpFiles();
   Log.println("[000] AuditReport.jsp set company: " + ESS.getCompany());
   GL.setCompany(ESS.getCompany());

%>
<html>
<head>
<link rel="stylesheet" media="screen" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
<script type="text/javascript">
  if (screen.width < 1024) {
    var link = document.getElementsByTagName( "link" )[ 0 ];
    link.href = "<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense800.css";
  }
</script>
<link rel="stylesheet" media="print" href="<%= PersFile.getWebServer()%>/<%= PersFile.getWebFolder() %>/print.css" type="text/css">
<script>
function setDataType(cValue)
{
    var isDate = new Date(cValue);
    if (isDate == "NaN")
    {
      if (isNaN(cValue))
      {
         cValue = cValue.toUpperCase();
         return cValue;
      }
      else
      {
         var myNum;
         myNum = String.fromCharCode(48 + cValue.length) + cValue;
         return myNum;
      }
    }
    else
    {
      var myDate = new String();
      myDate = isDate.getFullYear() + " " ;
      myDate = myDate + isDate.getMonth() + " ";
      myDate = myDate + isDate.getDate(); + " ";
      myDate = myDate + isDate.getHours(); + " ";
      myDate = myDate + isDate.getMinutes(); + " ";
      myDate = myDate + isDate.getSeconds();
      return myDate ;
    }
}

var innerTextOK = true;  
function getInnerText(obj){ 
  retVal = ""
  if (obj.innerText) { // IE; 
      retVal = obj.innerText; 
  } else { 
    if (obj.textContent) { 
       retVal = obj.textContent; 
    } else { 
      alert("<%= Lang.getString("ERROR_WRONG_BROWSER") %>"); 
      innerTextOK = false;
    }
  }
  return retVal;  
} 


function sortTable(col, tableName)
{
  var tableToSort = document.getElementById(tableName);
  var totalRows = tableToSort.rows.length;
  var colArray = new Array();
  var newRow;
  var newCell;
  var i;
  var c;
  var j;
  var setItem = "";
  innerTextOK = true;
  for (i=1; i < tableToSort.rows.length; i++)
  {
      if (tableToSort.rows[i].id != "extra") { 
         setItem = setDataType(getInnerText(tableToSort.rows[i].cells[col]));  
      }
      colArray.length = i;
      colArray[i - 1] = setItem;
  }

  if (innerTextOK)
  {
    var x = new Array(colArray.length);
    for (i=0; i < colArray.length; i++)
    {
      var y = new Array(2);
      y[0] = colArray[i];
      y[1] = i + 1;
      x[i] = y;
    }
    x = x.sort(compareCol);

    var backcolor = true;  //These are used for alternating a colored line with a white one
    var oldbackcolor = false;
    var newbackcolor = false; 
    var z;

    for (i=0; i<x.length; i++)
    {
      z = x[i][1];                                //jh 1/30/07 
      newRow = tableToSort.insertRow(tableToSort.rows.length);         //added -1 jh 1/30/07
      newRow.id = tableToSort.rows[z].id;         //rows()
      if (newRow.id != "extra")
      {
         newbackcolor = backcolor;
         backcolor = oldbackcolor; 
         oldbackcolor = newbackcolor;
      } 
      for (c=0; c<tableToSort.cols; c++)
      {
          newCell = newRow.insertCell(c);
          newCell.innerHTML = tableToSort.rows[z].cells[c].innerHTML;
          newCell.width = tableToSort.rows[z].cells[c].width;
          newCell.align = tableToSort.rows[z].cells[c].align;
          if (backcolor) {
             newCell.className = "TableData offsetColor";
          } else {
             newCell.className = "TableData";
          }
      }
    }
    //DELETE THE OLD ROWS FROM THE TOP OF THE TABLE ....
    for (i=1; i<totalRows; i++)
    {
       tableToSort.deleteRow(1);
    }
  }
}

function compareCol(a,b) {
    retVal = 0;
    if (a[0] > b[0]) retVal = 1;
    if (a[0] < b[0]) retVal = -1;
    return retVal;
}

</script>
</head>
<body onLoad="initForm()">

<%@ include file="StandardAuditTop.jsp" %>

<!--<%= ESS.printTitle(Lang.getString("auditCopy")) %>-->

<small>

<%= ESS.printHeader() %>
<%
// String homeCurrencyCheck = ";" + SystemDOM.getDOMTableValueFor("configuration","currency","US Dollar") + ";Local Currency;";
// String homeCurrency = SystemDOM.getDOMTableValueFor("configuration","currency","US Dollar");
String homeCurrency = ESS.getHomeCurrency();
String omitguidelines = SystemDOM.getDOMTableValueFor("configuration","omitguidelines","No");
String requireAuditComment = SystemDOM.getDOMTableValueFor("configuration","requireauditcomment","No");
boolean requiredComment = requireAuditComment.equalsIgnoreCase("Yes");
String omitforeignguidelines = SystemDOM.getDOMTableValueFor("configuration","omitforeignguidelines","Yes");
String omitforeignconversion = SystemDOM.getDOMTableValueFor("configuration","omitforeignconversion","No");
String reportCurrency = ESS.getCurrency();

//Call the rate change form here.....
//if (omitforeignconversion.equalsIgnoreCase("No") && !isRateChange(ESS, homeCurrencyCheck))
if (omitforeignconversion.equalsIgnoreCase("No") && !ESS.isHomeCurrency())
{
%>
<%@ include file="RateChangeForm.jsp" %>

<%
}

if (!omitguidelines.equalsIgnoreCase("YES") && (omitforeignguidelines.equalsIgnoreCase("NO") || (ESS.isHomeCurrency()) )) { 
   GL.setReport(voucher);
   Log.println("[000] ApproveReport.jsp - DB2Guide - " + reply2); 

%>
<% if (ESS.isDuplicateReceipts()) { %>
<p><%= Lang.getString("DUPLICATE_RECEIPTS_FOUND","Duplicate Receipts Have Been Found!")%></p>
<% 
   		String duplicates[] = ESS.getDuplicateReceipts();
   		for (int i = 0; i < duplicates.length; i++) 
   		{
   			%> <%= duplicates[i] %>&nbsp;<%= Lang.getString("DUPLICATE_RECEIPT_FOUND","is duplicated on this report")%><br/> <%
   		}
   		%><br/><br/><%
   } else { %>
<p><%= Lang.getString("DUPLICATE_RECEIPTS_NOT_FOUND","No Dups Found")%></p>
<% } %>

<p><big><%= Lang.getString("guidelineTitle") %></big></p>
<small>
<% if (GL.getStatus().equalsIgnoreCase("passed")) { %>
<%= Lang.getStringWithReplace("REPORT_PASSED_GUIDELINE","$guideType$",GL.getGuideType() )%><br><br>
<% } else { %>    
<%= Lang.getStringWithReplace("REPORT_FAILED_GUIDELINE","$guideType$",GL.getGuideType() )%><br><br>
<% } 
   } %>
<%= ESS.printCrossChargeWarning() %>
<%
if (!omitguidelines.equalsIgnoreCase("YES") && (omitforeignguidelines.equalsIgnoreCase("NO") || ( ESS.isHomeCurrency()))) 
  { 
   Log.println("[000] ApproveReport.jsp - Guide - " + reply2); %>
<%= GL.toString() %></small><br>
<% } %>

<%=ESS.printTripByDay() %>
<%=ESS.printFleetItems() %>
<%=ESS.printAdvanceItems() %>

<a name="receiptsSection" />

<form name="Receipts">
<%-- Was ESS.printReceipts(true) --%>
<!--
<%=ESS.printReceiptsByExpense(true) %>
--></form>

<%@ include file="ScanImageList.jsp" %>

<br>
</small>

<br>
<a name="signoffSection" />
<%=ESS.printEApproval() %>
<%
if ((PersFile.isAuditor() || PersFile.isAdmin()) && !PersFile.getPersNum().equals(ESS.getPersNum())) {
%>
<table border="0" cellpadding="2" cellspacing="0" width="90%" class="tableBGColor" style="border: 1px solid"><tr>
<tr><td width="100%">
<form name="Signoff" method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/AuditSave.jsp">
  <input type="hidden" name="email" value>
  <input type="hidden" name="company" value>
  <input type="hidden" name="ccode" value>
  <input type="hidden" name="database" value>
  <input type="hidden" name="voucher" value>
  <input type="hidden" name="reference" value>
  <input type="hidden" name="status" value>
  <input type="hidden" name="action" value>
  <input type="hidden" name="rcpt2" value>
  <input type="hidden" name="reply2" value>
  <input type="hidden" name="receipts" value>
  <input type="hidden" name="checks" value>

<% if (NeedPassword.equalsIgnoreCase("NO"))
   {
%> 
  <input type="hidden" name="password" value="">
<% }
%>

  <table border="0" cellpadding="0" cellspacing="0" width="100%" height="38">
   <tr>
     <td width="40%" align="right"><strong>Action:&nbsp;</strong></td>
     <td width="60%" align="left"><input type="radio" value="result" checked name="actiontype"><em>
     <strong><%= Lang.getString("acceptReport") %></strong></em></td>
   </tr>
   <tr>
     <td width="40%" align="right"><strong></strong></td>
     <td width="60%" align="left"><input type="radio" name="actiontype" value="reject"><em>
     <strong><%= Lang.getString("rejectReport") %></strong></em></td>
   </tr>
   <tr>
     <td width="40%" align="right"><strong></strong></td>
     <td width="60%" align="left"><input type="radio" name="actiontype" value="receiptonly"><em>
     <strong><%= Lang.getString("receiptsOnly") %></strong></em></td>
   </tr>
   <tr>
     <td width="40%" align="right"><strong><%= Lang.getLabel("received") %>&nbsp;</strong></td>
     <td width="60%" align="left"><input type="text" name="received" size="12" onChange="smallDateCheck(document.Signoff.received)">
     <a HREF="javascript:doNothing()" onClick="setDateField(document.Signoff.received,'<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.html');">
     <img SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.gif" BORDER="0" WIDTH="16" HEIGHT="16"> 
     </a><span class="ExpenseTinyLink"><%= Lang.getString("popCal") %></span></td>
   </tr>
   <tr>
     <td width="40%" align="right"><strong><%= Lang.getLabel("message") %>&nbsp;</strong></td>
     <td width="60%" align="left" valign="top"><textarea rows="2" name="msgdata" cols="29"></textarea></td>
   </tr>
   <tr>
     <td width="40%" align="right"><strong><%= Lang.getLabel("approvedBy") %>&nbsp;</strong></td>
     <td width="60%" align="left"><input type="text" name="name" size="20" readOnly=Yes></td>
   </tr>
<% if (!NeedPassword.equalsIgnoreCase("NO"))
   {
%> 
   <tr>
     <td width="40%" align="right"><strong><%= Lang.getLabel("password") %>&nbsp;</strong></td>
     <td width="60%" align="left"><input type="password" name="password" size="13"></td>
   </tr>
<% }
%>
   </table>
   <table border="0" cellpadding="0" cellspacing="0" width="100%" height="38">
   <tr>
   <td width="100%" align="center">
     <input type="button" value="<%= Lang.getString("PROCESS_REPORT") %>" name="B2" onClick="Javascript: void Approve()">
   </td>
   </tr> 
   </table>
</form>
</td></tr>
</table>
<%
}   // if (PersFile.isAuditor()) 
%>
<br>
<small>
<!--
<%=ESS.printAuditInfo() %>
<%=ESS.printExpenseSummary() %>
<%=ESS.printDepartSummary() %>
<%=ESS.printExpenseGrid() %>
<%=ESS.printFleetEntries() %>-->
</small>
<br>

<%@ include file = "ScanImageDisplay.jsp" %>

<%@ include file="StandardAuditBottom.jsp" %>

<form name = "ReportList" method="POST" action="AuditList.jsp">
  <input type="hidden" name="email" value>
  <input type="hidden" name="ccode" value>
  <input type="hidden" name="xaction" value>
  <input type="hidden" name="database" value>
  <input type="hidden" name="begdate" value>
  <input type="hidden" name="enddate" value>
  <input type="hidden" name="downlevel" value>
  <input type="hidden" name="reportclass" value="form">
  <input type="hidden" name="reporttype" value="SELECT * FROM REPORT WHERE">
  <input type="hidden" name="inUse" value="0">
</form>

<form name = "EditItem" method="GET" action="">
  <input type="hidden" name="email" value>
  <input type="hidden" name="ccode" value>
  <input type="hidden" name="tt" value>
  <input type="hidden" name="rr" value>
  <input type="hidden" name="vv" value>
  <input type="hidden" name="sc" value>
</form>

<script LANGUAGE="JavaScript" SRC="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/calendar.js"></script>
<script language="Javascript">

function initForm() {
<%
if ((PersFile.isAuditor() || PersFile.isAdmin()) && !PersFile.getPersNum().equals(ESS.getPersNum())) {
%>

  parent.contents.switchCompany("<%= ESS.getReportCompany() %>");

  document.Signoff.name.value = parent.contents.getDBValue(parent.Header,"name");
  document.Signoff.reference.value = "<%= reference %>";
  document.Signoff.voucher.value = "<%= voucher %>";
  document.Signoff.email.value = parent.contents.getDBValue(parent.Header,"email");
  document.Signoff.company.value = parent.company;
  document.Signoff.ccode.value = parent.CCode;
  document.Signoff.database.value = parent.database;
  document.Signoff.status.value = "<%= ESS.getESSReportStatus() %>";
  document.Signoff.action.value = "result";
  document.Signoff.actiontype[0].checked = true;
  document.Signoff.rcpt2.value = "<%= rcpt2 %>";
  document.Signoff.reply2.value = "<%= reply2 %>";
  document.Signoff.received.value = "<%= ESS.getESSReportReceiptsReceived() %>"; 

  parent.contents.setGeneralLimit("<%= ESS.getCurrency() %>");
  parent.contents.setDBPair(parent.PersDBase,"last_report", "<%= voucher %>");

  if (document.RateChange) {
     document.RateChange.voucher.value = "<%= ESS.getVoucherNumber() %>";
     document.RateChange.email.value = parent.contents.getDBValue(parent.Header,"email");
     document.RateChange.ccode.value = parent.CCode;
     setCurrency(document.RateChange,"<%= ESS.getCurrency() %>");
  }
  initReturn();
  restoreCheckMarks();  //here OK?
<%
  if (inUse) {
%>
  if (document.ReportList.inUse.value == "0") {
     alert("<%= Lang.getString("WARNING_REPORT_IN_USE") %>");
     document.ReportList.inUse.value = "1";
  }
<%
  }
}
%>
//figure something out for reject
}

var submitSafetyFlag = true;
parent.contents.DirectEdit = true;  

function Approve(){
  if (submitSafetyFlag) {
    var xfound = false;
    with (document.Signoff) {
      for (var i = 0; i < actiontype.length; i++) {
        if (actiontype[i].checked == true) {
          action.value = actiontype[i].value;
          xfound = true;
        }
      }

      if (!xfound) {
        alert("<%= Lang.getString("ERROR_NO_ACTION_SELECTED") %>");
      } else if (action.value == "reject") {
<% if (!(PersFile.isAuditor() || PersFile.isAdmin()) || requiredComment) {  %>
        if (msgdata.value.length < 1 ) {
           alert("<%= Lang.getString("ERROR_NO_REJECT_MESSAGE") %>");
           msgdata.focus();
        } else {
<% } %>
           if (confirm("<%= Lang.getString("CONFIRM_REJECT") %>")) {
             submit();
             submitSafetyFlag = false;
           }
<% if (!(PersFile.isAuditor() || PersFile.isAdmin()) || requiredComment) {  %>
        }
<% } %>
      } else if (action.value == "result" || action.value == "receiptonly") {
       <% if (NeedPassword.equalsIgnoreCase("NO")){
       %>
          if (confirm("<%= Lang.getString("CONFIRM_APPROVAL") %>")) {
       <% }
       %>
            var delim = "";
            for (var i = 0; i < document.Receipts.length; i++) {
              // Had this below before:  && document.Receipts.elements[i].checked == true
              // Need to figure out how to detect that a change has taken place to this so that
              // not everything gets sent up all the time.
             if (document.Receipts.elements[i].name == "select_this_receipt" && document.Receipts.elements[i].getAttribute("changed") == "Yes") {
                if (document.Receipts.elements[i].getAttribute("reference") == "") document.Receipts.elements[i].setAttribute("reference","X"); 
                document.Signoff.receipts.value += delim + document.Receipts.elements[i].getAttribute("reference");
                if (document.Receipts.elements[i].checked)
                {
                  document.Signoff.checks.value += delim + "Yes";
                } else {
                  document.Signoff.checks.value += delim + "No";
                }
                delim = ";";   
              }
            }
            //Later put in an optional check for receipts that are required
            //parent.contents.setLastSQL(lastSQL);
            //parent.contents.setLastDisplay(lastDisplay);
            submit();
            submitSafetyFlag = false;
       <% if (NeedPassword.equalsIgnoreCase("NO")){
       %>
          }
       <% }
       %>


      } else {
        alert("action not spcified - contact support!");
      }
    }
    return;
  }
}

function deletePurpose(PurposeRef) {
  if (confirm("Do you want to delete this purpose?")) {
    editScreen("DeleteReportItem.jsp","purpose",PurposeRef);
  }
}

function deleteReceipt(ReceiptRef) {
  if (confirm("Do you want to delete this receipt?")) {
    editScreen("DeleteReportItem.jsp","receipt",ReceiptRef);
  }
}

function editPurpose(PurposeRef) {
    editScreen("GetReportItem.jsp","purpose",PurposeRef);
}

function editReceipt(ReceiptRef) {
    editScreen("GetReportItem.jsp","receipt",ReceiptRef);
}

function editScreen(routine,xType,xReference) {
    parent.contents.BackSpaceToReport = -3;
    document.EditItem.action = "/<%= PersFile.getAppFolder() %>/edit/" + routine;
    document.EditItem.email.value = "<%= PersFile.repStr(reply2,"'","\\'") %>";
    document.EditItem.ccode.value = "<%= CCode%>";
    document.EditItem.vv.value = "<%= voucher%>";
    document.EditItem.tt.value = xType;
    document.EditItem.rr.value = xReference;
    document.EditItem.sc.value = "";
    saveCheckMarks();
    document.EditItem.submit();
}

function newScreen(xType,screenName) {
    parent.contents.BackSpaceToReport = -2;
    document.EditItem.action = "/<%= PersFile.getAppFolder() %>/edit/" + "GetReportItem.jsp";
    document.EditItem.email.value = "<%= PersFile.repStr(reply2,"'","\\'") %>";
    document.EditItem.ccode.value = "<%= CCode%>";
    document.EditItem.vv.value = "<%= voucher%>";
    document.EditItem.tt.value = xType;
    document.EditItem.rr.value = "";
    document.EditItem.sc.value = screenName;
    saveCheckMarks();
    document.EditItem.submit();
}

function saveCheckMarks() {
    parent.CheckMarks = new Array(document.Receipts.length + 2);
    parent.CheckMarks[0] = "<%= ESS.getVoucherNumber() %>";
    parent.CheckMarks[1] = "<%= ESS.getReportInstance() %>";
    for (var i = 0; i < document.Receipts.length; i++) {
        	parent.CheckMarks[i+2] = new Array (document.Receipts.elements[i].getAttribute("reference"),
                                          document.Receipts.elements[i].getAttribute("changed"),
                                          document.Receipts.elements[i].checked);
    }
}

// function saveCheckMarks() {
//    parent.CheckMarks = new Array(document.Receipts.length + 2);
//    parent.CheckMarks[0] = "<%= ESS.getVoucherNumber() %>";
//    parent.CheckMarks[1] = "<%= ESS.getReportInstance() %>";
//    with(document.Receipts) {
//    	for (var i = 0; i < document.Receipts.length; i++) {
//        	parent.CheckMarks[i+2] = new Array (getAttribValue(elements[i],"reference",elements[i].reference),
//                                          getAttribValue(elements[i],"changed",elements[i].changed),
//                                          getAttribValue(elements[i],"checked",elements[i].checked));
//    	}
//    }
//}
//function getAttribValue(eleObj, attribName, attribObj) {
//      retVal = null;
//      if (eleObj.getAttribute) {
//        retVal = eleObj.getAttribute(attribName);
//      } else if (attribObj){
//        retVal = attribObj;
//      } 
//      return retVal;
//}


function restoreCheckMarks () {
    if (parent.CheckMarks 
     && parent.CheckMarks[0] == "<%= ESS.getVoucherNumber() %>" 
     && parent.CheckMarks[1] == "<%= ESS.getReportInstance() %>")
    {
       var CMIndex = -1;
       for (var i = 0; i < document.Receipts.length; i++) {
          CMIndex = findStoredCheck(document.Receipts.elements[i].reference);
          if ((CMIndex != -1) && (parent.CheckMarks[CMIndex][1] == "Yes"))
          {
             document.Receipts.elements[i].setAttribute("changed",parent.CheckMarks[CMIndex][1]);
             document.Receipts.elements[i].setAttribute("checked", parent.CheckMarks[CMIndex][2]);
          }
       }
    }
}

function findStoredCheck(reference) {
  var retVal = -1;
  for (var i = 2; i < parent.CheckMarks.length; i++) {
    if (parent.CheckMarks[i][0] == reference) {
      retVal = i;
      i = parent.CheckMarks.length;
    }
  }
  return retVal;
}
function hasChanged(obj) {
  obj.setAttribute("changed","Yes");
}

var lastDisplay;  //probably no longer need these as separate variables.
var lastSQL;

function initReturn() {
  with (document.ReportList) {
    lastDisplay = parent.contents.getLastDisplay();
    lastSQL = parent.contents.getLastSQL();
    document.ReportList.action = parent.contents.defaultApps + lastDisplay;
    begdate.value = parent.contents.getDBString(parent.PersDBase, "reportBegDate", document.ReportList.begdate.value);
    enddate.value = parent.contents.getDBString(parent.PersDBase, "reportEndDate", document.ReportList.enddate.value);
    downlevel.value = parent.contents.getDBString(parent.PersDBase, "approvallevel", "1");
    email.value = parent.contents.getNameValue(parent.Header, "email");
    database.value = parent.database;
    ccode.value = parent.CCode;
    xaction.value = "List";
    reporttype.value = lastSQL;
    parent.contents.setLastDisplay(lastDisplay);  //jh 2007-08-28
    parent.contents.setLastSQL(lastSQL);          //jh 2007-08-28
  }
}

</script>
</body>
</html>
<% Log.println("[000] AuditReport.jsp - End - " + reply2); %>

<% } else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } %>
<%@ include file="RateChangeBoolean.jsp" %>