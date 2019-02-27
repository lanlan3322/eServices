<%--
Company.jsp - common edit data for a site
For MySQL
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

//This is system/site shared but sub-system specific code


//Company.jsp contains the site shared items for profile generation
//Used by ESSProfile.jsp and AuditProfile.jsp
//Copyright 2003, Adisoft, Inc. All rights reserved.

function getAppServer() {
  return "<%= SystemDOM.getDOMTableValueFor("configuration","appserver","http://localhost:8080") %>";
}
function getWebServer() {
  return "<%= SystemDOM.getDOMTableValueFor("configuration","webserver","http://localhost:8080") %>";
}
function getCustomFolder() {
  return "<%= SystemDOM.getDOMTableValueFor("configuration","customfolder","ess") %>";
}
function getAppFolder() {
  return "<%= SystemDOM.getDOMTableValueFor("configuration","appfolder","ess-app") %>";
}
function getWebFolder() {
  return "<%= SystemDOM.getDOMTableValueFor("configuration","webfolder","ess") %>";
}
function getDatabase() {
  return "<%= SystemDOM.getDOMTableValueFor("configuration","centraldatabase","jdbc:odbc:adisoft") %>";
}

function getDefaultLimit() {
  return <%= SystemDOM.getDOMTableValueFor("configuration","transactionlimit","10000") %>;
}

//The functions check a specific code for applicability or return a default value
function getLodgingDef(WhichList) {
  return "<%= SystemDOM.getDOMTableValueFor("process","lodging","ROOM") %>";
}

function getLodgingExc() {
//This is a comment
  return <%= Extract.getRequired("SELECT EXPENSE FROM ACCOUNT WHERE UPPER(RTRIM(SPECIAL)) <> 'HOTEL'") %>;
}

function getExclude(x) {
  retVal = "";
  if (x == "split") {
    retVal = <%= Extract.getRequired("SELECT EXPENSE FROM ACCOUNT WHERE UPPER(RTRIM(SPECIAL)) = 'NOSPLIT'") %>;
  }
  return retVal;
}

function getInclude(x) {
  retVal = [];
  if (x == "hotel") {
    retVal = <%= Extract.getSingle("SELECT EXPENSE FROM ACCOUNT WHERE NOT SHOW1 AND NOT SHOW2 AND NOT SHOW3 AND NOT SHOW4 AND UPPER(RTRIM(SPECIAL)) = 'HOTEL' ORDER BY EXPENSE ASC", false) %>;  
  }
  return retVal;
}



function getChargeDef() {  
 return "<%= SystemDOM.getDOMTableValueFor("process","defaultpayment","CASH") %>";
}

function getAdvanceDef() {
 return "<%= SystemDOM.getDOMTableValueFor("process","advance","ADVANCE") %>";
}

function getPersonalDef() {
 return "<%= SystemDOM.getDOMTableValueFor("process","personal","PERSONAL") %>";
}

function getReturnedDef() {
 return "<%= SystemDOM.getDOMTableValueFor("process","returned","CASH-RETD") %>";
} 

function getFleetDef() {
 return "<%= SystemDOM.getDOMTableValueFor("process","fleetallowance","ALLOWANCE") %>";
} 

function getDefault(x) {
 retVal = "";
 if (x == "combine2.stepno") retVal = "None";
 if (x == "head2a.stepno") retVal = "Commercial";
 if (x == "head2b.stepno") retVal = "Commercial";
 return retVal;
}

function getMileageDefault(curDate) {
 if (curDate == null) curDate = getDBValue(parent.Header,"credate");
 var MList = <%= Extract.getElementArray(SystemDOM,"mileage") %>;
 var defRate = "0.00";
 if (parseFloat(parent.Mileage) <= 0) {
   var x = applyThisDate(MList, "effective", curDate, "value");
   if (x != null) defRate = x;
 } else {
   defRate = parent.Mileage;
 }
 return defRate;
}
function applyThisDate(y, dateName, curDate, retVal) {
 var x = new Date(curDate);
 //y = the array list;
 var z;            // will hold single item 
 var sDate;        // date from array
 var sValue;       // value from array
 var n1 = -1;      // value we're shooting for
 var n2 = 0;       // working difference between 2 dates              
 for (var i = 0; i < y.length; i++) {
    z = y[i][1]; //get first array
    sDate = new Date(getDBValue(z,"effective"));
    n2 = x - sDate; 
    if (n2 >= 0 && (n2 < n1 || n1 < 0)) {
      n1 = n2;
      sValue = getDBValue(z,"value");
    } 
 } 
 return sValue;
}

function getMileageType() {
 return "<%= SystemDOM.getDOMTableValueFor("process","defaultmileage","MILEAGE") %>";
}

function getMerchantReq() {
  return <%= Extract.getRequired("SELECT EXPENSE FROM ACCOUNT WHERE MERCHANT") %>;
}

function getCommentReq() {
  return <%= Extract.getRequired("SELECT EXPENSE FROM ACCOUNT WHERE XEXPLAIN") %>;
}

function getCommentLen() {
  return 10;
}

function getAttendeeReq() {
  return <%= Extract.getRequired("SELECT EXPENSE FROM ACCOUNT WHERE ATTENDEE") %>;
}

function getReimburseReq() {
  return <%= Extract.getRequired("SELECT CHARGE FROM CHARGE WHERE REIMB")%>;
}

function getAdvanceReq() {
  return "<%= Extract.getCheckListFromArray(SystemDOM.getDOMTableArrayFor("process","advance")) %>";
}

function getPersonalReq() {
  return "<%= Extract.getCheckListFromArray(SystemDOM.getDOMTableArrayFor("process","personal")) %>";
}

function getReturnedReq() {
  return "<%= Extract.getCheckListFromArray(SystemDOM.getDOMTableArrayFor("process","returned")) %>";
}  


//These functions return list, which are generally used for selection purposes
function getExpenseTypes( WhichList) {
 var ThisList;
 switch (WhichList) {
   case "1" :
     //GENERAL EXPENSE LIST
     ThisList = <%= Extract.getSingle("SELECT EXPENSE FROM ACCOUNT WHERE XSHOW AND SHOW1 ORDER BY SHOWLIST ASC, EXPENSE ASC") %>;  
     break;
   case "2" :
     ThisList = <%= Extract.getSingle("SELECT EXPENSE FROM ACCOUNT WHERE XSHOW AND SHOW2 ORDER BY SHOWLIST ASC, EXPENSE ASC") %>;  
     break;
   case "3" :
     ThisList = <%= Extract.getSingle("SELECT EXPENSE FROM ACCOUNT WHERE XSHOW AND SHOW3 ORDER BY SHOWLIST ASC, EXPENSE ASC") %>;  
     break;
   case "4" :
     ThisList = <%= Extract.getSingle("SELECT EXPENSE FROM ACCOUNT WHERE SHOW4 ORDER BY SHOWLIST ASC, EXPENSE ASC") %>;  
     break;
 }
 return ThisList;
}

//These functions return list, which are generally used for selection purposes
function getExpense4Trvl( WhichList) {
 var ThisList = "";
 return ThisList;
}

function getDedicatedMethod(WhichList) {
 var ThisList;
 switch (WhichList) {
   case "1" :
     ThisList = <%= Extract.getNameValue("SELECT EXPENSE, CHARGE FROM ACCOUNT WHERE CHARGE > '' ") %>;
     break;
 }
 return ThisList;
}
function getPaymentTypes( WhichList) {
 var ThisList;
 switch (WhichList) {
   case "1" :
     //GENERAL LIST
     ThisList = <%= Extract.getSingle("SELECT CHARGE FROM CHARGE WHERE XSHOW ORDER BY SHOWLIST, CHARGE ASC") %>;
     break;
   case "2" :
     //USE FOR THE Audit Module
     ThisList = <%= Extract.getSingle("SELECT CHARGE FROM CHARGE ORDER BY SHOWLIST, CHARGE ASC") %>;
     break;
   case "3" :
     //USE FOR HOTEL BILL
     ThisList = ["CASH","PREPAID"];
     break;
   case "4" :
     ThisList = ["CASH","PREPAID"];
     break;
 }
 return ThisList;
}

function getProjectNos(WhichList) {
 var ThisList;
 switch (WhichList) {
   case "1" :
     ThisList = <%= Extract.getNameValue("SELECT PROJECT, TITLE FROM PROJECT") %>;
     break;
 }
 return ThisList;
}

function getBillableLabel() {
 return "<%= SystemDOM.getDOMTableValueFor("configuration","billable_name","Billable") %>";
}

function getStepName() {
 return "<%= SystemDOM.getDOMTableValueFor("configuration","step_display","Pre-approved") %>";
}
function getStepNos(WhichList) {
 var ThisList;
 switch (WhichList) {
   case "1" :
     // ThisList = ["","0004","0005","0006","0007","0008","0009","0010","0011","0012"];
     ThisList = <%= Extract.getElementList(SystemDOM,"steps") %>;
     break;
 }
 return ThisList;
}


function setClientLookup(objLookup) {
  setListWValueWPers(objLookup, getClientNos("2"),"client","client","clientno");
}

function getClientNos(WhichList) {
 var ThisList;
 switch (WhichList) {
   case "1" :
     ThisList = <%= Extract.getNameValue("SELECT CLIENTNO, CLIENT FROM CLIENT WHERE LOCATION <> 'CLOSED' ORDER BY CLIENTNO") %>;
     break;
   case "2" :
     ThisList = <%= Extract.getNameValue("SELECT CLIENT, CLIENTNO FROM CLIENT WHERE LOCATION <> 'CLOSED' ORDER BY CLIENT") %>;
     break;
 }
 return ThisList;
}

function getLocations(WhichList) {
 var ThisList;
 switch (WhichList) {
   case "1" :
     ThisList = <%= Extract.getSingle("SELECT LOCATION FROM LOCATION ORDER BY LOCATION ASC") %>;
     break;
 }
 return ThisList;
}

function getMerchants(WhichList) {
 var ThisList;
 switch (WhichList) {
   case "1" :
     ThisList = <%= Extract.getSingle("SELECT MERCHANT FROM MERCHANT WHERE EXPENSE <> 'LODGING' ORDER BY MERCHANT ASC") %>;
     break;
   case "2" :
     ThisList = [""];
     break;
   case "3" :
     ThisList = [""];
     break;
   case "4" :
     ThisList = <%= Extract.getSingle("SELECT MERCHANT FROM MERCHANT WHERE EXPENSE = 'LODGING' ORDER BY MERCHANT ASC") %>;
     break;
 }
 return ThisList;
}

function getCurrencies() {
 var ThisList = <%= Extract.getSingle("SELECT CURRENCY FROM CURRENCY ORDER BY SHOWLIST ASC, CURRENCY ASC") %>;
 return ThisList;
}

function getTransLimits() {
// Limits correspond to curreny list above - significant to the top of the list
// Used to check input
 var ThisList = <%= Extract.getSingleNoQuotes("SELECT XLIMIT FROM CURRENCY ORDER BY SHOWLIST ASC, CURRENCY ASC") %>;
 return ThisList;
}

function getHomeCurrency() {
  return "<%= SystemDOM.getDOMTableValueFor("configuration","currency","US Dollar") %>";
}

function getHomeCurrencyList() {
 var ThisList = ";;<%= SystemDOM.getDOMTableValueFor("configuration","currency","US Dollar") %>;Local Currency;";
 return ThisList;
}
function getDistanceUnit() {
  return "<%= SystemDOM.getDOMTableValueFor("configuration","distance","Mile") %>";
}

function getGuidelineGroups() {
 var ThisList;
 ThisList = <%= Extract.getSingle("SELECT DISTINCT GUIDE FROM GUIDE ORDER BY GUIDE DESC") %>;
 return ThisList;
}

function getGuideCategories() {
 var ThisList;
 ThisList = <%= Extract.getSingle("SELECT DISTINCT CATEGORY FROM GUIDE ORDER BY CATEGORY DESC") %>;
 return ThisList;
}

function getCompanies() {
 var ThisList;
 ThisList = <%= Extract.getSingle("SELECT COMPANY FROM COMPANY ORDER BY COMPANY") %>;
 return ThisList;
}
function getEntities( WhichList) {  //This seems duplicate a bit from above
 var ThisList;
 switch (WhichList) {
   case "1" :
     ThisList = <%= Extract.getNameValue("SELECT COMPANY, DESCRIP FROM COMPANY WHERE DESCRIP <> '' ORDER BY COMPANY ASC", true) %>; 
     break;
   case "2" :
     ThisList = <%= Extract.getNameValue("SELECT COMPANY, DESCRIP FROM COMPANY WHERE DESCRIP <> '' ORDER BY DESCRIP ASC", true) %>; 
     break;
   
 }
 return ThisList;
}

function getDeparts(WhichList) {
 var ThisList;

 switch (WhichList) {
   case "1" :
     ThisList = <%= Extract.getNameValue("SELECT DEPART, DESCRIP FROM DEPART WHERE GUIDE <> 'CLOSED' AND LOC_CODE <> 'CLOSED'") %>;
     break;
 }
 return ThisList;
}

//These are billing control functions
var BillXArray = [["1","Yes"],["2","No"],["3","Personal"]];
function getBillXlate(x) {
    return getNameValue(BillXArray, x);
}



// Do not make changes below this point 
