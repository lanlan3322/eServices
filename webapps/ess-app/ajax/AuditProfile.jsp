<%--
AuditProfile.jsp - Produces AuditProfile.js which contains edit tables
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
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Extract"
     class="ess.EditTables"
     scope="page" />
<jsp:useBean id = "SystemDOM"
     class="ess.AdisoftDOM"
     scope="session" />
<jsp:useBean id = "StatusDOM"
     class="ess.AdisoftDOM" 
     scope="session" />
<jsp:useBean id = "SysTable"
     class="ess.ServerSystemTable"
     scope="page" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />   
     

<% 
Log.println("[000] AuditProfile for: " + PersFile.getName());
Extract.setConnection(PersFile.getConnection());
Extract.setSQLTerminator(PersFile.getSQLTerminator());
Lang.setLanguage(PersFile.getLanguage());
SystemDOM.setConnection(PersFile.getConnection());
SystemDOM.setSQLTerminator(PersFile.getSQLTerminator());

if (!SystemDOM.getDOMProcessed()) {
	SysTable.setConnection(PersFile.getConnection());
	SysTable.setSQLTerminator(PersFile.getSQLTerminator());
    String system_file = SysTable.getSystemString("XMLSYSTEM","C:\\WORK\\"); 
    java.io.File SystemFile = new java.io.File(system_file);
    SystemDOM.setDOM(SystemFile);
    
    StatusDOM.setConnection(PersFile.getConnection());       //?? Need this here
    StatusDOM.setSQLTerminator(PersFile.getSQLTerminator());
     
    String status_file = SysTable.getSystemString("XMLSTATUS","C:\\WORK\\"); 
    java.io.File StatusFile = new java.io.File(status_file);

    StatusDOM.setDOM(StatusFile); 
}

%>       

<%@ include file="SysProfile.jsp" %>

// This is the start of site sub-system specific routines

function getAuditEdit() { 
   return true;
}

function getEditable() {
  var r = true;
  var x = getNameValue(Header,"editable");
  if (x.toUpperCase() == "NO") r = false;
  return r;
}

function getHeadEditHTML(x) {
  return "reportHeader.html";
}

function getPurposeHTML(x) {
  return "headGen.html";
}

function getExtraHTML(whichHTML) {
  return "";
}

function getFieldName(x) {
  if (x.toUpperCase() == "LOCATION") x = "Manager";
  return x;
}

function getList4Head() {
  //[x,y] where x = field name and y = substring length, 0 means all
  var x = [["PURPOSE",0],["BEG_DATE",0],["END_DATE",0],["COMMENT",15]];  
  return x;
}

function getHLTagName() {
  return "purpose";
}

function getTLTagName() {
  return "receipt";
}

function ListRepHeader() {
  ListHeader("Voucher #", getNameValue(Header,"VOUCHER")); 
  ListHeader("Status", statusTranslate(getNameValue(Header,"RP_STAT")));
  ListHeader("Personnel Number", dispPersNo(getNameValue(Header,"PERS_NUM")),"javascript:void parent.contents.TransWindow('" + defaultHead + getHeadEditHTML() + "')");
  ListHeader("Name", getNameValue(Header,"NAME"));  
  ListHeader("Phone", getNameValue(Header,"PHONE"));
  ListHeader(getFieldName("Location"), getNameValue(Header,"LOCATION"));
  ListHeader("Bill to Department", getNameValue(Header,"DEPART"));
  ListHeader("Create Date", getNameValue(Header,"CRE_DATE"));
  ListHeader("Input by", dispPersNo(getNameValue(Header,"CLERK")));
  if (rtrim(getNameValue(Header,"COMMENT")) != "") ListHeader("Comment", getNameValue(Header,"COMMENT"));

}

function setTotalValues() {
  var Sum1 = getTotalValueFor(TailList,'AMOUNT');
  var Sum2 = getTotalValueFor(TailList,'AMOUNT','CHARGE',getReimburseReq());
  Sum2 = Sum2 - getTotalSubListValue(TailList,'expenselist','AMOUNT','EXPENSE',getPersonalReq());
  var Sum3 = getTotalValueFor(TailList,'AMOUNT','CHARGE',getAdvanceReq());
  var Sum4 = getTotalValueFor(TailList,'AMOUNT','CHARGE',getReturnedReq());  
  var Sum5 = Sum2 + Sum4 - Sum3;
  var Sum6 = Sum1 - (Sum4 + Sum3);
  setNameValue(Header,"RC_AMT",format(Sum6.toString(10),2));
  setNameValue(Header,"RE_AMT",format(Sum5.toString(10),2));
  setNameValue(Header,"AD_AMT", format(Sum3.toString(10),2));
  var regexp = /'/g ;
  var processStr = getNameValue(parent.contents.Header, "COMMENT"); 
  processStr = processStr.replace(regexp,"");
  regexp = /\n/g ;
  processStr = processStr.replace(regexp," ");
  regexp = /\r/g ;
  processStr = processStr.replace(regexp,"");
  if (processStr.length > 60) processStr = processStr.substring(0,60);   //jh 2003-5-2
  setNameValue(Header,"COMMENT", processStr);
}

function setRepTotals() {
  var Sum1 = getTotalValueFor(TailList,'AMOUNT');
  ListHeader("Total Report", format(Sum1.toString(10),2));
  var Sum2 = getTotalValueFor(TailList,'AMOUNT','CHARGE',getReimburseReq());
  Sum2 = Sum2 - getTotalSubListValue(TailList,'expenselist','AMOUNT','EXPENSE',getPersonalReq());
  ListHeader("Reimbursables", format(Sum2.toString(10),2));
  var Sum3 = getTotalValueFor(TailList,'AMOUNT','CHARGE',getAdvanceReq());
  ListHeader("Advances", format(Sum3.toString(10),2));
  var Sum4 = getTotalValueFor(TailList,'AMOUNT','CHARGE',getReturnedReq());
  ListHeader("Returned Funds", format(Sum4.toString(10),2));
  var Sum5 = Sum2 + Sum4 - Sum3;
  ListHeader("Amount Due", format(Sum5.toString(10),2));
// This next part is customized to initiate the checking of the receipted box
  var receipted;
  for (var i = 0; i < TailList.length; i++) {
    receipted = getItemValue(TailList[i],"CHECK");
    if (receipted == "Yes") {
      parent.main.document.forms[0].elements["RECEIPT" + i].checked = true;
    }
  }
}

function getListDisplay(x) {
  var xStr = [1,2,3];
  if (x == "expenselist") {
     xStr = ["EXP_DATE","EXPENSE","AMOUNT","PURPOSE"];
  }
  return xStr; 
}

function getHLTitles() {
  var c1 = new TransCell("c1","Ref");
  var c2 = new TransCell("c2","Beg Date");
  var c3 = new TransCell("c3","End Date");
  var c4 = new TransCell("c4","Detail");
  var Titles = new ListItem("title",[c1,c2,c3,c4]);
  return Titles;
}
function getHLPrint() {
  var ThisList = ["PURPOSE","BEG_DATE","END_DATE","LOCATION","COMMENT","CLIENT","CLIENTNO","$Project:","PROJECT"];
  return ThisList;
}

function getHLSubLines() {
  var ThisList = Array();
  return ThisList;
}

function getTLTitles() {
  var c1 = new TransCell("c1","Receipt<br>OK");
  var c2 = new TransCell("c2","Date");
  var c3 = new TransCell("c3","Amount");
  var c4 = new TransCell("c4","Detail");
  var Titles = new ListItem("title",[c1,c2,c3,c4]);
  return Titles;
}
function getTLPrint() {
  var ThisList = ["$<input type='checkbox' name='RECEIPT$index$' value='$index$' onClick = 'parent.contents.setCheckBox(this,parent.contents.TailList,$index$,\"CHECK\")'>","REC_DATE","AMOUNT","CHARGE","$Receipt #:","RECEIPT"];
  return ThisList;
}

function getTLSubLines() {
  var ThisList = [["expenselist","EXPENSE","AMOUNT","COMMENT"]];
  return ThisList;
}

function getHLFormat() {
  var ThisList = ["","","",""];
  return ThisList;
}
function getTLFormat() {
  var ThisList = ["","align=\"right\"","",""];
  return ThisList;
}

//The functions check a specific code for applicability or return a default value

function getMileageReadOnly() {
 return true;
}

function getAllowNegative() {
 return true;
}

function getRequiredItem(xFld) {
  retVal = false;
  if(xFld.toLowerCase() == "title") retVal = true;
  return retVal;
}

//These functions return list, which are generally used for selection purposes

//These are billing control functions

function companyBillCheck(x,y,z) {  //BillCheck
  var retVal = true;
  switch (x) {
   case "trans1" :
     var b;
     if (z < HeadList.length) {
       b = getItemValue(HeadList[z],"billtype");
       if (b.toUpperCase() == "NO" && y.options[y.selectedIndex].value.toUpperCase() == "YES") {      //.test????
         alert("Cannot bill this item - Client billable specified in purpose is set to 'No'");
         y.focus();
         return false;
       }
     }
     break;
  }
  return retVal; 
}
function companyBillLoad(x,y,z) {
  if (z < HeadList.length) {
  switch (x) {
   case "trans1" :
     var b = getItemValue(HeadList[z],"billtype");
     setListDefault(y,b);
     break;
  } 
  }
}

function checkProject(x) {
 if (x == null) x = "";
 x = parent.contents.alltrim(x);
 if (x.length == 0 || x.length >= 4) {
   return true;
 } else {
   alert("Acct/Project # must be 4 or more characters");
   return false;
 }
}

function checkClientNo(x) {
 if (x.length < 17) {
   return true;
 } else {
   alert("Client number cannot be greater than 16 characters");
   return false;
 }
}


<% 
String[] elementFilter1 = {"translation","screen"};
%>
var statusTable = <%= Extract.getDOMResultSet(StatusDOM,"default",elementFilter1) %>;
function statusTranslate(status)
{
  return getDBResult(statusTable, status);
}
function getStatusTable() {
  return statusTable;
}
<% 
String[] elementFilter2 = {"status"};
%>
var statusList = <%= Extract.getDOMSingle(StatusDOM,"default",elementFilter2) %>;
function getStati() {
 return statusList;
}

function getRoutingNames() {
  var x = <%= Extract.getDOMChildNames(StatusDOM) %>;
  return x;
}
// End of JS File

<% Extract.close(); %>