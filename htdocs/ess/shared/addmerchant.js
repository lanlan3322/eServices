// addmerchant.js - source for adding attendees to a receipt 
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

var LocalFldObj;
var MerchantType = "merchant";
var merchantCCode = parent;
var PersDataArea = parent;
var LocalReturn = "";

function MerWinSize(x,y,cType) {
  if (merchantCCode.setDBPair) {
    if (cType == null) cType = "addmerchant";
    merchantCCode.setDBPair(PersDataArea.PersDBase, cType + "-x", "" + x);
    merchantCCode.setDBPair(PersDataArea.PersDBase, cType + "-y", "" + y);
  }
}

function setLocalMerchant(LocalText, AddValue, LocalValue, CombineFlag) {
   LocalText = merchantCCode.getNormalizeText(LocalText);
   var OrigText = LocalText;
   if (!AddValue) AddValue = LocalText;
   if (!CombineFlag) CombineFlag = "1";
   if (CombineFlag == "2") LocalText = LocalText + ": " + LocalValue;
   if (CombineFlag == "3") LocalText = LocalValue + " " + LocalText;
   var addFlag = true;
   var i = LocalFldObj.length + 1;  
   for (var j = 0; j < LocalFldObj.options.length; j++) {
     if (LocalFldObj.options[j].text.toUpperCase() == LocalText.toUpperCase()) {
       addFlag = false;
       i = j;
       j = LocalFldObj.options.length;
     }
   }
   if (addFlag) {
     LocalFldObj.length = i;
     i = i - 1;
     LocalFldObj.options[i].text = LocalText;
     if (CombineFlag == "2") {
        LocalFldObj.options[i].value = OrigText;
     } else { 
        if (LocalValue) {
           LocalFldObj.options[i].value = LocalValue;
        }
     }
   }
   merchantCCode.setDBUniquePair(PersDataArea.PersDBase,MerchantType,AddValue);
   LocalFldObj.selectedIndex = i;
   
   if (LocalReturn != "") eval(LocalReturn);
   if (LocalFldObj.onReturn) eval(LocalFldObj.onReturn);
}

function setLocalJsp(ThisObj, cType, defaultx, defaulty){
   var cOptions = "title,resizable,titlebar,scrollbars";
   setLocalObj(ThisObj, cType, defaultx, defaulty, parent.defaultApps, "jsp?email=" + parent.getNameValue(parent.Header, "email"),cOptions);
}

function setLocalObj(ThisObj, cType, defaultx, defaulty, cFolder, cExt,cOptions) {
   if (cType == null) cType = "addmerchant";
   if (defaultx == null) defaultx = 200;
   if (defaulty == null) defaulty = 150;
   if (cFolder == null) cFolder = parent.webServer + "/" + parent.webFolder + "/" + parent.language + "/";
   if (cExt == null) cExt = "html";
   if (cOptions == null) cOptions = "title,resizable,titlebar";
   var x = cType + "-x";
   var y = cType + "-y";
   LocalFldObj = ThisObj;
   LocalReturn = "";
   var x = merchantCCode.getDBString(PersDataArea.PersDBase, x, defaultx);  //was DBmerchantCCode
   var y = merchantCCode.getDBString(PersDataArea.PersDBase, y, defaulty);
   var optionString = "dependent,width=" + x + ",height=" + y + "," + cOptions;
   top.newWin = window.open(cFolder + cType + "." + cExt, "merchant", optionString);
}
