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
// 675 Mass Ave, Cambridge, MA 02139, USA. var LocalFldObj;

//Note: you need addMerchant.js loaded for this.
function departMapping(obj1, obj2, obj3, listObj4) {
   if (obj1.value != "") {
     checkDepartAJAX(obj1.value, obj2, obj3, listObj4);
   } else {
     obj2.value = "";
     if (obj3 != null) obj3.value = "";  
     //what to do???
   }   
}

function deptNotValid(obj) {
  if (obj.value == "Not Valid") {
    alert("Invalid department - please correct");
    obj.focus()
    return true;
  } else {
    return false;
  }
}

function returnDepart(departValue,departText,departCompany,defaultGuide) {
   LocalFldObj.value = departValue;
   LocalFldObj2.value = departText;
   if ((departCompany != null) && (LocalFldObj3 != null)) LocalFldObj3.value = departCompany;
   if ((defaultGuide != null) && (LocalFldObj4 != null))   //list object
   {
       for (var i = 0; i < LocalFldObj4.length; i++)
       {
          if (LocalFldObj4.options[i].text == defaultGuide)
          {
             LocalFldObj4.selectedIndex = i;
             i = LocalFldObj4.length; 
          }
       }
   }  
}   
function setDepartObj(ThisObj1, ThisObj2, cType, defaultx, defaulty, ThisObj3, ThisObj4) {
   setLocalJsp(ThisObj1, cType, defaultx, defaulty);
   LocalFldObj2 = ThisObj2;
   LocalFldObj3 = ThisObj3;
   LocalFldObj4 = ThisObj4;
}
