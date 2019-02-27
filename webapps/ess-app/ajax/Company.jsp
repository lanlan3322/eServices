<%--
Company.jsp - common edit data for a site for MySQL
Copyright (C) 2004,2008 R. James Holton

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
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Extract"
     class="ess.EditTables" 
     scope="page" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />

<% 

//Need to add logic for being logout - i.e. coming back to a logged out terminal.

Log.println("[000] Company profile for: " + PersFile.getName());
Extract.setConnection(PersFile.getConnection());
Extract.setSQLTerminator(PersFile.getSQLTerminator());
Extract.setLanguage(PersFile.getLanguage());
		
String activeCompany = request.getParameter("company");
if (activeCompany == null || activeCompany == "") {
   activeCompany = PersFile.getCompany();
   Log.println("[000] Company profile using default");
}

String CompanySelect = "COMPANY = '" + activeCompany + "'"; //Later can do some tricky things with OR
Extract.setResultSet("SELECT CLIENT, EXPENSE, PAYMENT, MERCHANT, LOCATION, GUIDE, MILEAGE, PROJECT FROM COMPANY WHERE " + CompanySelect);

String clientSelect = complexSelect(Extract.myResult.getString(1),activeCompany,CompanySelect);  
String expenseSelect = complexSelect(Extract.myResult.getString(2),activeCompany,CompanySelect); 
String paymentSelect = complexSelect(Extract.myResult.getString(3),activeCompany,CompanySelect);
String merchantSelect = complexSelect(Extract.myResult.getString(4),activeCompany,CompanySelect);
String locationSelect = complexSelect(Extract.myResult.getString(5),activeCompany,CompanySelect);
String guideSelect = complexSelect(Extract.myResult.getString(6),activeCompany,CompanySelect);
String mileageSelect = Extract.myResult.getString(7);  //completely replaces
String projectSelect = complexSelect(Extract.myResult.getString(8),activeCompany,CompanySelect);

%>       
//Copyright 2002,2008 R.James Holton, All Rights Reserved

function getReporterPurposeHTML(x) {
  var companyPurpose = "<%= Extract.getUnique("SELECT PURPOSESCREEN FROM COMPANY WHERE " + CompanySelect) %>"; 
  return companyPurpose;
}

function getHotelScreen() {
	return "<%= PersFile.getHotelScreen() %>";
}

function getHomeCurrency() {
  return "<%=  Extract.getUnique("SELECT CURRENCY FROM COMPANY WHERE " + CompanySelect) %>";
}

function getHomeCurrencyList() {
 var ThisList = ";;<%= Extract.getUnique("SELECT CURRENCY FROM COMPANY WHERE " + CompanySelect) %>;Local Currency;";
 return ThisList;
}

function getDistanceUnit() {
   var retVal = parent.MilesType;
   if (retVal == null || retVal == "") retVal = "<%= Extract.getUnique("SELECT UNITS FROM COMPANY WHERE " + CompanySelect) %>";
  return retVal;
}

function getHomeDistanceUnit() {
  return "<%= Extract.getUnique("SELECT UNITS FROM COMPANY WHERE " + CompanySelect) %>";
}

function getDistanceUnitXlation() {
   var retVal = parent.MilesType;
   if (retVal == null || retVal == "") {
        retVal = "<%= Lang.getDataString(Extract.getUnique("SELECT UNITS FROM COMPANY WHERE " + CompanySelect)) %>";
   } else {
        retVal = parent.getJSX(retVal);
   }     
   return retVal;
}

function getHomeDistanceUnitXlation() {
   return "<%= Lang.getDataString(Extract.getUnique("SELECT UNITS FROM COMPANY WHERE " + CompanySelect)) %>";
}

function getActiveCompany()
{
  return "<%= activeCompany %>";
}

function getMileageList() {   //See parent.MList
   var ML = <%= Extract.getMileage(mileageSelect) %>;
   return ML; 
}

function getLodgingExc() {
//This is a comment
  return <%= Extract.getRequired("SELECT DISTINCT EXPENSE FROM ACCOUNT WHERE UPPER(RTRIM(SPECIAL)) <> 'HOTEL' AND " + expenseSelect) %>;
}

function getExclude(x) {
  retVal = "";
  if (x == "split") {
    retVal = <%= Extract.getRequired("SELECT DISTINCT EXPENSE FROM ACCOUNT WHERE UPPER(RTRIM(SPECIAL)) = 'NOSPLIT' AND " + expenseSelect) %>;
  }
  return retVal;
}

function getInclude(x) {
  retVal = [];
  if (x == "hotel") {
    retVal = <%= Extract.getSingle("SELECT DISTINCT EXPENSE FROM ACCOUNT WHERE SHOW1 = 0 AND SHOW2 = 0 AND SHOW3 = 0 AND UPPER(RTRIM(SPECIAL)) = 'HOTEL' AND " + expenseSelect + " ORDER BY EXPENSE ASC", false) %>;  
  }
  return retVal;
}


function getMerchantReq() {
  return <%= Extract.getRequired("SELECT DISTINCT EXPENSE FROM ACCOUNT WHERE MERCHANT = 1 AND " + expenseSelect) %>;
}

function getCommentReq() {
  return <%= Extract.getRequired("SELECT DISTINCT EXPENSE FROM ACCOUNT WHERE XEXPLAIN = 1 AND " + expenseSelect) %>;
}

function getAttendeeReq() {
  return <%= Extract.getRequired("SELECT DISTINCT EXPENSE FROM ACCOUNT WHERE ATTENDEE = 1 AND " + expenseSelect) %>;
}

function getReimburseReq() {
  return <%= Extract.getRequired("SELECT DISTINCT CHARGE FROM CHARGE WHERE REIMB = 1 AND " + paymentSelect)%>;
}


//These functions return list, which are generally used for selection purposes
function getExpenseTypes( WhichList) {
 var ThisList;
 if (WhichList == 5) WhichList = 4;
 switch (WhichList) {
   case "1" :
     //GENERAL EXPENSE LIST
     ThisList = <%= Extract.getSingle("SELECT DISTINCT EXPENSE, SHOWLIST FROM ACCOUNT WHERE XSHOW = 1 AND SHOW1 = 1 AND " + expenseSelect + " ORDER BY SHOWLIST ASC, EXPENSE ASC") %>;  
     break;
   case "2" :
     ThisList = <%= Extract.getSingle("SELECT DISTINCT EXPENSE, SHOWLIST FROM ACCOUNT WHERE XSHOW = 1 AND SHOW2 = 1 AND " + expenseSelect + " ORDER BY SHOWLIST ASC, EXPENSE ASC") %>;  
     break;
   case "3" :
     ThisList = <%= Extract.getSingle("SELECT DISTINCT EXPENSE, SHOWLIST FROM ACCOUNT WHERE XSHOW = 1 AND SHOW3 = 1 AND " + expenseSelect + " ORDER BY SHOWLIST ASC, EXPENSE ASC") %>;  
     break;
   case "4" :
     ThisList = <%= Extract.getSingle("SELECT DISTINCT EXPENSE, SHOWLIST FROM ACCOUNT WHERE SHOW4 = 1 AND " + expenseSelect + " ORDER BY SHOWLIST ASC, EXPENSE ASC") %>;  
     break;
 }
 return ThisList;
}


function getExpense4Trvl() {
 <% if (PersFile.getCategory().equals("5")) { %>
 	var ThisList = <%= Extract.getNameAndTranslation("SELECT DISTINCT EXPENSE, SHOWLIST  FROM ACCOUNT WHERE XSHOW = 1 AND DEPART = '" + PersFile.getDepartment() +"' AND " + expenseSelect) %>;  
 <% } else { %>   
 	var ThisList = <%= Extract.getNameAndTranslation("SELECT DISTINCT EXPENSE, SHOWLIST  FROM ACCOUNT WHERE XSHOW = 1 AND SHOW" + PersFile.getCategory() + " = 1 AND " + expenseSelect) %>;  
  <% } %>
 return ThisList.sort(transArraySort);
}

function getExpense4Hotel( WhichList) {
  <% if (PersFile.getCategory().equals("5")) { %>
 	 var ThisList = <%= Extract.getNameAndTranslation("SELECT DISTINCT EXPENSE, SHOWLIST FROM ACCOUNT WHERE SPECIAL = 'HOTEL' AND DEPART = '" + PersFile.getDepartment() +"' AND " + expenseSelect) %>;  
 <% } else { %>   
     var ThisList = <%= Extract.getNameAndTranslation("SELECT DISTINCT EXPENSE, SHOWLIST FROM ACCOUNT WHERE SPECIAL = 'HOTEL' AND SHOW" + PersFile.getCategory() + " = 1 AND " + expenseSelect  ) %>;  
 <% } %>
 return ThisList.sort(transArraySort);
}

function transArraySort(a,b) {
 var retVal = 0
 if (a[2] < b[2]) retVal = -1;
 else if (a[2] > b[2]) retVal = 1;
 else if (a[1] < b[1]) retVal = -1;
 else if (a[1] > b[1]) retVal = 1;
 return retVal;
}


function getDedicatedMethod(WhichList) {
 var ThisList;
 switch (WhichList) {
   case "1" :
     ThisList = <%= Extract.getNameValue("SELECT EXPENSE, CHARGE FROM ACCOUNT WHERE CHARGE > '' AND " + expenseSelect) %>;
     break;
 }
 return ThisList;
}
function getPaymentTypes( WhichList) {
 var ThisList;
 switch (WhichList) {
   case "1" :
     //GENERAL LIST
     ThisList = <%= Extract.getSingle("SELECT CHARGE FROM CHARGE WHERE XSHOW = 1 AND " + paymentSelect + " ORDER BY SHOWLIST, CHARGE ASC") %>;
     break;
   case "2" :
     //USE FOR THE Audit Module
     ThisList = <%= Extract.getSingle("SELECT CHARGE FROM CHARGE WHERE " + paymentSelect + " ORDER BY SHOWLIST, CHARGE ASC") %>;
     break;
 }
 return ThisList;
}

function getProjectNos(WhichList) {
 var ThisList;
     ThisList = <%= Extract.getList("SELECT PROJECT, TITLE, CLIENTNO FROM PROJECT WHERE " + projectSelect) %>;  
 return ThisList;
}

function getLeaveTypes(WhichList) {
 var ThisList;
     ThisList = <%= Extract.getList("SELECT LEAVE_TYPE FROM LEAVETYPE") %>;  
 return ThisList;
}

function getCatTypes(WhichList) {
 var ThisList;
     ThisList = <%= Extract.getList("SELECT CAT_NAME FROM DB_CATEGORY") %>;  
 return ThisList;
}

function getStorage(WhichList) {
 var ThisList;
     ThisList = <%= Extract.getList("SELECT STORAGE_OWNER FROM DB_STORAGE") %>;  
 return ThisList;
}

function getLeaveHolidays(WhichList) {
 var ThisList;
     ThisList = <%= Extract.getList("SELECT * FROM LEAVEHOLIDAYS WHERE " + CompanySelect) %>;  
 return ThisList;
}

function getLeaveHolidaysSG() {
 var ThisList;
     ThisList = <%= Extract.getList("SELECT * FROM LEAVEHOLIDAYS WHERE COMPANY = '001'") %>;  
 return ThisList;
}

function getLeaveHolidaysMY() {
 var ThisList;
     ThisList = <%= Extract.getList("SELECT * FROM LEAVEHOLIDAYS WHERE COMPANY = '002'") %>;  
 return ThisList;
}

function getUsersName(WhichList) {
 var ThisList;
 ThisList = <%= Extract.getList("SELECT FNAME FROM USER") %>;  
 return ThisList;
}

function setClientLookup(objLookup) {
  setListWValueWPers(objLookup, getClientNos("2"),"client","client","clientno");
}

function getClientNos(WhichList) {
 var ThisList;
 switch (WhichList) {
   case "1" :
     ThisList = <%= Extract.getNameValue("SELECT CLIENTNO, CLIENT FROM CLIENT WHERE LOCATION <> 'CLOSED' AND " + clientSelect + " ORDER BY CLIENTNO") %>;
     break;
   case "2" :
     ThisList = <%= Extract.getNameValue("SELECT CLIENT, CLIENTNO FROM CLIENT WHERE LOCATION <> 'CLOSED' AND " + clientSelect + " ORDER BY CLIENT") %>;
     break;
 }
 return ThisList;
}

function getDepartments(WhichList) {
 var ThisList;
 ThisList = <%= Extract.getNameValue("SELECT DEPART, DESCRIP FROM DEPART WHERE " + CompanySelect + " ORDER BY DEPART") %>;
 return ThisList;
}

function getLocations(WhichList) {
 var ThisList;
 ThisList = <%= Extract.getSingle("SELECT LOCATION, '1'  FROM LOCATION WHERE " + locationSelect + " ORDER BY LOCATION ASC") %>;
 return ThisList;
}

function getLocation4Trvl( WhichList) {
 var ThisList = <%= Extract.getNameAndTranslation("SELECT LOCATION, '1' FROM LOCATION WHERE " + locationSelect + " ORDER BY LOCATION ASC") %>;  
 return ThisList.sort(transArraySort);
}

function getMerchants(WhichList) {
 var ThisList = [""];
 switch (WhichList) {
   case "1" :
     ThisList = <%= Extract.getSingle("SELECT MERCHANT FROM MERCHANT WHERE EXPENSE <> 'LODGING' AND " + merchantSelect + " ORDER BY MERCHANT ASC") %>;
     break;
   case "4" :
     ThisList = <%= Extract.getSingle("SELECT MERCHANT FROM MERCHANT WHERE EXPENSE = 'LODGING' AND " + merchantSelect + " ORDER BY MERCHANT ASC") %>;
     break;
 }
 return ThisList;
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


// End 

<%!
String complexSelect(String targetCompany, String currentCompany, String currentSQL)
{
  if ((targetCompany != null) && (!targetCompany.equals("")) && (!targetCompany.equals(currentCompany))) 
  {
	 currentSQL = "(" + currentSQL + " || COMPANY = '" + targetCompany + "')"; 	
  }
  return currentSQL;
}
%>
