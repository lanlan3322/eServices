 // xshared2.js - list handling and formatting routines
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


function genNoError() {
return(true);
}

function cusNoError() {
return(true);
}

//These are functions that are used to put information into selection lists
function setForm (FormObj, ListArray) {
// need to verify and encorporate changes in the form names not being present
 for (var i = 0; i < ListArray.length; i++) {
    FormObj.elements([ListArray][0]).value = ListArray[i][1];
 }    
}

function setList (SelectObj, ListArray, SkipString, setValue) {
   setListFromCell(SelectObj, ListArray, -1, SkipString, setValue);
}

function setListFromCell (SelectObj, ListArray, cellWanted, SkipString, setValue) {
//Used to load list options from a simple array
  var j = 0
  if (!SkipString) SkipString = "";
  if (!setValue) setValue = false;
  if (SelectObj.length == 0) {
    SelectObj.options.length = ListArray.length;
    for (var i = 0; i < ListArray.length; i++) {
      if (ListArray[i] == "" || SkipString.indexOf(";" + ListArray[i] + ";") == -1) 
      {
    	  if (cellWanted == -1) {
    		  SelectObj.options[j].text = ListArray[i];
    	  } else {
    		  SelectObj.options[j].text = ListArray[i][cellWanted];
    	  }
    	  if (setValue) SelectObj.options[j].value = ListArray[i];
    	  j = j + 1;
      }
    }
    SelectObj.selectedIndex = 0;  
    SelectObj.options.length = j;   
  } 
}

function setListWithTranslation (SelectObj, ListArray, SkipString) {
//Used to load list options from a two column array
  var j = 0
  if (!SkipString) SkipString = "";
  if (SelectObj.length == 0) {
    SelectObj.options.length = ListArray.length;
    for (var i = 0; i < ListArray.length; i++) {
      if (ListArray[i][0] == "" || SkipString.indexOf(";" + ListArray[i][0] + ";") == -1) 
      {
      SelectObj.options[j].text = ListArray[i][1];
      SelectObj.options[j].value = ListArray[i][0];
      j = j + 1;
      }
    }
    SelectObj.selectedIndex = 0;  
    SelectObj.options.length = j;   
  } 
}

function setListWithPers(SelectObj, CommonItems, PersItemWanted) {
  var mArray = getDBResult(parent.PersDBase,PersItemWanted);
  if (mArray.length > 0) {
    CommonItems = CommonItems.concat(mArray);
  }
  setList(SelectObj, CommonItems.sort());
}

function setRcptDefDate(SelectObj, dateDifference, baseDate) {
  if (parent.defDateStr == "") {
    if (HeadList.length > 0) {
      if (baseDate == null) baseDate = "begdate";
      SelectObj.value = getItemValue(HeadList[HeadList.length - 1], baseDate);
    } else {
      setDefaultDate(SelectObj, dateDifference);
    }
  } else {
    SelectObj.value = parent.defDateStr;
  }
}

function setDefaultDate(SelectObj, dateDifference, DateObj) {
  SelectObj.value = setDateStr(dateDifference, DateObj);
}

function setDateStr(dateDifference, DateObj) {
  //implement the dateDifference later on
  if (DateObj == null) {
    DateObj = new Date();
  }
  var currMilliSecs = DateObj.getTime();
  DateObj.setTime(currMilliSecs + (dateDifference * (24*60*60*1000)));
  var newDate = parent.dateFormat;
  newDate = newDate.replace("MM",DateObj.getMonth()+1);  //can also use reg exp /MM/g for global replace
  newDate = newDate.replace("dd",DateObj.getDate());
  newDate = newDate.replace("yyyy",DateObj.getFullYear());
  return newDate;
}

function getNormalDate(DateStr, DateObj) {  //need to fix this - jh 2010-01-25
  //expects date in some version of M/D/Y
  if (DateObj == null) {
    var DateObj = new Date();
  }
  var DateObj = setDateObj(DateStr);
  return "" + zeroPack((DateObj.getMonth()+1),2) + "/" + zeroPack(DateObj.getDate(),2) + "/" + DateObj.getFullYear();
}

function getNormalizeText(LocalStr) {
   return LocalStr;
}

function setTimeStr(DateObj) {
  //implement the dateDifference later on
  if (DateObj == null) {
    var DateObj = new Date();
  }
  var currMilliSecs = DateObj.getTime();
  DateObj.setTime(currMilliSecs);
  var xHours = "0" + DateObj.getHours();
  var xMinutes = "0" + DateObj.getMinutes();
  var xSeconds = "0" + DateObj.getSeconds();
  xHours = xHours.substring(xHours.length - 2);
  xMinutes = xMinutes.substring(xMinutes.length - 2);
  xSeconds = xSeconds.substring(xSeconds.length - 2);
  return "" + xHours + ":" + xMinutes + ":" + xSeconds;
}

function setDateObj(DateString) {    //need to fix this - jh 2010-01-25
  var DateObj = new Date();
  var i = DateString.indexOf("/");
  var j = DateString.indexOf("/",i+1);
  DateObj.setMonth(eval(DateString.substring(0,i)) - 1);
  DateObj.setDate(eval(DateString.substring(i+1,j)));
  var y = eval(DateString.substring(j+1));
  if (y < 100) {
    if (y < 80) {
      y = y + 2000;
    } else {
      y = y + 1900;
    }
  } 
  DateObj.setYear(y);
  return DateObj;
}


function setListWithValue (SelectObj, ListArray, x, y, both,reversal, startElement) {
//Used to load list options from a array with name,value pair [[x0,y0],[x1,y1]...[xn,yn]]
  if (x == null) x = 0;
  if (y == null) y = 1;
  if (both == null) both = false;
  if (reversal == null) reversal = false;
  if (startElement == null) startElement = 0;
  if (SelectObj.length == 0) {
    SelectObj.length = ListArray.length - startElement;
    for (var i = startElement; i < ListArray.length; i++) {
      if (both) {
        if (ListArray[i][y] > "") {
           SelectObj.options[i - startElement].text = ListArray[i][x] + " (" + ListArray[i][y] + ")";
        } else {
           SelectObj.options[i - startElement].text = ListArray[i][x];
        }
      } else {
        if (reversal) {
           SelectObj.options[i - startElement].text = ListArray[i][y];
        } else { 
           SelectObj.options[i - startElement].text = ListArray[i][x];
        }   
      }
      if (reversal) {
         SelectObj.options[i - startElement].value = ListArray[i][x];
      } else {
         SelectObj.options[i - startElement].value = ListArray[i][y];
      }
    }    
  SelectObj.selectedIndex = 0;
  } 
}

function setListWValueWPers(SelectObj,CommonItems,PersItemWanted,xText,yValue){
  var mArray = getDBResult(parent.PersDBase,PersItemWanted);
  if (mArray.length > 0) {
     for (var i = 0; i < mArray.length; i++) {
       if (isArray(mArray[i])) CommonItems[CommonItems.length] = [getDBValue(mArray[i],xText),getDBValue(mArray[i],yValue)];
     }
  }
  setListWithValue(SelectObj, CommonItems);
}

function setListWValWPersWBlank(SelectObj,CommonItems,PersItemWanted,xText,yValue){
  var mArray = new Array(1);
  mArray[0] = ["",""];
  CommonItems = mArray.concat(CommonItems);
  setListWValueWPers(SelectObj,CommonItems,PersItemWanted,xText,yValue);
}

function setListWKeyWPers(SelectObj,CommonItems,PersItemWanted,xText,yValue){
  var mArray = getDBResult(parent.PersDBase,PersItemWanted);
  if (mArray.length > 0) {
     for (var i = 0; i < mArray.length; i++) {
       CommonItems[CommonItems.length] = [getDBValue(mArray[i],xText),getDBValue(mArray[i],yValue)];
     }
  }
  setListWithKey(SelectObj, CommonItems);
}

function setListWKeyWPersW2nd(SelectObj,CommonItems,PersItemWanted,xText,yValue,ComItems2){
  var mArray = getDBResult(parent.PersDBase,PersItemWanted);
  if (mArray.length > 0) {
     for (var i = 0; i < mArray.length; i++) {
       CommonItems[CommonItems.length] = [getDBValue(mArray[i],xText),getDBValue(mArray[i],yValue)];
     }
  }
  if (ComItems2.length > 0) {
     for (var i = 0; i < ComItems2.length; i++) {
       if (ComItems2[i][0] != "") CommonItems[CommonItems.length] = [ComItems2[i][0],ComItems2[i][1]];
     }
  }
  setListWithKey(SelectObj, CommonItems);
}

function setListWithKey (SelectObj, ListArray, x, y, z) {
// Used to load list options from a array with name = name1 + ': ' + name2 
// and then name1 (key) as value[[x0,y0],[x1,y1]...[xn,yn]]
// Also can used for a list of arrays and showing specific columns
  var S = ": "; //separator
  if (!x) { 
     x = 0;       //first display
     y = 1;       //second display
  }
  if (!z) z = 0;  //value option
  if (SelectObj.length == 0) {
    SelectObj.length = ListArray.length;
//optimize to put the checks outside the loop
    for (var i = 0; i < ListArray.length; i++) {
      if (typeof(x) != "object") {  
        if (!y || x == y) {
          SelectObj.options[i].text = ListArray[i][x];
        } else {
          SelectObj.options[i].text = ListArray[i][x] + S + ListArray[i][y];
          if (SelectObj.options[i].text == S ) SelectObj.options[i].text = "";
        }
         SelectObj.options[i].value = ListArray[i][z];
      } else {
        var textStr = "";
        var DD = ""
        for (var k = 0; k < x.length; k++){ //x can also be an array, set y to zero
           if (typeof(x[k]) == "string") {
             textStr += DD + getNameValue(ListArray[i][z],x[k]);
           } else {
             textStr += DD + ListArray[i][z][x[k]][$value$];
           }
           DD = S;
        }
        SelectObj.options[i].text = textStr;
      
        var delimit = "";
        var xStr = O + Q + ListArray[i][y] + Q + D + O;  //in lists, y is the name
        for (var k = 0; k < ListArray[i][z].length; k++) {            
           xStr += delimit + setArray2Str(ListArray[i][z][k]);
           delimit = D;
        }              
        xStr += C + C;      
        SelectObj.options[i].value = xStr;
      }
    }    
  SelectObj.selectedIndex = -1;
  } 
}

function setArray2Str(ListArray, Quotes) {
   if (Quotes == null) Quotes = Q;
   var delimit = "";
   var xStr = O 
   for (var k = 0; k < ListArray.length; k++) {            
      if (typeof(ListArray[k]) == "string") {
        xStr += delimit + Quotes + correctStr(ListArray[k]) + Quotes;
      } else {
        xStr += delimit + setArray2Str(ListArray[k],Quotes);
      }
      delimit = D;
   }              
   xStr += C;      
   return xStr;
}


function strPair(x,y) {
  return O + Q + correctStr(x) + Q + D + Q + correctStr(y) + Q + C; 
}
function correctStr(processStr) {  //similar function in common.js
  var regexp ;
  regexp = /\n/g ;
  processStr = processStr.replace(regexp,"\\n");
  regexp = /\r/g ;
  processStr = processStr.replace(regexp,"");
  regexp = /"/g ;
  processStr = processStr.replace(regexp,"");
  if ((processStr.substr(0,1) != "[") || (processStr.substr(processStr.length - 1,1) != "]")) {   //assumed to be a string-array representation
    regexp = /'/g ;
    processStr = processStr.replace(regexp,"");
    regexp = /\]/g ;
    processStr = processStr.replace(regexp,")");
    regexp = /\[/g ;
    processStr = processStr.replace(regexp,"(");
  } 
  return processStr;
}


function setListFromHead (SelectObj,FieldsWantedArray,crossRef) {
  var ConstructedList = new Array(HeadList.length);
  var D;
  var StrX;
  var z;
  for (var i = 0; i < HeadList.length; i++) {
    D = ""; 
    ConstructedList[i] = new Array(2);
    ConstructedList[i][0] = "";
    ConstructedList[i][1] = getXref(i,crossRef);  
    var Items = HeadList[i][$items$];
    for (var j = 0; j < FieldsWantedArray.length; j++) {
      StrX = getNameValue(Items,FieldsWantedArray[j][0]);
      z = FieldsWantedArray[j][1];
      if (z != 0 && StrX.length > z) StrX = StrX.substr(0,z);
      ConstructedList[i][0] = ConstructedList[i][0] + D + StrX;      
      D = " ";  
    }
  }
  setListWithValue(SelectObj,ConstructedList);
  SelectObj.selectedIndex = ConstructedList.length - 1;
}

function getArrayFromHead(i,FieldsWantedArray,crossRef) {
  // JH 2008 April 26
  // i is the index to the HeadList array
  var D;
  var StrX;
  var z;
  D = ""; 
  var ConstructedList = new Array(2);
  ConstructedList[0] = "";
  ConstructedList[1] = getXref(i,crossRef);  
  var Items = HeadList[i][$items$];
  for (var j = 0; j < FieldsWantedArray.length; j++) {
      StrX = getNameValue(Items,FieldsWantedArray[j][0]);
      z = FieldsWantedArray[j][1];
      if (z != 0 && StrX.length > z) StrX = StrX.substr(0,z);
      ConstructedList[0] = ConstructedList[0] + D + StrX;      
      D = " ";  
  }
  return ConstructedList; 
}


//function constructStr(Items,FieldsWantedArray) {
//   var retVal = "";   
//   var StrX;
//   var D = "";
//   for (var j = 0; j < FieldsWantedArray.length; j++) {
//      StrX = getNameValue(Items,FieldsWantedArray[j][0]);
//      z = FieldsWantedArray[j][1];
//      if (z != 0 && StrX.length > z) StrX = StrX.substr(0,z);
//      retVal = retVal + D + StrX;      
//      D = " ";  
//   }
//}

function setDefaultFromHead (SelectObj) {
  //setListFromHead (SelectObj,getList4Head());
  setDfltFrmHdWSplit (SelectObj); 
  if (DefaultXref != "") {
    var z = true;
    var j = 0;
    do {
      if (SelectObj.options[j].value == DefaultXref) {
        SelectObj.selectedIndex = j;
        z = false;
      }
      j = j + 1;
    } while (z && j < SelectObj.length); 
  }
  
}

function setDfltFrmHdWSplit (SelectObj,crossRef) {
  setListFromHead(SelectObj,getList4Head(),crossRef);
  for (var j = 0; j < HeadList.length; j++) {
     if ( 0 + getNumericValue(HeadList[j], "weight") > 0) {
        var i = SelectObj.length;
        SelectObj.length = i + 1;
        SelectObj.options[i].text = "Split among purposes";
        SelectObj.options[i].value = "Weight";
        j = HeadList.length;
     }
  }
}

function getStringFmHead(i, ItemsWanted) {
  if (!ItemsWanted) ItemsWanted = getList4Head(); //Allow for flexible form design
  Items = HeadList[i][$items$];
  var D = "";
  var StrX;
  var ConstructString = "";
  for (var j = 0; j < ItemsWanted.length; j++) { 
    StrX = getNameValue(Items,ItemsWanted[j][0]);
    if (ItemsWanted[j][1] != 0) StrX = StrX.substr(0,ItemsWanted[j][1]);
    ConstructString = ConstructString + D + StrX;
    D = " ";  
  }
  return ConstructString;
}

function getStringFmHeadWhere(WhereName, WhereValue, ItemsWanted) {
  if (!ItemsWanted) ItemsWanted = getList4Head();
  var retValue = WhereValue;
  var checkValue;
  for (var i = 0; i < HeadList.length; i++) {
     checkValue = getItemValue(HeadList[i], WhereName);
     if (checkValue == WhereValue) {
        retValue = getStringFmHead(i, ItemsWanted);
        i = HeadList.length;
     }
  }
  return retValue;
}

function setListDefault(eleObj,defValue) {
   var j = 0;
   do {
     if (eleObj.options[j].text == defValue) {
         eleObj.selectedIndex = j;
     }
     j = j + 1;
   } while (j < eleObj.length); 
}

function setListDfltWVal(eleObj,defValue) {
   var j = 0;
   if (eleObj.length > 0) {    //review this jh 9/25/2003
     do {
       if (eleObj.options[j].value == defValue) {
         eleObj.selectedIndex = j;
       }
       j = j + 1;
     } while (j < eleObj.length);
   }
}

function setListValue(List, eleObj, Subj) {
//List = array(2), eleObj = select list, Subj = string
  var retVal = getDBValue(List, Subj);
  if (retVal != "") {
     var X = eleObj.type;
     if (X.indexOf("select") == 0) { 
       setListDefault(eleObj,retVal);
     } else {
       eleObj.value = retVal;
     }
  }  
}

//These functions help manipulate the head/tail arrays in common.js.
function getTotalValueFor(WhichList, ItemName, EditName, EditValueStr) {    //, ClassName
  if (!EditValueStr) EditValueStr = "";   //string to search for a match to the key
  //if (!ClassName) ClassName = "";         //need to put in a special process for _expensetype
  var Sum = 0;
  var sKey;
  var amount;
  for (var i = 0; i < WhichList.length; i++) {
    sKey = getItemValue(WhichList[i],EditName);
    if (!EditName || (sKey != "" && EditValueStr.indexOf(sKey + ";" ) != -1)) {
      amount = new oNumber(getNumericValue(WhichList[i],ItemName));
      Sum = Sum + amount.parseFloat();
      //Sum = Sum + parseFloat(getNumericValue(WhichList[i],ItemName));
    }
  }
  return Sum;  //returning numeric which needs to be made a string with Sum.toString(10)
}


function doesNameExist(ItemList, ItemName) { //ItemList = Array[Array[2]...]
  var retValue = false;
  if (ItemList != null) {    
    var j = ItemList.length;
    var i = 0;
    do {
      if (ItemList[i][$name$] == ItemName) {
        retValue = true;
        i = j;
      } 
      i = i + 1;
    } while(i < j);
  }
  return retValue;   
}    

function doesItemExist(ItemList, ItemName) { //ItemList = ListItem obj
   var x = false;
   if (typeof(ItemList) == "object") {
     x = doesNameExist(ItemList[$items$], ItemName);
   }
   return x;
}


function getTotalSubListValue(WhichList, SubListName, ItemName, EditName, EditValueStr) { 
  var Sum = 0;
  var subList;
  for (var i = 0; i < WhichList.length; i++) {
     subList = getItemValue(WhichList[i],SubListName);
     if (subList == null) alert(getJSX("JS2_SUBLIST"));
     if (typeof(subList) != "string") {
       Sum += getTotalValueFor(subList, ItemName, EditName, EditValueStr);
     }
  }
  return Sum;
}

function getResultWhere(ItemArray, WhereName, WhereValue) {
// null == result not found 
  var retValue;  
  for (var i = 0; i < ItemArray.length; i++) {
     retValue = getItemValue(ItemArray[i],WhereName);
     if (retValue == WhereValue) return ItemArray[i];
  }
  return null;
}

function getNameValue(ItemList, ItemName) { //ItemList = Array[Array[2]...]
  var j = ItemList.length;
  var i = 0;
  var retValue = "";
  do {
    if (ItemList[i][$name$] == ItemName) {
      retValue = ItemList[i][$value$];
      i = j;
    } 
    i = i + 1;
  } while(i < j);
  return retValue;   
}    

function getItemValue(ItemList, ItemName) { //ItemList = ListItem obj
   var x = "";
   if (typeof(ItemList) == "object") {
     x = getNameValue(ItemList[$items$], ItemName);
   }
   return x;
}

function getNumericValue(ItemList, ItemName) { //ItemList = ListItem obj
   var x = "0.0";
   if (typeof(ItemList) == "object") {
     x = getNameValue(ItemList[$items$], ItemName);
     if (x == "") x = "0.0";    
   }
   return x; 
}

function getNameValueSubstr(ItemList, ItemName) { //ItemList = Array[Array[2]...]
  var j = ItemList.length;
  var i = 0;
  var retValue = "";
  do {
    if (ItemList[i][$name$].indexOf(ItemName) > -1) {
      retValue = ItemList[i][$value$];
      i = j;
    } 
    i = i + 1;
  } while(i < j);
  return retValue;   
}    

function getItemValueSubstr(ItemList, ItemName) { //ItemList = ListItem obj
    return getNameValueSubstr(ItemList[$items$], ItemName);
}

function setNameValue(ItemList, ItemName, setValue) { //ItemList = Array[ Array [name,value]...]
  var j = ItemList.length;
  var i = 0;
  var retValue = false;
  if (j > 0) {
    do {
      if (ItemList[i][$name$] == ItemName) {
        ItemList[i] = TransCell(ItemName, setValue); 
        i = j;
        retValue = true;
      } 
      i = i + 1;
    } while(i < j);
  }
  if (!retValue) {
    ItemList[j] = TransCell(ItemName, setValue);  //adding a new item
    retValue = true;
  }
  return retValue;   //true if set, will never be false at this time
}    

//These functions format numbers
function formatNumber(expr, decplaces) {
   var x = "" + expr;
   x = x.replace(".",parent.decimal);
   return format(x, decplaces);
}


function format (expr, decplaces) {
  var sign = "";
  var str;
  var amount = new oNumber(expr);
  var numx = amount.parseFloat();
  // var numx = parseFloat(expr); 
  if (numx < 0 ) {
    sign = "-";
    str = "" + Math.round(-1 * numx * Math.pow(10,decplaces));
  } else {
    str = "" + Math.round(numx * Math.pow(10,decplaces));
  }
  while (str.length <= decplaces) {
    str = "0" + str;
  }
  var decpoint = str.length - decplaces;
  return sign + str.substring(0,decpoint) + parent.decimal + str.substring(decpoint,str.length);
}
function makeCurrency (obj) {
  var thisValue = obj.value;
  if (!isNaN(thisValue) && !isEmpty(thisValue)) {
    var commaPos = thisValue.lastIndexOf(",");
    var pointPos = thisValue.lastIndexOf(".");
    if ((pointPos > commaPos) && (parent.decimal == ","))
    {
    	thisValue = returnMyNumFormat(thisValue);
    }
    obj.value = format(thisValue,2);
  }
}
function isEmpty(x) {
  if (x == null || x == "") {
    return true;
  } else {
    return false;
  }
}  
 
var generalLimit;
function checkAmtFldOK(tag, xType, allowNeg, specificLimit) {
  if (specificLimit != null) generalLimit = specificLimit;	
  if (generalLimit == null) generalLimit = getDefaultLimit();
  if (tag.value == "") tag.value = "0" + parent.decimal + "00";  //jh 2005-12-27
  var PerReq = getPersonalReq();  
  var amount = new oNumber(tag.value);  //my function which handles the proper replacements - see below
  if (allowNeg == null) allowNeg = getAllowNegative();
  if (isNaN(amount.standard) || rtrim(amount.standard) == "" || amount.hasSeparator) {
     alert(getJSX("JS2_NUMERIC"));
     tag.focus();
     return false;
  } else {
    var Check = amount.parseFloat();
    if (Check < .01 && !allowNeg) {
      alert(getJSX("JS2_AMOUNT0"));
      tag.focus();
      return false;
    } else if (Check < .01 && xType != null && (PerReq.indexOf(xType) > -1)) {
      alert(getJSX("JS2_PERS0"));
      tag.focus();
      return false;
    } else if (Check >= generalLimit) {
      alert(getJSX("JS2_LESS") + " " + generalLimit);
      tag.focus();
      return false;
    } else {
      return true;
    }
  }
}

function oNumber(x) {   //Creates a number from the user's format
   this.original = x;
   this.hasSeparator = false;
   x = "" + x;
   while (x.indexOf(parent.separator) > -1 )
   {
	       x = x.replace(parent.separator,"");
	       this.hasSeparator = true;
   }
   this.simple = x;
   x = x.replace(parent.decimal,".");
   this.standard = x;
   this.parseFloat = function() 
   {
      return parseFloat(this.standard);
   }
}

function myNumber(x) {  //Creates a number from the standard format
   this.original = x;
   x = "" + x;
   while (x.indexOf(parent.separator) > -1 )
   {
	       x = x.replace(",","");
   }
   this.simple = x;
   //x = x.replace(parent.decimal,".");
   this.standard = x;
   this.parseFloat = function() 
   {
      return parseFloat(this.standard);
   }
   this.returnMine = function()
   {
      return this.standard.replace(".",parent.decimal);
   }
}

function returnMyNumFormat(x)
{
   x = "" + x;
   x = x.replace(",",""); 
   return x.replace(".",parent.decimal);
}

function returnStdNumFormat(x)
{
   x = "" + x;
   x = x.replace(parent.separator,"");
   return x.replace(parent.decimal,".");
}

function setGeneralLimit(currency) {
  var searchArray = getCurrencies();
  var returnArray = getTransLimits();
  var x = getDefaultLimit();
  for (var i = 0; i < searchArray.length; i++)
  {
    if (searchArray[i] == currency) {
       x = returnArray[i];
       if (x == null) x = getDefaultLimit();  //see above
       i = searchArray.length; 
    }
  }
  generalLimit = x;
}

function getReportCurrencyLabel() {
   return getCurrencyLabel(getNameValue(parent.Header,"CURRENCY"));
}

function getCurrencyLabel(retVal) {
   if (retVal == null) retVal = getNameValue(parent.Header,"currency");
   if (retVal == null || retVal == "") retVal = getHomeCurrency();
   if (retVal != "Amount" && retVal.substring(retVal.length - 1) != "s") retVal = retVal + "s";  //English!
   return retVal;
}

function getDistanceLabel() {
   var retVal;
   retVal = getDistanceUnitXlation();
   if (retVal != null && retVal != "" && retVal.substring(retVal.length - 1) != "s") retVal = retVal + "s";  //English!
   return retVal;
}

//These functions are used for accessing the personal database

function setDBAdd(dBase, Name, Value) { //adds a value/pair to the 
  if (typeof(Value) == "string") { 
    dBase[dBase.length] = [Name, Value];
  } else {
    dBase[dBase.length] = [Name, new Array()];
    setArray(dBase[dBase.length - 1][1],Value);
  }
}

function setDBGlobal(dBase, Name, Value) { //replaces an existing throughout
  if (Value != null) {
    for (var i = 0; i < dBase.length; i++) {
       if (typeof(dBase[i][1]) == "string") {
          if (dBase[i][0] == Name) dBase[i][1] = Value;
       } else {
          setDBGlobal(dBase[i][1], Name, Value);
       }    
    }
  }
}

function setDBPair(dBase, Name, Value) { //replaces an existing
  if (Value != null) {
    var addFlag = true;
    if (typeof(Value) == "string") {
      for (var i = 0; i < dBase.length; i++) {
        if (dBase[i][0] == Name) {
          dBase[i][1] = Value;
          addFlag = false;
          i = dBase.length;
        }
      }
    } else {
      if (Value.length > 0) {  
        for (var i = 0; i < dBase.length; i++) {
          if (dBase[i][0] == Name && dBase[i][1][0] != null && dBase[i][1][0][0] == Value[0][0] && dBase[i][1][0][1] == Value[0][1]) {
            dBase[i][1] = new Array();
            setArray(dBase[i][1], Value);
            addFlag = false;
            i = dBase.length;
          }
        }
      }
    }
    if (addFlag) {
      setDBAdd(dBase, Name, Value);
    }
  }
} 

function setDBUniquePair(dBase, Name, Value) { //adds a unique name value (assumes column 0 is an index for complex)
  var addFlag = true;
  var ind = 0
  var indx = ind + 1
  if (typeof(Value) == "string") {
    for (var i = 0; i < dBase.length; i++) {
      if (dBase[i][0] == Name && dBase[i][1] == Value) {
        addFlag = false;
        i = dBase.length;
      }
    }
  } else {
    for (var i = 0; i < dBase.length; i++) {
      if (dBase[i][0] == Name && dBase[i][indx][0][0] == Value[ind][0] && dBase[i][indx][0][1] == Value[ind][1]) {
        addFlag = false;
        i = dBase.length;
      }
    }
  }
  if (addFlag) {
    setDBAdd(dBase, Name, Value);
  }
} 

function setArray(x,y) {
  var Str1;
  var Str2;
  for (var i = 0; i < y.length; i++) {
     Str1 = y[i][0];
     Str2 = y[i][1];
     x[x.length] = new Array(Str1, Str2);
  }  
}    

function getDBResult(dBase, Name) { 
  var returnSet = new Array();
  for (var i = 0; i < dBase.length; i++) {
     if (dBase[i][0] == Name) {
       returnSet[returnSet.length] = dBase[i][1];
     }
  }
  return returnSet;
}

var WhereSet = new Array();
function getDBWhere(dBase, Name, Where, Value) {
  var resultSet = getDBResult(dBase, Name);
  WhereSet = new Array()
  for (var i = 0; i < resultSet.length; i++) {
    for (var j = 0; j < resultSet[i].length; j++) {
      if (resultSet[i][j][0] == Where && resultSet[i][j][1] == Value) { 
        WhereSet[WhereSet.length] =  resultSet[i];
        j = resultSet[i].length;
      }
    }
  }
  return WhereSet;
}

var SingleSet = new Array();
function getDBSingle(dBase, Name, Where, Value) {
//This can be called with either 2 or 4 parameters
  var resultSet;
  if (Where) {
    resultSet = getDBWhere(dBase, Name, Where, Value);
  } else {
    resultSet = getDBResult(dBase, Name);
  }
  SingleSet = new Array();
  if (resultSet.length > 0) SingleSet = resultSet;
  return SingleSet;
}

function getDBValue(ItemList, ItemName, RetLocation, TC){
//Gets the value for a name from the array (seeNameValue)
  var j = ItemList.length;
  var i = 0;
  var retValue = "";
  if (RetLocation == null) RetLocation = 1;
  if (TC == null) TC = 0;  //Title Column to Search
  if (j > 0) { 
    do {
      if (ItemList[i][TC] == ItemName) {
        retValue = ItemList[i][RetLocation];
        i = j;
      } 
      i = i + 1;
    } while(i < j);
  }
  return retValue;   
}   

function getDBString(ItemList, ItemName, DefValue) {
  if (!DefValue) DefValue = "";
  var x = getDBValue(ItemList, ItemName);
  if (x == "") x = DefValue;
  return x
}

function removeDBPair(dBase, Name, Value) { 
  var removeItem = -1;
  if (typeof(Value) == "string") {
    for (var i = 0; i < dBase.length; i++) {
      if (dBase[i][0] == Name && dBase[i][1] == Value) {
        removeItem = i;
        i = dBase.length;
      }
    }
  } else {
    for (var i = 0; i < dBase.length; i++) {
      if (dBase[i][0] == Name && dBase[i][1][0][0] == Value[0][0] && dBase[i][1][0][1] == Value[0][1]) {
        removeItem = i;
        i = dBase.length;
      }
    }
  }
  if (removeItem != -1) {
    dBase[removeItem] = new Array(2);
    dBase[removeItem][0] = "removed";
    dBase[removeItem][1] = "";
    return true;
  } else {
    return false;
  }
} 

//Simple formatting functions

function isNumber(x) { 
  if (x == null) return false;
  oneDec = false;
  y = x.toString();
  if (y.length == 0) return false;
  for (var i = 0; i < y.length; i++) {
     var oneChar = y.charAt(i);
     if (i == 0 && oneChar == "-") continue;
     if (oneChar == parent.decimal && !oneDec) {
        oneDec = true;
        continue;
     }
     if (oneChar < "0" || oneChar > "9") return false;
  }
  return true;
}

function alltrim(arg) {
  return ltrim(rtrim(arg));
}

function rtrim(arg) {
  var trimvalue = "";
  var arglen = arg.length;
  if (arglen < 1) return trimvalue;
  var lastpos = -1;
  var i = arglen;
  while (i >= 0) {
    if (arg.charCodeAt(i) != 32 && !isNaN(arg.charCodeAt(i))) {
      lastpos = i;
      break;
    }
    i--;
  }
  trimvalue = arg.substring(0,lastpos+1);
  return trimvalue;
}


function ltrim(arg) {
  var trimvalue = "";
  var arglen = arg.length;
  if (arglen < 1) return trimvalue;
  var i = 0;
  pos = -1;
  while (i < arglen) {
    if (arg.charCodeAt(i) != 32 && !isNaN(arg.charCodeAt(i))) {
      pos = i;
      break;
    }
    i++;
  }
  trimvalue = arg.substring(pos);
  return trimvalue;
}

function zeroPack(x, n) {
  x = "" + x;  
  x = "0000000000000000" + ltrim(x);
  var xLen = x.length;
  x = x.substr(xLen - n);
  return x;   
}

// Handling returns

var SQLStack = new Array();
var DisplayStack = new Array();
function setLastSQL(x) {
   pushStack(SQLStack, x);
}
function getLastSQL() {
   return popStack(SQLStack);
}
function setLastDisplay(x) {
   pushStack(DisplayStack, x);
}
function getLastDisplay() {
   return getStack(DisplayStack);
}
function pushStack(stack, x) {
     stack.length = stack.length + 1;
     stack[stack.length - 1] = x;
}
function popStack(stack) {
  var retVal = "";
  if (stack.length > 0) {
     retVal = stack[stack.length - 1];
     stack.length = stack.length - 1;
  }
  return retVal; 
}

function getStack(stack) {
  var retVal = "";
  if (stack.length > 0) {
     retVal = stack[stack.length - 1];
  }
  return retVal; 
}

function initStacks() {
//Call when a non-return event takes place or even better
//to initiate a sequence.
     SQLStack.length = 0;
     DisplayStack.length = 0;
}

function isItemInArray(xArray, xItem) {
  var retVal = -1;
  for ( var i = 0; i < xArray.length; i++) {
     if (xArray[i] == xItem) {
        retVal = i;
        i = xArray.length;
     }
  }
  return retVal;
}

function isArray(obj){
   var retVal = true;
   if (typeof(obj.length) == "undefined" || typeof(obj) == "string") retVal = false;
   return retVal;
}
// End of script file
