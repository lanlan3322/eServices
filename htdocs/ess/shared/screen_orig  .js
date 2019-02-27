// screen.js - controls report input screen 
// Copyright (C) 2010,2014 R. James Holton

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

var useScreenDefaultDates = false;
var checkForPrepop = new checkAJAX();   //see check.js
function FillForm() {

Log.println("screen.js","FillForm Starting");
  var mStart = 2;     //Set to 3 if returned funds, set to two if returned funds are commented out

  // document.forms[formStartNumber].project.subtype = "select-value";  //needed for Mozilla
  // document.forms[formStartNumber].location.subtype = "select-value";
  // document.forms[formStartNumber].department.subtype = "select-value";

  parent.setDefaultDate(document.forms[formStartNumber].begdate,-2);
  parent.setDefaultDate(document.forms[formStartNumber].enddate,-1);
  parent.setDefaultDate(document.forms[formStartNumber + 1].rcptdate,-2);
  if (useScreenDefaultDates) parent.setScreenDefaultDate(document.forms[formStartNumber + mStart].rcptdate,-1);
  document.forms[formStartNumber + mStart].xrate.value = returnMyNumFormat(parent.getMileageDefault(),4);
  //document.forms[formStartNumber + mStart].xrate.readOnly = parent.getMileageReadOnly();
  document.forms[formStartNumber + mStart].units.value = parent.getDistanceUnit();
  document.forms[formStartNumber + mStart].expense_1_billtype.value = "No";
  if(document.forms[formStartNumber].projectname) parent.setListWithValue(document.forms[formStartNumber].projectname,parent.getProjectNos("1"),0,1,true,true);
  if(document.forms[formStartNumber].clientLookup)
  {
     parent.setListWValueWPers(document.forms[formStartNumber].clientLookup, parent.getClientNos("2"),"client","client","clientno");
  }
  MerchantType = "location";
  if(document.forms[formStartNumber].location) document.forms[formStartNumber].location.value = parent.getDefaultLocation();  //2014-3-14
  if(document.forms[formStartNumber].locationname) parent.setListWithValue(document.forms[formStartNumber].locationname, parent.getLocation4Trvl("1"),0,1,false,true,1);
  if(document.forms[formStartNumber].locationname) parent.setListDfltWVal(document.forms[formStartNumber].locationname,parent.getDefaultLocation());
  
  if(document.forms[formStartNumber].departmentname  && document.forms[formStartNumber].departmentname.type == "select-one") {
  	parent.setListWithValue(document.forms[formStartNumber].departmentname,parent.getDepartments(),0,1,true,true,1);
  	parent.setListDfltWVal(document.forms[formStartNumber].departmentname,parent.getNameValue(parent.myHeader, "depart"));
  } else if (document.forms[formStartNumber].departmentname) { 
    document.forms[formStartNumber].depart.value = parent.getNameValue(parent.myHeader, "depart");
    document.forms[formStartNumber].departmentname.value = parent.getNameValue(parent.getDepartments(), parent.getNameValue(parent.myHeader, "depart"));
  }
  if(document.forms[formStartNumber].stepno) parent.setListDefault(document.forms[formStartNumber].stepno, parent.getDefault("combine2.stepno"));
//  var xlist =  ";" + DedicatedList() + parent.getMerchantReq();
  numberMileageLines = 0;  //these are found in xshared1.js
  numberReceiptLines = 0;
  numberPlaneReceiptLines = 0;

  for (var i = formStartNumber + mStart; i < document.forms.length; i++) {
    if (document.forms[i].expense_1_expensetypename) parent.setListWithTranslation(document.forms[i].expense_1_expensetypename, parent.getExpense4Trvl());  //xlist
    if (document.forms[i].charge) document.forms[i].charge.value = parent.getChargeDef();
    if (document.forms[i].locationname) {
	      parent.setListWithValue(document.forms[i].locationname, parent.getLocation4Trvl("1"),0,1,false,true,1); 
              parent.setListDfltWVal(document.forms[i].locationname,parent.getDefaultLocation());
	}	
    if(document.forms[i].refername) parent.setListWithValue(document.forms[i].refername,parent.getProjectNos("1"),0,1,true,true);  
    if (document.forms[i].offsetname) {
	      parent.setListWithValue(document.forms[i].offsetname, parent.getLocation4Trvl("1"),0,1,false,true,1); 
	      parent.setListDfltWVal(document.forms[i].offsetname,parent.getDefaultLocation());
	}	
	if (document.forms[i].merchant && document.forms[i].merchant.type == "select-one") {
	       MerchantType = "merchant";
           var merchArray = parent.getMerchants("1");
           var mArray = merchArray.concat(parent.getDBResult(parent.PersDBase,MerchantType));
           parent.setList(document.forms[i].merchant, mArray.sort());
	}	  
    if (document.forms[i].lodgingtranslation) document.forms[i].lodgingtranslation.value = parent.getLodgingTrans();
    if (document.forms[i].planetranslation) {
          document.forms[i].planetranslation.value = parent.getAirTrans();
          document.forms[i].expense_1_expensetype.value = parent.getAirDef();
    }      
    if (useScreenDefaultDates) parent.setDefaultDate(document.forms[i].rcptdate,-2);
   	if (document.forms[i].mileageLabel) document.forms[i].mileageLabel.value = parent.getDistanceUnitXlation();
    document.forms[i].expense_1_billtype.value = "No";
  }

  // Advance and Return Section
  //parent.setDefaultDate(document.forms[formStartNumber + 1].rcptdate,-1);
  //parent.setDefaultDate(document.forms[formStartNumber + 2].rcptdate,0);
  

  checkForPrepop.param2 = "ajaxprepopbutton";  //return the correct button
  checkForPrepop.setStandard(parent.getNameValue(parent.Header, "persnum"));  //Will display the prepop button
  document.forms[formStartNumber].begdate.focus();

}

function DedicatedList() {
//Remove expense types requiring other than cash.
  var retVal = "";
  var delimit = ";";
  var x = parent.getDedicatedMethod("1");
  for (var i = 0; i < x.length; i++) {
     if (x[i][1] != parent.getChargeDef() && x[i][1] != "") {
       retVal += delimit + x[i][0];
     }
  } 
  return retVal;
}

var screenDupFlagOK = true;
function SubmitRec(xPost) {
Log.println("screen.js","SubmitRec");
 var retVal = true;
 if (xPost == "Post") {
 if (screenDupFlagOK) {
  screenDupFlagOK = false;
  var PostScreen = true;
  // do purpose form check here and set to false if failed
  if (doDateCheck(document.forms[formStartNumber].begdate.value, document.forms[formStartNumber].enddate.value)
     && checkdate(document.forms[formStartNumber].begdate)
     && checkdate(document.forms[formStartNumber].enddate) 
     && ((document.forms[formStartNumber].project) ? checkProject(parent.rtrim(document.forms[formStartNumber].project.value)) : true )) {

    with (document.forms[formStartNumber]) {    //check projects, clients and locations???
      if (checkPurpComment(comment)) {
         PostScreen = true;
      } else {
          var j = formStartNumber + 1;
          var noReceipts2Post = true;
          do {
             noReceipts2Post = isNotPostedReceipt(document.forms[j++]) 
          } while (noReceipts2Post == true && j < document.forms.length);     
          if (!noReceipts2Post) {
             alert(getJSX("JSS_NEED_REASON"));
             comment.focus();
             comment.select();
             PostScreen = false;
          }  else {
             screenDupFlagOK = true;
             retVal = false;
             PostScreen = false;
             return true;        //JH 2010-06-30
          }   
      }
    }
      
    // do expense grid check here and set to false if failed
    var i = formStartNumber + 1; 
    do {
       //Check OK to post (not a blank line)
       if (document.forms[i].name == "screenReceipt" && isGoodReceipt(document.forms[i])) {
          i = i + 1; 
       } else if (document.forms[i].name == "screenHotel" && isGoodReceipt(document.forms[i])) {
          i = i + 1;  
       } else if (document.forms[i].name == "screenPlaneReceipt" && isGoodReceipt(document.forms[i])) {
          i = i + 1;
       } else if (document.forms[i].name == "screenMileage" && isGoodReceipt(document.forms[i]) && milesValueOK(document.forms[i])) {  // Changed to an and condition JH 2-16
          i = i + 1;

       } else if (document.forms[i].name == "screenMileage2"   // Changed to an and condition JH 2-16 
                  && (CheckZero(document.forms[i].amount) 
                      || document.forms[i].amount.value == ""
                      || isNaN(parseFloat(document.forms[i].amount.value))) 
                  && CheckAmount(document.forms[i].amount)                  
                  && CheckMilesOK(document.forms[i])
                  && checkdate(document.forms[i].rcptdate)) {   
                      i = i + 1;

       } else if (document.forms[i].name == "advanceEntry"    //need to check for reference numbers
                  && (CheckZero(document.forms[i].amount) || document.forms[i].amount.value == '' || parent.checkAmtFldOK(document.forms[i].amount,null,false))   //JH 2-16
                  && checkdate(document.forms[i].rcptdate)
                  && doDateChkToday(document.forms[i].rcptdate))  {
          i = i + 1;   
       } else if (document.forms[i].name == "returnEntry"    //need to check for reference numbers
                  && (CheckZero(document.forms[i].amount) || CheckAmount(document.forms[i].amount))                  
                  && checkdate(document.forms[i].rcptdate)
                  && doDateChkToday(document.forms[i].rcptdate))  {
          i = i + 1;           
       } else {    
          PostScreen = false;
       }  
      
    } while (PostScreen == true && i < document.forms.length);
    
    var calculatedIndex = 0;
    if (PostScreen == true) {
      functionPostScreen();
    } else {
      // alert(getJSX("JSS_CORRECT_REPORT"));
      screenDupFlagOK = true;
      retVal = false;
    }
   } else {
     // alert(getJSX("JSS_CORRECT_REPORT") + " [2]");
     screenDupFlagOK = true;
     retVal = false;
   } 
    
  } else {
     alert(getJSX("JSS_PROCESSING"));
     retVal = false;
  }   
  }   //xPost
  return retVal;
}

function functionPostScreen() {
      var calculatedIndex = 0;
      var newListBuffer = new Array();
      var newListIndex = -1;
      
      parent.NewReport(); 
      document.forms[formStartNumber].xref.value = parent.NextXref();
      parent.UpdateReport('1','head2a',document.forms[formStartNumber]);
      if (parent.HeadList.length == 1) {
        var r = parent.setNameValue(parent.Header, "comment", document.forms[formStartNumber].comment.value);
        if(document.forms[formStartNumber].departmentname  && document.forms[formStartNumber].departmentname.type == "select-one") {
           r = parent.setNameValue(parent.Header, "depart", document.forms[formStartNumber].departmentname[document.forms[formStartNumber].departmentname.selectedIndex].value); 

        } else if (document.forms[formStartNumber].departmentname) { 
           r = parent.setNameValue(parent.Header, "depart", document.forms[formStartNumber].depart.value);
        }
      }    
      var thisPurpose = parent.getStringFmHead(parent.HeadList.length - 1);
      // post mileage transaction - throws out blanks
      for (var j = formStartNumber + 1; j < document.forms.length; j++) {
        if (document.forms[j].name == "screenMileage") {
          if (!CheckZero(document.forms[j].amount) && !isNaN(parseFloat(document.forms[j].amount.value)) && !isNaN(parseFloat(document.forms[j].recamt.value))) {
            document.forms[j].expense_1_purpose.value = thisPurpose;
            document.forms[j].expense_1_expensetype.value = parent.getMileageType();
            document.forms[j].charge.value = parent.getChargeDef();
            document.forms[j].expense_1_purpose.value = thisPurpose;
            document.forms[j].expense_1_xref.value = document.forms[formStartNumber].xref.value;
            document.forms[j].rcpttype.value = "4";
            parent.UpdateReport('2','trans5',document.forms[j]);
            calculatedIndex += 1;
          }
        }
        if (document.forms[j].name == "screenMileage2") {
          if (!CheckZero(document.forms[j].amount) && !isNaN(parseFloat(document.forms[j].amount.value)) && !isNaN(parseFloat(document.forms[j].recamt.value))) {
            document.forms[j].expense_1_purpose.value = thisPurpose;
            document.forms[j].expense_1_expensetype.value = parent.getMileageType();
            document.forms[j].charge.value = parent.getChargeDef();
            document.forms[j].expense_1_purpose.value = thisPurpose;
            document.forms[j].expense_1_xref.value = document.forms[formStartNumber].xref.value;
            document.forms[j].rcpttype.value = "4";
            parent.UpdateReport('2','trans5',document.forms[j]);
            calculatedIndex += 1;
          }
        }
      // post expense grid transactions - throws out blanks
        if (document.forms[j].name == "screenReceipt") {
          if (!CheckZero(document.forms[j].amount) && (document.forms[j].amount.value != "")) {
            if (!isNaN(document.forms[j].amount.value)) parent.makeCurrency(document.forms[j].amount);
            setChargeValue(document.forms[j]);
            document.forms[j].expense_1_purpose.value = thisPurpose;
            document.forms[j].expense_1_xref.value = document.forms[formStartNumber].xref.value;
            document.forms[j].rcpttype.value = "3";
            parent.UpdateReport('2','trans1afxn',document.forms[j]);
            calculatedIndex += 1;
          }
        }
        if (document.forms[j].name == "screenPlaneReceipt") {
          if (!CheckZero(document.forms[j].amount) && (document.forms[j].amount.value != "")) {
            if (!isNaN(document.forms[j].amount.value)) parent.makeCurrency(document.forms[j].amount);
            setChargeValue(document.forms[j]);  //dup of the form init action jh 2011-05-06
            document.forms[j].expense_1_purpose.value = thisPurpose;
            document.forms[j].expense_1_xref.value = document.forms[formStartNumber].xref.value;
            document.forms[j].rcpttype.value = "3";
            parent.UpdateReport('2','trans1air',document.forms[j]);
            calculatedIndex += 1;
          }
        }
        
        if (document.forms[j].name == "screenHotel") {
          if (!CheckZero(document.forms[j].amount) && (document.forms[j].amount.value != "")) {
            if (!isNaN(document.forms[j].amount.value)) parent.makeCurrency(document.forms[j].amount);
            document.forms[j].charge.value = parent.getChargeDef();
            document.forms[j].purpose.value = thisPurpose;
            document.forms[j].xref.value = document.forms[formStartNumber].xref.value;
            document.forms[j].rcpttype.value = "3";
            parent.UpdateReport('2',parent.getHotelScreen(),document.forms[j]);
            calculatedIndex += 1;
            if (document.forms[j].setPointer.value == "Yes")
            {
               newListIndex = TailList.length - 1;
               newListBuffer = TailList[newListIndex][$items$];
          //     newListIndex = calculatedIndex;
          //     newListBuffer = TailList[calculatedIndex][$items$];
            }
          }
        }
        if (document.forms[j].name == "advanceEntry") {
          if (!CheckZero(document.forms[j].amount) && (document.forms[j].amount.value != "")) {
            if (!isNaN(document.forms[j].amount.value)) parent.makeCurrency(document.forms[j].amount);
            document.forms[j].charge.value = parent.getAdvanceDef();
            parent.UpdateReport('2','trans7',document.forms[j]);
            calculatedIndex += 1;
          }
        }
        if (document.forms[j].name == "returnEntry") {
          if (!CheckZero(document.forms[j].amount) && (document.forms[j].amount.value != "") ) {
            if (!isNaN(document.forms[j].amount.value)) parent.makeCurrency(document.forms[j].amount);
            document.forms[j].charge.value = parent.getReturnedDef();
            parent.UpdateReport('2','trans8',document.forms[j]);
            calculatedIndex += 1;
          }
        }
      }
      screenDupFlagOK = true;
      if (newListIndex != -1) {
         ListIndex = newListIndex;
         ListBuffer = newListBuffer;
      }
}


function isGoodReceipt(obj) {

   var expType;
   var typeObj;
   if (obj.expense_1_expensetype) {
      if (obj.expense_1_expensetype.type == "select-one") {
        expType = obj.expense_1_expensetype.options[obj.expense_1_expensetype.selectedIndex].value;
        typeObj = obj.expense_1_expensetype;
      } else {
        expType = obj.expense_1_expensetype.value;
        typeObj = obj.expense_1_expensetype;
      }
   } else {
     expType = obj.expense_1_expensetypename.options[obj.expense_1_expensetypename.selectedIndex].value;
     typeObj = obj.expense_1_expensetypename;
   }  
   var retVal = (isNotPostedReceipt(obj)          // CheckZero(amount) 
          || (CheckAmount(obj.amount)
          && Checkrecamt(obj.recamt) 
          && checkdate(obj.rcptdate)
          && doDateChkToday(obj.rcptdate)
          && CheckExpType(typeObj, obj.amount)
          && CheckAttendee(obj.expense_1_attendeelist, expType)
          && CheckComment(obj.expense_1_comment, expType))) 
   return retVal;        
}

function Checkrecamt(rcpt)
{
   if (rcpt == null || rcpt.value == null || rcpt.value == "")
   {
     return true;
   } else {
     return CheckAmount(rcpt);
   }
}



function isNotPostedReceipt(obj) {
 return (CheckZero(obj.amount) || (obj.amount.value == ""))
} 

function CheckAttendee(tag,expense) {
  var retVal = true;
  if (tag != null) {
    var Check = tag.value;
    var Xstr = parent.getAttendeeReq();
    if (Xstr.indexOf(";" + expense + ";") > -1 && Check.length < 3) {
      var workingString = getJSX("JSS_NEED_ATTS");
      alert(workingString.replace("$expense$",expense));
      retVal = false;
    } 
  }
  return retVal;
}

function checkPurpComment(object, msg) {
        if (object.value.length >= parent.getCommentLen()) {
                return true;
        } else {
                return false;
        }        
}

function resetLowerDate() {
 var startingDate = document.forms[formStartNumber].begdate.value;
 if (!isDateLess(startingDate, document.forms[formStartNumber].enddate.value)) {
     document.forms[formStartNumber].enddate.value = startingDate;
 }  
 if (useScreenDefaultDates) {  
    if (!isDateLess(startingDate, document.forms[formStartNumber + 1].rcptdate.value)) {  // advance
       document.forms[formStartNumber + 1].rcptdate.value = startingDate;
    }
    if (!isDateLess(startingDate, document.forms[formStartNumber + 2].rcptdate.value)) {  //return
       document.forms[formStartNumber + 2].rcptdate.value = startingDate;
    }
    for (var i = formStartNumber + 3; i < document.forms.length; i++) {                   //trans   
       if (!isDateLess(startingDate, document.forms[i].rcptdate.value)) {
          document.forms[i].rcptdate.value = startingDate;
       }   
    }
 }   
 parent.defDateStr = document.forms[formStartNumber].begdate.value;
}

function resetUpperDate() {
 var endingDate = document.forms[formStartNumber].enddate.value;
 if (useScreenDefaultDates) {
    if (!isDateLess(document.forms[formStartNumber + 1].rcptdate.value,endingDate)) {  // advance
       document.forms[formStartNumber + 1].rcptdate.value = endingDate;
    }
    if (!isDateLess(document.forms[formStartNumber + 2].rcptdate.value,endingDate)) {  //return
       document.forms[formStartNumber + 2].rcptdate.value = endingDate;
    }
    for (var i = formStartNumber + 3; i < document.forms.length; i++) {                   //trans 
       if (!isDateLess(document.forms[i].rcptdate.value,endingDate)) {
         document.forms[i].rcptdate.value = endingDate;
       } 
    }     
 }
}

function CheckExpType(tag1, tag2) {
        if (!CheckZero(tag2) && (tag1.selectedIndex == 0)) {
     alert(getJSX("JSS_SELECT"));
     tag1.focus();
     return false;
  } else {
     return true;
  }
}

function CheckZero(tag) {
  var Check = parseFloat(tag.value);
  if (Check == 0) {
     return true;
  } else {
     return false;
  }
}

function CheckAmount(tag) {
  return parent.checkAmtFldOK(tag);
}

var NeedComment = parent.getCommentReq();
function CheckComment(tag,expensetype) {
  if (tag) {
     var Check = tag.value;
     if (NeedComment.indexOf(";" + expensetype + ";") > -1 && Check.length < parent.getCommentLen()) {
        alert(getJSX("JSS_NEED_CMT"));
        tag.focus();
        tag.select();
        return false;
     } else {
        return true;
     }
  } else {
     return true;
  }
}

function calcBarterAmount(formObj) {
    // if (check the rec_amt is a good format with a reqular expresion and take an action if not - see comma and decimal conflict)
        var intAmount = parseFloat(returnStdNumFormat(formObj.recamt.value));
        var intRate = parseFloat(returnStdNumFormat(formObj.xrate.value));
        var totalAmt = intAmount * intRate;
        formObj.amount.value = totalAmt;
        makeCurrency(formObj.amount);
        amountVal(formObj.amount);
        return;
}
function checkXRate(formObj) {

        var newValue = returnStdNumFormat(formObj.xrate.value);
        if (isNumber(newValue)) {
                calcBarterAmount(mileage);
        } else {
                xRateAlert(formObj.xrate);
                return false;
        }
}

function xRateAlert(textObj) {
        alert(getJSX("JSS_INV_RATE"));
        textObj.focus();
        textObj.select();
}

function checkClientNo(x) {
  return parent.checkClientNo(x);
}


function LookupCleanup() {
  document.forms[0].clientLookup.selectedIndex = 0;
}

function fxCleanUp(lastFormObj) {  //Doesn't work - need to use the get name stuff.
        checkFCurrency(lastFormObj);
}

function checkFCurrency(lastFormObj){
        extraForm = getExtraRcptForm();
        extraForm.xrate.value = lastFormObj.xrate.value;
        extraForm.units.value = lastFormObj.units.value; 
        extraForm.ratetype.value = lastFormObj.ratetype.value; 
        extraForm.xsource.value = lastFormObj.xsource.value; 
        extraForm.xdate.value = lastFormObj.xdate.value;     
        var z = isEmpty(lastFormObj.xrate.value);
        setFgnProtected(z, 'recamt', 'amount', extraForm);  
        FXConvert('recamt', 'amount', true, extraForm); 
}
function getExtraRcptForm() {
  var hiddenReceipt = document.getElementById("extraReceipt");
  var formArray = hiddenReceipt.getElementsByTagName("form");
  return formArray[0];
}


function populateClient() {
  if (document.forms.screenPurpose.clientLookup.selectedIndex > -1) {
    document.forms.screenPurpose.clientno.value = document.forms.screenPurpose.clientLookup.options[document.forms.screenPurpose.clientLookup.selectedIndex].value;
    document.forms.screenPurpose.client.value = document.forms.screenPurpose.clientLookup.options[document.forms.screenPurpose.clientLookup.selectedIndex].text;
    var X = parent.getDBSingle(parent.PersDBase,"client","clientno",document.forms.screenPurpose.clientno.value);
    var Y;
    if (X[0] && X[0].length != null) {
    for (var i = 0; i < X[0].length; i++) {
      Y = X[0][i][0];
      if(Y == "location") {
        document.forms.screenPurpose.location.value = X[0][i][1];
      }
    }
    }
//    document.forms.screenPurpose.clientLookup.selectedIndex = 0;
  }
}   

function populateLocation() {
  with (document.forms.screenPurpose) {
    if (( locationname) && locationname.selectedIndex > -1) {  
      location.value = locationname.options[locationname.selectedIndex].text;
//      locationname.selectedIndex = 0;
    }
  }
}

function populateProject() {
  if (document.forms.screenPurpose.projectname.selectedIndex > -1) {
    var projNum = document.forms.screenPurpose.projectname.options[document.forms.screenPurpose.projectname.selectedIndex].value;
    document.forms.screenPurpose.project.value = projNum;
    var X = parent.getDBSingle(parent.PersDBase,"file","project",projNum);
    var Y;
    if (X[0] && X[0].length != null) {
      for (var i = 0; i < X[0].length; i++) {
        Y = X[0][i][0];
        if(Y == "clientno") {
            document.forms.screenPurpose.clientno.value = X[0][i][1];
            i = X[0].length;
        }
      }
    } else {
      var DB = parent.getProjectNos();
      if (DB.length > 0) {
         for (var i = 1; i < DB.length; i++) {
            if (DB[i][0] == projNum && DB[i][2].length > 1) {
                document.forms.screenPurpose.clientno.value = DB[i][2];
                i = DB.length;
            }
         }
      }
    }
    
    if (document.forms.screenPurpose.clientno.value != "") {
      for (var i = 0; i < document.forms.screenPurpose.clientLookup.options.length; i++) {
         if (document.forms.screenPurpose.clientno.value == document.forms.screenPurpose.clientLookup.options[i].value) {
            document.forms.screenPurpose.clientLookup.selectedIndex = i;
            populateClient();
            i = document.forms.screenPurpose.clientLookup.options.length;
         }
      }
    }
//    document.forms.screenPurpose.projectname.selectedIndex = 0;
  }
}   

function odometerTrigger (milesObj)
{
        var intBegin = parseFloat(returnStdNumFormat(milesObj.refer.value));
        var intEnd = parseFloat(returnStdNumFormat(milesObj.offset.value));
        if (intEnd > intBegin) {
          var totalMiles = intEnd - intBegin;
          milesObj.recamt.value = totalMiles;
          makeCurrency(milesObj.recamt);
          amountVal(milesObj.recamt);
          milesObj.recamt.onchange();
		  milesObj.msgback.value = "Amount added to total";
        } else {
          milesObj.recamt.value = "";
          milesObj.amount.value = "";
		  milesObj.msgback.value = "";
        }
		milesObj.xsource.focus();
        return;
}

function milesValueOK(xx) {
    // xx is the element
	var retVal = false;
	if (isNotPostedReceipt(xx)) {
		retVal = true;
	} else {
		var amt1 = new parent.oNumber(xx.recamt.value);   //located in xshared2.js
		var amt2 = new parent.oNumber(format(xx.recamt.value,2));
		if (amt1.parseFloat() == amt2.parseFloat()) {
   			retVal = true;
   		} else {
   			alert(getJSX("JS2_NUMERIC"));
   			xx.recamt.focus();
   		}
   	}
   	return retVal;	
}



function CheckMilesOK(xx) {
  var retval = true;
  if (false)  {      //need a cnfig flag 
  if (!CheckZero(xx.amount) 
     && !isNaN(parseFloat(returnStdNumFormat(xx.amount.value))) 
     && !isNaN(parseFloat(returnStdNumFormat(xx.recamt.value)))) {
   if ( xx.xsource.value.length < 2) {
     retval = false;
     alert(getJSX("JSS_FROM_REQ"));
     xx.xsource.focus();
   } else if (xx.expense_1_comment.value.length < 2) {
     retval = false;
     alert(getJSX("JSS_TO_REQ"));
     xx.expense_1_comment.focus();
   }
  }
  }
  return retval;
}

function setChargeValue(obj) {
   var expType;
   if (obj.expense_1_expensetype) {
      if (obj.expense_1_expensetype.type == "select-one") {
        expType = obj.expense_1_expensetype.options[obj.expense_1_expensetype.selectedIndex].text;
      } else {
        expType = obj.expense_1_expensetype.value;
      }
   } else {
     expType = obj.expense_1_expensetypename.options[obj.expense_1_expensetypename.selectedIndex].value;
   } 
   var y = obj.charge.value;
   var retVal = true;
   var dedicated = parent.getDBValue(parent.getDedicatedMethod("1"), expType);
   if (dedicated != "") { 
     obj.charge.value = dedicated; 
   } else {
     obj.charge.value = parent.getChargeDef();
   }   
}     


var screenItems = 3;

function AddReceiptAutomatic(currentRcpt) {
  // if (isGoodReceipt(currentRcpt)) {
    if ((currentRcpt.persistance) && (currentRcpt.persistance.value == "New")) {
      currentRcpt.persistance.value = "";
      if (isTabKey) AddRcptViaLink(true);
    }
  //}
  isTabKey = false;
}

function AddRcptViaLink(giveFocus) {
  if (giveFocus == null) giveFocus = true;
  var x = AddReceiptLine();
  x.persistance.value = "New";
  if (giveFocus) x.rcptdate.focus();
}

function AddReceiptLine() {
  var div = document.getElementById("receiptSection");
  var button = document.getElementById("addReceipt");
  screenItems++;
  var hiddenReceipt = document.getElementById("extraReceipt");
  var newItem = hiddenReceipt.cloneNode(true);
  newItem.style.display="";
  div.insertBefore(newItem,button);
  var formArray = newItem.getElementsByTagName("form");
  if (formArray[0].locationname) parent.setListDfltWVal(formArray[0].locationname,parent.getDefaultLocation());
  if (formArray[0].merchant && formArray[0].merchant.type == "select-one") {
     MerchantType = "merchant";
     var merchArray = parent.getMerchants("1");
     var mArray = merchArray.concat(parent.getDBResult(parent.PersDBase,MerchantType));
     formArray[0].merchant.length = 0;
     parent.setList(formArray[0].merchant, mArray.sort());
  } 
  return formArray[0];
}

function AddPlaneRcptViaLink(giveFocus) {
  if (giveFocus == null) giveFocus = true;
  var x = AddPlaneReceiptLine();
  x.persistance.value = "New";
  if (giveFocus) x.rcptdate.focus();
}
function AddPlaneReceiptLine() {
  var div = document.getElementById("planeSection");
  var button = document.getElementById("addReceiptPlane");
  screenItems++;
  var hiddenReceipt = document.getElementById("extraPlaneReceipt");
  var newItem = hiddenReceipt.cloneNode(true);
  newItem.style.display="";
  div.insertBefore(newItem,button);
  var formArray = newItem.getElementsByTagName("form");
  setChargeValue(formArray[0]);
  if (formArray[0].locationname) parent.setListDfltWVal(formArray[0].locationname,parent.getDefaultLocation());
  if (formArray[0].offsetname) parent.setListDfltWVal(formArray[0].offsetname,parent.getDefaultLocation());
  return formArray[0];
}

function AddHotelLine() {
  var div = document.getElementById("receiptSection");
  var button = document.getElementById("addReceipt");
  screenItems++;
  var hiddenReceipt = document.getElementById("extraHotel");
  var newItem = hiddenReceipt.cloneNode(true);
  newItem.style.display="";
  div.insertBefore(newItem,button);
  var formArray = newItem.getElementsByTagName("form");
  formArray[0].expenselist.setAttribute("subtype","hiddenlist");  //for Mozilla
  return formArray[0];
}

function getPurposeLine() {
  var xForm = document.getElementById("screenPurpose");
  return xForm;
}

function setTabKey(e) {
    var code;
    if (!e) {  // no e = ie, e = mozilla standard
       var e = window.event;
    }   
	if (e.keyCode) code = e.keyCode;
	else if (e.charCode) code = e.charCode;
	if (code == 9) isTabKey = true;
}
var isTabKey = false;

function AddMilesAutomatic(currentMiles) {
   if (CheckMilesOK(currentMiles) && checkdate(currentMiles.rcptdate)) {
      if ((currentMiles.persistance) && (currentMiles.persistance.value == "New")) {
         currentMiles.persistance.value = "";
         if (isTabKey) AddMilesViaLink(true);
     }    
   }
   isTabKey = false;
}

function AddMilesViaLink(giveFocus) {
  if (giveFocus == null) giveFocus = true;
  var x = AddMileageLine();
  x.persistance.value = "New";
  if (giveFocus) x.rcptdate.focus();
}

function AddMileageLine() {
  var div = document.getElementById("mileageSection");
  var button = document.getElementById("addMileage");
  screenItems++;
  var hiddenReceipt = document.getElementById("extraMileage");
  var newItem = hiddenReceipt.cloneNode(true);
  newItem.style.display="";
  div.insertBefore(newItem,button);
  var formArray = newItem.getElementsByTagName("form");
  formArray[0].xrate.value = returnMyNumFormat(parent.getMileageDefault());
  //formArray[0].xrate.readOnly = parent.getMileageReadOnly();
  formArray[0].units.value = parent.getDistanceUnit();
  formArray[0].expense_1_billtype.value = "No";
  if (formArray[0].locationname) parent.setListDfltWVal(formArray[0].locationname,parent.getDefaultLocation());
  if (formArray[0].mileageLabel) formArray[0].mileageLabel.value = parent.getDistanceUnitXlation();
  
  return formArray[0];
}

function ShowAdvanceLine() {
   var advanceForm = document.forms.advanceEntry;
   showDataFields('advanceSection');
   return advanceForm;
}

function ShowReturnLine() {
   var returnForm = document.forms.returnEntry;
   showDataFields('advanceSection');
   return returnForm;
}

function removeThisForm(thisForm) {
   if (confirm(getJSX("JSS_DELETE_LINE"))) {
      thisForm.parentNode.removeChild(thisForm);
      printTotals();
   }
}

function removeEmpties(defaultType, n) {
  if (n > 0) {
    var elem = document.getElementById(defaultType);
    elem.parentNode.removeChild(elem);
  }
}

function screenLoad() {
Log.println("screen.js","screenLoad");
   FillForm();
   myESSMenu.setNewReport();
   if (document.getElementById("mileageLabel")) document.getElementById("mileageLabel").innerHTML = parent.getDistanceUnitXlation();
   if (document.getElementById("currencyLabel")) document.getElementById("currencyLabel").innerHTML = parent.getCurrencyLabel();
   ListMemory();
   removeEmpties("defaultMileage",numberMileageLines);
   removeEmpties("defaultReceipt",numberReceiptLines);
   removeEmpties("defaultPlaneReceipt",numberPlaneReceiptLines);
//   if (document.forms[formStartNumber].project.value.length > 0) 
//   {
//       showDataFields("projectEntry");
//   }
//   if ((document.forms[formStartNumber].client.value.length > 0) 
//      || (document.forms[formStartNumber].clientno.value.length > 0)) 
//   {
//       showDataFields("clientNoEntry","ClientNameEntry");
//   }
   document.getElementById("reportUsersReference").innerHTML =  parent.getNameValue(parent.Header,"reference");

   printTotals();
   //parent.myESSMenu.setReport();
   if (parent.SetReportIsSaved) {
       parent.ReportIsSaved = true;
       parent.SetReportIsSaved = false;
   }
   return true;
}

var cancelThisRequest = "";
function screenUnload() {
Log.println("screen.js","screenUnload: " + cancelThisRequest );
  var retVal; 
  if (cancelThisRequest != "DoNotPost") {
     retVal = SubmitRec("Post");
  } else {
     retVal = SubmitRec("DoNotPost");
  }
  cancelThisRequest = "";
  if (retVal) parent.myESSMenu.setMenu();    //Temporary - each screen should set its own menu
  return retVal;
}

function cancelThisReport() {
  if (confirm(getJSX("JSS_CANCEL"))) {
     cancelThisRequest = "DoNotPost";
     // parent.ReportIsSaved = true;
     // parent.SetReportIsSaved = false;
     screenUnload();
     document.getElementById("main").innerHTML = "<p><h2>" + getJSX("JSS_CANCEL_DONE") + "</h2></p>";
     switchScript("shared/blank.js");
  }
}

function editHotelEntry(setIndex) {
  if (checkPurpComment(document.forms[formStartNumber].comment)) {
    //load list here.
    setIndex.value =  "Yes";
    parent.loadHTMLScreenAJAX(parent.getHotelScreen()); 
  } else {
    alert(getJSX("JSS_HOTEL_EDIT"));
  }  
}

function loadHotelWizard() {
  if (checkPurpComment(document.forms[formStartNumber].comment)) {
    parent.loadHTMLScreenAJAX(parent.getHotelScreen()); 
  } else {
    alert(getJSX("JSS_HOTEL_CREATE"));
  }  
}  

function showDataFields() {
  var reportElement;
  for (var i = 0; i < arguments.length; i++){
     reportElement = document.getElementById(arguments[i]);
     if (reportElement != null) reportElement.style.display="";
  }   
}

function hideDataFields() {
  var reportElement;
  for (var i = 0; i < arguments.length; i++){
     reportElement = document.getElementById(arguments[i]);
     if (reportElement != null) reportElement.style.display="none";  //added by JH Nov-8-2011
  }   
}

function printTotals() {
  var mStart = 2;
  var reportTotal = 0;
  var nonReimb = 0;
  var advance = 0;
  var returnChk = 0;
  for (var i = formStartNumber + mStart; i < document.forms.length; i++)
  {
     with(document.forms[i]) {
        if (!isNaN(parseFloat(returnStdNumFormat(amount.value)))) {
           reportTotal += parseFloat(returnStdNumFormat(amount.value));
           nonReimb += nonReimbAmt(document.forms[i]);
        }
     }   
  }
  if (!isNaN(parseFloat(document.forms[formStartNumber + 1].amount.value))) advance = parseFloat(returnStdNumFormat(document.forms[formStartNumber + 1].amount.value));
//  if (!isNaN(parseFloat(document.forms[formStartNumber + 2].amount.value))) returnChk = parseFloat(returnStdNumFormat(document.forms[formStartNumber + 2].amount.value));
  
  var htmlReportTotal = format(returnMyNumFormat(reportTotal),2);
  var htmlNonReimbAdvance = format(returnMyNumFormat((nonReimb + advance)),2);
  var htmlReturnChk = format(returnMyNumFormat(returnChk),2);
  var htmlReportTotalreturnChk = format(returnMyNumFormat(((reportTotal + returnChk) - (nonReimb + advance))),2);

  document.getElementById("reportTotal").innerHTML = htmlReportTotal;
  document.getElementById("nonReimbAdvance").innerHTML = htmlNonReimbAdvance;
//  document.getElementById("returnChk").innerHTML = htmlReturnChk;
  document.getElementById("reportTotalreturnChk").innerHTML = htmlReportTotalreturnChk;
  
//  reportTotal
  
}

function nonReimbAmt(obj) {
  var otherPersonal = 0;
  var x;
  with(obj) {
    if (getReimburseReq().indexOf(charge.value) == -1) {
       otherPersonal = parseFloat(returnStdNumFormat(amount.value));
    } else {
       if (obj.expenselist) {
          x = eval(expenselist.value);
          otherPersonal = getTotalValueFor(x,'amount','expensetype',getPersonalReq());
       }

    }  
  }
  return otherPersonal;
}

function expTypeChange(obj) {
    setChargeValue(obj);
    printTotals();
}


function onOff(tag, state){			
	document.getElementById(tag).id=state;
}

function getProperFgnRate(xform) {
     xform.xrate.value = returnMyNumFormat(parent.getMileageDefault(xform.rcptdate.value));
     calcBarterAmount(xform);
}

// ****


