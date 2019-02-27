
// UploadSelect.jsp - Specifies which file to import 
// Copyright (C) 2006 R. James Holton

// This program is free software; you can redistribute it and/or modify it 
// under the terms of the GNU General Public License as published by the 
// Free Software Foundation; either version 2 of the License, or (at your option) 
// any later version.  This program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
// Public License for more details.

// You should have received a copy of the GNU General Public License along with 
// this program; if not, write to the Free Software Foundation, Inc., 
// 675 Mass Ave, Cambridge, MA 02139, USA. 


function initForm() {
	document.forms[formStartNumber].action = parent.defaultApps + "ajax/receipts/Upload.jsp";
	Log.println("initForm", "Receipt screen with: " + parent.myESSMenu.voucher);
	displayScans();
}

function initUploadFields() {
  document.forms[formStartNumber].scanComment.value = "";
  document.forms[formStartNumber].filename.value = "";
}

function displayScans() {
  parent.myESSMenu.voucher = document.forms[formStartNumber].pvoucher.value;  //JH 8-jul-2013 + all constructPVoucher calls
  displayRemoveScans();
  displayEmailScans();
}

function displayRemoveScans() {
  getRemoveFiles(contructPVoucher(document.forms[formStartNumber].pvoucher.value));
}
function displayEmailScans() {
  getRemoveEmailFiles(contructPVoucher(document.forms[formStartNumber].pvoucher.value));
}

function checkInput() {
  return true;
}

function getRemoveFiles(x) {
   if (x == null) x = contructPVoucher(parent.myESSMenu.voucher);
   var ParamString = "?pvoucher=" + x;
   document.getElementById("scanFiles").innerHTML = "<b><i>" + getJSX("REC_UPL_SEARCH") + "...</i></b>"; 
   loadHTMLAJAX(ParamString);
}   
  
function selectRemoveFiles() {
   getRemoveFiles(contructPVoucher(document.forms[formStartNumber].pvoucher.value))
}
function getRemoveEmailFiles(x) {
   if (x == null) x = contructPVoucher(parent.myESSMenu.voucher);
   var ParamString = "?pvoucher=" + x;
   document.getElementById("emailScans").innerHTML = "<b><i>" + getJSX("REC_UPL_SEARCH") + "...</i></b>"; 
   loadEMAILAJAX(ParamString);
}   
  
function selectRemoveEmailFiles() {
   getRemoveEmailFiles(document.forms[formStartNumber].pvoucher.value)
}

//AJAX stuff below here
var uploadEmailObj;
function loadEMAILAJAX(params) {
  uploadEmailObj = GetXmlHttpObject();
  var LoadJSP = parent.appServer + "/" + parent.appFolder + "/ajax/receipts/EmailScans.jsp" + params + "&force=" + Math.random();
  getInfo(uploadEmailObj, LoadJSP, uploadEmailStateChanged, true);
}

function uploadEmailStateChanged() {
  var x = uploadEmailObj.readyState;
  if ( x == 4 )
  { 
       var newHTML = uploadEmailObj.responseText;
       document.getElementById("emailScans").innerHTML = newHTML;
       // var y = setTimeout("selectRemoveFiles()",3000);
  }
}

var uploadXMLObj;
function loadHTMLAJAX(params) {
  uploadXMLObj = GetXmlHttpObject();
  var LoadJSP = parent.appServer + "/" + parent.appFolder + "/ajax/receipts/ReceiptScans.jsp" + params + "&force=" + Math.random();
  getInfo(uploadXMLObj, LoadJSP, uploadStateChanged, true);
}

function uploadStateChanged() {
  var x = uploadXMLObj.readyState;
  if ( x == 4 )
  { 
       var newHTML = uploadXMLObj.responseText;
       document.getElementById("scanFiles").innerHTML = newHTML;
       // var y = setTimeout("selectRemoveFiles()",3000);
  }
}

//AJAX functions for communicating with the server 1/29/2008
// xmlHttp -> HTTP Request Object, define globally in calling object/script (i.e., var xmlHttp;)
// url -> url to execute (i.e., var url="/ess-app/AJAXTest.jsp";)
// stateChanged -> name of routine to run
// aSync -> true runs asynchronously (i.e., parallel), false run serially

// function getInfo(xmlHttp, url, stateChanged, aSync) - see XReport.jsp
// function GetXmlHttpObject() - see XReport.jsp

function startUpload(){
    if (checkInput()) {
      return true;
    } else {
      return false;
    }
}

var scanRemoveObj;
function removeScanAJAX(removeJSP) {
  scanRemoveObj = GetXmlHttpObject();
  getInfo(scanRemoveObj, removeJSP, removeScanMessage, true);
}

function removeScanMessage() {
  var x = scanRemoveObj.readyState;
  if ( x == 4 )
  { 
       var newHTML = scanRemoveObj.responseText;
       document.getElementById("scanFiles").innerHTML = newHTML;
       var y = setTimeout("selectRemoveFiles()",3000);
  }
}

// Email scan handling
// Getting the list of scans
var emailScansObj;
function getEmailScans(x) {
   if (x == null) x = contructPVoucher(parent.myESSMenu.voucher);
   emailScansObj = GetXmlHttpObject();
   var ParamString = "?pvoucher=" + x;
   document.getElementById("emailScans").innerHTML = "<b><i>" + getJSX("REC_EMAIL_SCANS") + "...</i></b>"; 
   Log.println("Initializing the emailScansObj", "getEmailScans");
   var LoadJSP = parent.appServer + "/" + parent.appFolder + "/ajax/receipts/EmailScans.jsp" + ParamString + "&force=" + Math.random();
   getInfo(emailScansObj, LoadJSP, showEmailScansMessage, true);
} 

// Deleting a scan - the removeEmailScanJSP will come from the EmailScans.jsp - it "deletes" an email scan file
function removeEmailScanAJAX(removeEmailScanJSP) {
  emailScansObj = GetXmlHttpObject();
  getInfo(emailScansObj, removeEmailScanJSP + "&force=" + Math.random(), showEmailScansMessage, true);
}
// Attach a scan - the attachEmailScanJSP will come from the EmailScans.jsp - it attaches a email scan to a report in the scan file
function applyEmailScanAJAX(applyEmailScanJSP) {
  emailScansObj = GetXmlHttpObject();
  getInfo(emailScansObj, applyEmailScanJSP + "&force=" + Math.random(), showBothScansMessage, true);
}
//
function showEmailScansMessage() {
  var x = emailScansObj.readyState;
  if ( x == 4 )
  { 
       var newHTML = emailScansObj.responseText;
       document.getElementById("emailScans").innerHTML = newHTML;
       var y = setTimeout("selectRemoveEmailFiles()",3000);
  }
}

function showBothScansMessage() {
  var x = emailScansObj.readyState;
  if ( x == 4 )
  { 
       var newHTML = emailScansObj.responseText;
       document.getElementById("emailScans").innerHTML = newHTML;
       var y = setTimeout("displayScans()",3000);
  }
}

function screenLoad() {
   initForm();
   return true;
}

function screenUnload() {
   return true;
}   




