// attendee.js - source for adding attendees to a receipt 
// Copyright (C) 2004 R. James Holton

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

var AttendList;
var AttendPerSplit;
var AttendRequired = false;
var AttendScreen = 2;

function initAttendeeList(xList, xPerSplit, xExpenseType, xScreen) {
  if (xScreen == null) xScreen = 3;  //for XReport
  AttendScreen = xScreen;  //see attendee3a.html
  if (xExpenseType == null) xExpenseType = document.forms[0].expense_1_expensetype;
  var Xstr = ""; 
  if (parent.getAttendeeReq) Xstr = parent.getAttendeeReq();
  
  var Xsearch;
  if (typeof(xExpenseType) == "string") {
    var Xsearch = ";" + xExpenseType + ";";
  } else {
    var Xsearch = ";" + xExpenseType.options[xExpenseType.selectedIndex].value + ";";
  }
  if (Xstr.indexOf(Xsearch) > -1 || Xsearch == ";;" ) {
     AttendRequired = true;
  } else {
     AttendRequired = false;
  }
  
  AttendList = xList;

  if (xPerSplit) {
    AttendPerSplit = xPerSplit;
  } else {
    AttendPerSplit = null;
  }
}

function getAttendeeList() {
   return AttendList.value;
}

function setAttendeeList(StringList, PerSplit) {

   AttendList.value = StringList;
   if (AttendPerSplit != null) AttendPerSplit.value = PerSplit;
//deals with comment required for multi person transaction (above line is true)
   var expName = AttendList.name;
   var hashLocation  = expName.lastIndexOf("_");
   if (hashLocation > -1) {
     expName = expName.substring(0,hashLocation+1) + "comment";
   } else {
     expName = "comment"; 
   } 
   var commentFld = AttendList.form.elements[expName];
   if (commentFld != null && commentFld.value.length < parent.getCommentLen()) {
     if (commentFld.value.length == 0) {
       commentFld.value = getJSX("JS_ATTENDEE");
     } else {
       commentFld.value = commentFld.value + " - " + getJSX("JS_ATTENDEE");
     }  
   }
}

function setPeopleList(listType, keyName, keyValue, arrayString) {
   var x = eval(arrayString);
   parent.setDBPair(parent.PersDBase,listType,x);
}
