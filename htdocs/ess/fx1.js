// fx1.js - foreign exhange handling logic
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

var LocalXFldObj;
var FormNumber = 0;
var FgnFldObj;
var FXFormNames = ["units","xrate","ratetype","xdate","xsource","recamt","amount"];

function setLocalObjCurrency(LocalValue) {
   LocalXFldObj.value = LocalValue;
   parent.contents.makeCurrency(LocalXFldObj);
}
function setFgnObjAmount(FgnValue) {
   FgnFldObj.value = FgnValue;
   if (FgnValue != "") parent.contents.makeCurrency(FgnFldObj);
}   
function getFgnObjAmount() {
   return FgnFldObj.value;
}
function setXLocalObj(ThisObj) {
   LocalXFldObj = ThisObj;
}
function setFgnObj(ThisObj) {
   FgnFldObj = ThisObj;
}
function setFGN(FGNArray, xRecamt, yAmount) {
  if (isEmpty(xRecamt)) xRecamt = FXFormNames[5]; //recamt
  if (isEmpty(yAmount)) yAmount = FXFormNames[6]; //amount
  var fgnFlag = true
  for (var i = 0; i < FGNArray.length; i++) {
     document.forms[FormNumber].elements[FGNArray[i][0]].value = FGNArray[i][1];
     if (FGNArray[i][0] == "units" && FGNArray[i][1] == "") {
       fgnFlag = false;
       if (!isEmpty(document.forms[FormNumber].elements[yAmount])) document.forms[FormNumber].elements[yAmount].readOnly = false;
     }
  }
  FXConvert(xRecamt, yAmount, true);
  if (thisForm.elements[FXFormNames[1]].value != "") setFgnProtected(false);
  if (typeof(setMultiExpenseFromFX) == "function") setMultiExpenseFromFX();   //Can I check for the obj here and leave as fx1
}

function setFgnProtected(fgnFlag, xRecamt, yAmount) {
  //true = fgn readonly   false = amount readonly
  if (isEmpty(xRecamt)) xRecamt = FXFormNames[5];  //recamt
  if (isEmpty(yAmount)) yAmount = FXFormNames[6];  //amount
  document.forms[FormNumber].elements[xRecamt].readOnly = fgnFlag;
  document.forms[FormNumber].elements[yAmount].readOnly = !fgnFlag; 
}

function setFgnLocalVars(x,y,xRecamt,yAmount) {
  if (isEmpty(xRecamt)) xRecamt = FXFormNames[5];  //recamt
  if (isEmpty(yAmount)) yAmount = FXFormNames[6];  //amount
  thisForm = document.forms[FormNumber];
  LocalXFldObj = thisForm.elements[yAmount];
  FgnFldObj = thisForm.elements[xRecamt];
  setFgnObj(x);
  setLocalObj(y,"fx1",650,450);
}

function FXConvert(xRecamt, yAmount, doNotShowMsg, thisForm) {
  if (isEmpty(xRecamt)) xRecamt = FXFormNames[5];  //recamt
  if (isEmpty(yAmount)) yAmount = FXFormNames[6];  //amount
  if (thisForm == null) thisForm = fxFormObj;
  var thisRate = returnStdNumFormat(thisForm.elements[FXFormNames[1]].value);
  var thisAmt = returnStdNumFormat(thisForm.elements[xRecamt].value);
  if (!isEmpty(thisForm.elements[xRecamt]) && !isEmpty(thisForm.elements[yAmount])) {
    LocalXFldObj = thisForm.elements[yAmount];
    FgnFldObj = thisForm.elements[xRecamt];
    var NumVal;
    if (thisRate == null) thisRate = "";
    if (isNaN(thisRate) || thisRate == "" || isEmpty(thisAmt) || isNaN(thisAmt)) {    
      if (thisRate == ""){   //xrate
        if (!isEmpty(thisAmt)){  
          setFgnObjAmount("");
        }
      } 
      if ((thisRate != "") && (isNaN(thisAmt) || isEmpty(thisAmt)) ) {
        if (doNotShowMsg == null) {
          alert(getJSX("JS_FX_FLD"));
          thisForm.elements[yAmount].value = "";
          thisForm.elements[xRecamt].focus();
          thisForm.elements[xRecamt].select();
        }
      } else {
        setFgnProtected(true);
      }
    } else {
      if (thisForm.elements[FXFormNames[2]].value == "0") { //ratetype   was 1
        NumVal = parseFloat(thisAmt) / parseFloat(thisRate);
      } else {
        NumVal = parseFloat(thisAmt) * parseFloat(thisRate);
      }  
      if (!isNaN(thisAmt) && FgnFldObj && !isNaN(NumVal.toString())) {
        setFgnObjAmount(thisAmt);
        setLocalObjCurrency(NumVal.toString()); 
      }
      setFgnProtected(false);
    }
  }
}

function __FXConvert(xRecamt, yAmount, doNotShowMsg) {
  if (isEmpty(xRecamt)) xRecamt = FXFormNames[5];  //recamt
  if (isEmpty(yAmount)) yAmount = FXFormNames[6];  //amount
  thisForm = document.forms[FormNumber];
  if (!isEmpty(thisForm.elements[xRecamt]) && !isEmpty(thisForm.elements[yAmount])) {
    LocalXFldObj = thisForm.elements[yAmount];
    FgnFldObj = thisForm.elements[xRecamt];
    var NumVal;
    if (thisForm.elements[FXFormNames[1]].value == null) thisForm.elements[FXFormNames[1]].value = "";
    if (isNaN(thisForm.elements[FXFormNames[1]].value) || thisForm.elements[FXFormNames[1]].value == "" || isEmpty(thisForm.elements[xRecamt].value) || isNaN(thisForm.elements[xRecamt].value)) {    
      if (thisForm.elements[FXFormNames[1]].value == ""){   //xrate
        if (!isEmpty(thisForm.elements[xRecamt].value)){  
          setFgnObjAmount("");
        }
      } 
      if ((thisForm.elements[FXFormNames[1]].value != "") && (isNaN(thisForm.elements[xRecamt].value) || isEmpty(thisForm.elements[xRecamt].value)) ) {
        if (doNotShowMsg == null) {
          alert("Invalid entry in the foreign amount field");
          thisForm.elements[yAmount].value = "";
          thisForm.elements[xRecamt].focus();
          thisForm.elements[xRecamt].select();
        }
      } else {
        setFgnProtected(true);
      }
    } else {
      if (thisForm.elements[FXFormNames[2]].value == "0") { //ratetype   was 1
        NumVal = parseFloat(thisForm.elements[xRecamt].value) / parseFloat(thisForm.elements[FXFormNames[1]].value);
      } else {
        NumVal = parseFloat(thisForm.elements[xRecamt].value) * parseFloat(thisForm.elements[FXFormNames[1]].value);
      }  
      if (!isNaN(thisForm.elements[xRecamt].value) && FgnFldObj && !isNaN(NumVal.toString())) {
        setFgnObjAmount(thisForm.elements[xRecamt].value);
        setLocalObjCurrency(NumVal.toString()); 
      }
      setFgnProtected(false);
    }
  }
}

function defCurrency(){
  thisForm = document.forms[FormNumber];
  var ResultItem = parent.contents.getDBSingle(parent.WorkDBase,"last_currency");
  if (ResultItem[0] == null) ResultItem[0] = "";
  ResultItem[0] = parent.contents.rtrim(ResultItem[0]);
  if (ResultItem.length > 0 && ResultItem[0].length > 0) {
    var ResultSet = parent.contents.getDBSingle(parent.PersDBase,"currency","units",ResultItem[0]);
    if (ResultSet.length > 0) {
      for (var i = 0; i < ResultSet[0].length; i++) {
        thisForm.elements[ResultSet[0][i][0]].value = ResultSet[0][i][1];
      }
      setFgnProtected(false);
    } else {
      thisForm.elements[FXFormNames[1]].value = "";  //xrate
      thisForm.elements[FXFormNames[2]].value = "";  //ratetyp
      thisForm.elements[FXFormNames[3]].value = "";  //xdate
      thisForm.elements[FXFormNames[4]].value = "";  //xsource
      setFgnProtected(true);
    }
  } else {
    setFgnProtected(true);
  }
}

function isEmpty(x) {
  if (x == null || x == "") {
    return true;
  } else {
    return false;
  }
}  
 
function CheckFGNAmount(objRecamt) {
  var retVal = false;
  thisForm = document.forms[FormNumber];
  if ((thisForm.elements[FXFormNames[1]].value != "") && (isNaN(objRecamt.value) || isEmpty(objRecamt.value)) ) {
     alert("Invalid entry in the foreign amount field");
     objRecamt.focus();
  } else {
     retVal = true;
  }
  return retVal;
}


function setRateTypeAuto(xLocal,yFGN) {
  var retVal = "";
  if (!isNaN(xLocal) && !isNaN(yFGN))
  {
    var x = parseFloat(xLocal);
    var y = parseFloat(yFGN);
    if (x >= y)
    {
        retVal = "1";  // Multiply for home currency
    } else {
        retVal = "0";  // Divide for home currency
    }
  } 
  return retVal;  
}
