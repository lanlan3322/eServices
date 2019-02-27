// validation.js - common validation routines
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

//Seriously need to go through this an fix this up
//This was NOT done by me...

var TailList = new Array();     //Receipts and expense transactions
var updReportFlag = "yes";      // update report with transactions
// Alert Messages
function blankTextAlert(textObj) {
        alert(getJSX("JSV_INPUT") + " " + retTitle(textObj) + ":" +  getJSX("JSV_BLANK"));
        textObj.focus();
        textObj.select();
}
function checkAllFieldsAlert(textObj) {
        alert(getJSX("JSV_INPUT") + " " + retTitle(textObj) + ":" +  getJSX("JSV_ALL"));
        textObj.focus();
}
function stringAlert(textObj) {
        alert(getJSX("JSV_INPUT") + " " + retTitle(textObj) + ":" +  getJSX("JSV_STRING"));
        textObj.focus();
        textObj.select();
}
function intAlert(textObj) {
        alert(getJSX("JSV_INPUT") + " " + retTitle(textObj) + ":" +  getJSX("JSV_NUMERIC"));
        textObj.focus();
        textObj.select();
}
function dropDownAlert(textObj) {
        alert(getJSX("JSV_INPUT") + " " + retTitle(textObj) + ":" +  getJSX("JSV_LIST"));
        textObj.focus();
}
function retTitle(textObj) {
  var retValue = textObj.essTitle;
  if (retValue == null) retValue = textObj.name;
  return retValue;
}
    

// Field Validation

// is used by other routines
function amountVal(textObj) {
        var newValue = textObj.value;
        if(newValue.length != "" && newValue != "0" + parent.contents.decimal + "00") {
            if (newValue != "NaN") {
                moneyFormat(textObj);
                return true;
            } else {
                textObj.value = "";
                return false;
            }
        } else {
                blankTextAlert(textObj);
                return false;
        }
}

// free to Change
function referVal(textObj) {
        var newValue = textObj.value;
        if(newValue.length != "") {
                isInt(textObj);
        }
        else {
                blankTextAlert(textObj);
                return false;
        }
}
// free to Change
function commentVal(textObj) {
        var newValue = textObj.value;
        if(newValue.length != "") {
                isString(textObj);
        }
        else {
                blankTextAlert(textObj);
                return false;
        }
}
// Drop Down Validation  - free to Change
function isDropDown(textObj) {
        var retVal = true;
        //var newValue = textObj[textObj.selectedIndex].text;
        if (textObj.essRequired && textObj.essRequired.toUpperCase() == "YES")
        {
           if (textObj.selectedIndex == 0 && (textObj[0].text == "select..." || textObj[0].text.length == 0))
           {
                dropDownAlert(textObj);
                retVal = false;
           }
        }
        return retVal;
}
// Interger Validation  - free to Change
function isInt(textObj) {
        var newValue = textObj.value;
        var newLength = newValue.length;
        for(var i = 0; i != newLength; i++) {
                aChar = newValue.substring(i,i+1);
                if(aChar < "0" || aChar > "9") {
                        intAlert(textObj);
                        return false;
                }
        }
        return true;
}
// Interger Validation  - free to Change
function isRate(textObj) {
        var newValue = textObj.value;
        var newLength = newValue.length;
        for(var i = 0; i != newLength; i++) {
                aChar = newValue.substring(i,i+1);
                if((aChar < "0" || aChar > "9") && aChar != parent.contents.decimal && aChar != "." && aChar != "-") {
                        intAlert(textObj);
                        return false;
                }
        }
        var Check = parseFloat(newValue);
        if (Check < -1 || Check > 10000) {
            intAlert(textObj);
            return false
        }
        return true;
}
// free to change
function isCurrency(tag, isMoney) {
  setFlags(tag);
  if (isMoney == null) isMoney = false;
  var retVal = true;
  if (isNaN(tag.value)) {
     alert(getJSX("JSV_NUMERIC2"));
     tag.focus();
     retVal = false;
  } else {
    //var Check = parseFloat(NV);
    var amount = new parent.contents.oNumber(tag.value);
    var Check = amount.standard;
    if (Check < minimumFloatRequired) {
      alert(getJSX("JSV_GREATER") + " " + minimumFloatRequired );
      tag.focus();
      retVal = false;
    } else if (maximumFloatAllowed != null && Check > maximumFloatAllowed) {
      alert(getJSX("JSV_LESS") + " "  + maximumFloatAllowed);
      tag.focus();
      retVal = false;
    } else {
      retVal = true;
    }
    if (isMoney) moneyFormat(tag);
  }
  return retVal;
}

// String Validation  - free to Change
function isString(textObj) {
  
  setFlags(textObj);
  if (maximumAllowed == 0) maximumAllowed = isString2Int(textObj.maxLength);
  var retVal = true;

  if ((required == "YES") && (NV.length < minimumRequired || NV.length < 1))
  {
    alert(getJSX("JSV_MISSING") + " " + entryTitle + ". " + getJSX("JSV_REQ") + " " + getMaximum(minimumRequired,1) + " - " + maximumAllowed + " " + getJSX("JSV_CHAR") + ".");
    retVal = false;
  } else if (NV.length > 0 && NV.length < minimumRequired) {
    alert(getJSX("JSV_SHORT") + " " + entryTitle + ". " + getJSX("JSV_REQ") + " " + minimumRequired + " - " + maximumAllowed + " " + getJSX("JSV_CHAR") + ".");
    retVal = false;
  } else if ((maximumAllowed != 0) && (NV.length > maximumAllowed)) {
    alert(getJSX("JSV_LONG") + " " + entryTitle + ", " + getJSX("JSV_LIMIT") + " " + maximumAllowed + " " + getJSX("JSV_CHAR") + ".");
    retVal = false;
  }
  return retVal;
}

// Shared by all checking routines
var NV;  
var minimumRequired;
var maximumAllowed;
var minimumFloatRequired;
var maximumFloatAllowed;

var required;
var entryTitle;
function setFlags(textObj) {
  NV = parent.contents.ltrim(parent.contents.rtrim(textObj.value));  
  minimumRequired = isString2Int(textObj.getAttribute("essMinimum"));
  maximumAllowed = isString2Int(textObj.getAttribute("essMaximum"));
  if (textObj.getAttribute("essMaximum") != null && textObj.getAttribute("essMaximum") != "") {
       maximumFloatAllowed = isString2Float(textObj.getAttribute("essMaximum"));
  } else {
       maximumFloatAllowed = null;
  }
  minimumFloatRequired = isString2Float(textObj.getAttribute("essMinimum"));
  required = textObj.getAttribute("essRequired");
  if (required == null) required = "NO";
  required = required.toUpperCase();
  entryTitle = textObj.essTitle;
  if (entryTitle == null) entryTitle = textObj.name;
}

function isString2Int(x) {
  if (x == null) 
  {
    x = 0;
  } else {
    x = parseInt(x);
    if (isNaN(x)) x = 0;
  }
   return x;
}

function isString2Float(x) {
  if (x == null) 
  {
    x = 0.0;
  } else {
    x = parseFloat(x);
    if (isNaN(x)) x = 0.0;
  }
   return x;
}

function getMaximum(x,y){
  retVal = x;
  if (y > x) {
    retVal = y
  }
  return retVal;
}

// Money Format
function moneyFormat(textObj) {
  parent.contents.makeCurrency(textObj);
}

// Check all fields before saving record

function checkAllFields(formX) {

//Will used the following in each field object:
//   name       
//   value
//   essType     (if present, one of the essTypes values - if not present field is skipped)
//   selectedIndex
//   essRequired (yes or no, null = no)
//   essMinimum  (for String is the trimmed length, List is selectedIndex, otherwise is value)
//   essMaximum  ( "  ") - also uses maxlength
//   esstitle    (used for error messages)

   var essTypes = ['STRING','CURRENCY','INTEGER','RATE','DATE','LIST',"NUMERIC"];
   var formObj;
   var essType;
   var n;
   var retVal = true;
   var localReturn = true;

   for (var i = 0; i < formX.length; i++) {
       formObj = formX.elements[i];
       essType = formObj.getAttribute("essType");
       if (essType != null)
       {       
          essType = essType.toUpperCase();
          if (essType == 'UPPERCASE') {
            if (formObj.value != null) formObj.value = formObj.value.toUpperCase();
            essType = "STRING";
          }
          n = getStringIndex(essTypes,essType);
          if (n == 0) {
            localReturn = isString(formObj);
          }else if (n == 1) {
            localReturn = isCurrency(formObj);
          }else if (n == 2) {
            localReturn = isInt(formObj,true);
          }else if (n == 3) {
            localReturn = isRate(formObj);
          }else if (n == 4) { //need calendar.js loaded for 'DATE' types on the form
            if (formObj.value != null && formObj.value.length > 0) {
              localReturn = checkdate(formObj); 
            } else if (formObj.getAttribute("essRequired") && formObj.getAttribute("essRequired").toUpperCase() == "YES") {
              localReturn = checkdate(formObj); 
            }
          }else if (n == 5) {
            localReturn = isDropDown(formObj);
          }else if (n == 6) {
            localReturn = isCurrency(formObj,false);
          } else {
            alert("Validation error: " + essType)
            localReturn = false;
          }
       retVal = (retVal && localReturn);
       }
   }
   return retVal;
}

function getStringIndex(stringArray, stringIndex)
{
    var retIndex = -1;
    for (var i = 0; i < stringArray.length; i++)
    {
        if (stringArray[i] == stringIndex)
        {
            retIndex = i;
            i = stringArray.length;
        }
    }
    return retIndex;
}

function isRequired(ThisName, ThisValue) {
        for (var i = 0; i < ThisName.length; i++) {                
                if(ThisValue[i] == "" || ThisValue[i] == "select...") {
                        checkAllFieldsAlert(document.forms[0].elements[i]);
                        updReportFlag = "no";
                        break;
                }
        }
}

var DepartObj; 
var CompanyObj;
var GuideListObj;

var httpXMLDepart;   //was httpXMLObj
function checkDepartAJAX(depart, obj2, obj3, objList4) {
  DepartObj = obj2;
  CompanyObj = obj3;
  var companyStr = obj3.value;  //Kluge for multi-depart support
  GuideListObj = objList4;
  httpXMLDepart = parent.contents.GetXmlHttpObject();
  parent.contents.getInfo(httpXMLDepart, parent.contents.defaultApps + 'Check.jsp?check=depart&param1=' + encodeURIComponent(depart) + '&param2=' + encodeURIComponent(companyStr), stateDepart, true);
}

function stateDepart() {   //was stateChanged()
  var i;
  var x = httpXMLDepart.readyState;
  if ( x == 4 )
  { 
     var x = httpXMLDepart.responseText;
     i = x.indexOf(";");
     if (i > -1) {
        x = x.substr(i+1);
     }
     if (CompanyObj != null)
     {
       i = x.indexOf(";");
       if (i > -1) {
         CompanyObj.value = x.substr(0,i);
         x = x.substr(i+1);
         i = x.indexOf(";");
         if ( i > -1) {
           DepartObj.value = x.substr(0,i);
           // var dg = x.substr(i+1);  - replaced by next three lines with ending of ;
           x = x.substr(i+1);
           var dg = reduceX(x);
           if  (GuideListObj != null) {
              for (var k = 0; k < GuideListObj.length; k++)
              {
                 if (GuideListObj.options[k].text == dg)
                 {
                   GuideListObj.selectedIndex = k;
                   k = GuideListObj.length; 
                 }
              }
           }
         } else {
           DepartObj.value = reduceX(x.substr(i+1));
         }  
       } else {
         DepartObj.value = reduceX(x);
       }
     } else {
       DepartObj.value = reduceX(x);
     }
  }
}

function reduceX(x) {
  var i = x.indexOf(";");
  if (i > -1) x = x.substr(0,i);
  return x;
}

function getJSX(x) {
   return parent.contents.getJSX(x);
}   
