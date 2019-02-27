<%--
SysProfile.jsp - common edit data for a site
For MySQL
Copyright (C) 2008 R. James Holton

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

<%
String _appServer = SystemDOM.getDOMTableValueFor("configuration","appserver","http://localhost:8080");
String _appFolder = SystemDOM.getDOMTableValueFor("configuration","appfolder","ess-app");
String _normalizeText = SystemDOM.getDOMTableValueFor("configuration","normalizetext","No");
%>

function switchCompany(newCompany) 
{
   if (newCompany != getActiveCompany())  //see Company.jsp  
   {
     var repScript = document.getElementById("companyScript");
     document.body.removeChild(repScript); 
     var oScript;
     try {
       oScript = document.createElement("script");
       oScript.src = "<%= _appServer %>/<%= _appFolder %>/ajax/Company.jsp";
       oScript.id = "companyScript";
     } catch (e) {
       oScript = document.createElement("<sc"+"ript language=\"Javascript\" id = \"companyScript\" src=\"<%= _appServer %>/<%= _appFolder %>/ajax/Company.jsp?company=" + newCompany + "\"></s"+"cript>");
     }
     document.body.appendChild(oScript);
   }
}


function getAppServer() {
  return "<%= _appServer %>";
}
function getWebServer() {
  return "<%= SystemDOM.getDOMTableValueFor("configuration","webserver","http://localhost:8080") %>";
}
function getCustomFolder() {
  return "<%= SystemDOM.getDOMTableValueFor("configuration","customfolder","ess") %>";
}
function getAppFolder() {
  return "<%= _appFolder %>";
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

function getLodgingTrans(WhichList) {
  return "<%= Lang.getDataString(SystemDOM.getDOMTableValueFor("process","lodging","ROOM")) %>";
}

function getAirDef(WhichList) {
  return "<%= SystemDOM.getDOMTableValueFor("process","airfare","AIRFARE") %>";
}

function getAirTrans(WhichList) {
  return "<%= Lang.getDataString(SystemDOM.getDOMTableValueFor("process","airfare","AIRFARE")) %>";
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
function getCentralCurrency() {
  return "<%= SystemDOM.getDOMTableValueFor("configuration","currency","US Dollar") %>";
}
function getDefaultLocation() {
  return "<%= SystemDOM.getDOMTableValueFor("configuration","location","CAQC") %>";
}
 
function getDefault(x) {
 retVal = "";
 if (x == "combine2.stepno") retVal = "None";
 if (x == "head2a.stepno") retVal = "Commercial";
 if (x == "head2b.stepno") retVal = "Commercial";
 return retVal;
}

function getNormalizeText(x) {
<% if (_normalizeText.equalsIgnoreCase("No")) { %>
   return x;
<% } else { %>
   return x.toUpperCase();
<% } %>
}

function getMileageDefault(curDate, wanted, currency, distancetype) {
 if (curDate == null) curDate = getDBValue(parent.Header,"credate");
 if (wanted == null) wanted = "rate";
 // Need to check for report currency;
 if (currency == null) currency = getNameValue(Header,"currency");
 if (currency == null || currency == "") {
    if (parent.myHeader) {
    	currency = getNameValue(parent.myHeader, "currency");
    } else {
    	currency = getNameValue(parent.Header, "currency");
    }
 }
 if (currency == null || currency == "") currency = getHomeCurrency();
 if (currency == null || currency == "") currency = getCentralCurrency();
 if (distancetype == null || distancetype == "") distancetype = parent.MilesType;
 if (distancetype == null || distancetype == "") distancetype = getDistanceUnit();
 var retVal = "0.00";
 if (wanted == "units") {
   retVal = getDistanceUnit();  //Do I need to move this????
 } else {  // wanted == "rate"
   if (parseFloat(parent.Mileage) <= 0) {
      // var x = applyThis(parent.MList, "effective", curDate, wanted, currency, distancetype);
      var x = applyThis(getMileageList(), "effective", curDate, wanted, currency, distancetype);
      if (x != null) retVal = x;
   } else {
      retVal = parent.Mileage;
   }
 }
 return retVal;
}

function applyThis(y, dateName, curDate, retVal, currency, distancetype) {
 var x; 
 if (typeof getYear == 'function') {  //needed because of new and legacy (frameset) differences
    x = new Date(parseInt(getYear(curDate)), parseInt(getMonth(curDate)) - 1, parseInt(getDate(curDate)));
 } else {
    x = new Date(parseInt(parent.main.getYear(curDate)), parseInt(parent.main.getMonth(curDate)) - 1, parseInt(parent.main.getDate(curDate)));
 }  

 var z;            // will hold single item 
 var sDate;        // date from array
 var sValue;       // value from array
 var sCur;         // value from array for currency
 var sDist         // value from array for mileage type
 var n1 = -1;      // value we're shooting for
 var n2 = 0;       // working difference between 2 dates
 var edate;              
 for (var i = 0; i < y.length; i++) {
    z = y[i][1]; //get first array
    edate = getDBValue(z,"effective");
    sDate = new Date(edate);
    n2 = x - sDate; 
    // original held sCur setting
    if (n2 >= 0 && (n2 < n1 || n1 < 0)) {
      sCur = getDBValue(z,"currency");
      sDist = getDBValue(z,"units");
      if ((sCur == currency) && (sDist == distancetype)) {
      	n1 = n2;
      	sValue = getDBValue(z,retVal);
      }
    } 
 } 
 return sValue;
}


function getMileageType() {
 return "<%= SystemDOM.getDOMTableValueFor("process","defaultmileage","MILEAGE") %>";
}

function getCommentLen() {
  return 2;
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


function getBillableLabel() {
 return "<%= SystemDOM.getDOMTableValueFor("configuration","billable_name","Billable") %>";
}

function getStepName() {
 return "<%= SystemDOM.getDOMTableValueFor("configuration","step_display","Pre-approved") %>";
}
function getStepNos(WhichList) {
 var ThisList = <%= Extract.getElementList(SystemDOM,"steps") %>;
 return ThisList
}

function getEntryScreens(WhichList) {
 var Array1 = [""];
 var Array2 = <%= Extract.getElementList(SystemDOM,"entryscreens") %>;
 var ThisList = Array1.concat(Array2);
 return ThisList
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

//These are billing control functions
var BillXArray = [["1","Yes"],["2","No"],["3","Personal"]];
function getBillXlate(x) {
    return getNameValue(BillXArray, x);
}

function contructPVoucher(x) {
   var alternatePrefix = "<%= SystemDOM.getDOMTableValueFor("configuration","alternateprefix","") %>";
   x = alternatePrefix + x.substring(x.length - (8 - alternatePrefix.length));
   return x;
}


// Do not make changes below this point 
