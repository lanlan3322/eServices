
// trans12fxn.js - flexible hotel, fx, no billing with protected purpose
// Copyright (C) 2004,2010 R. James Holton

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

function FillForm() {
  if (parent.HeadList.length > 0) {

    document.forms[formStartNumber].expenselist.subtype = "list";  //needed for Mozilla
    document.forms[formStartNumber].expense_2_attendeelist.subtype = "nosave";
    document.forms[formStartNumber].expense_2_persplit.subtype = "nosave";
    document.forms[formStartNumber].expense_2_expdate.subtype = "nosave";
    document.forms[formStartNumber].expense_2_expensetype.subtype = "nosave";
    document.forms[formStartNumber].expense_2_billtype.subtype = "nosave";
    document.forms[formStartNumber].expense_2_amount.subtype = "nosave";
    document.forms[formStartNumber].expense_2_recamt.subtype = "nosave";
    document.forms[formStartNumber].expense_2_comment.subtype = "nosave";

    MerchantType = "location";
//    parent.setListWithPers(document.forms[formStartNumber].location, parent.getLocations("1"),MerchantType);
    parent.setListWithValue(document.forms[formStartNumber].locationname, parent.getLocation4Trvl("1"),0,1,false,true,1);
    parent.setListDfltWVal(document.forms[formStartNumber].locationname,parent.getDefaultLocation());
    parent.setListWithValue(document.forms[formStartNumber].refername,parent.getProjectNos("1"),0,1,true,true);

    document.forms[formStartNumber].charge.value = parent.getChargeDef();

//    var expArray = parent.getExpenseTypes(parent.Category);
//    parent.setList(document.forms[formStartNumber].expense_2_expensetype, expArray.concat(parent.getInclude("hotel")),parent.getLodgingExc() + ";");
    
    parent.setListWithTranslation(document.forms[formStartNumber].expense_2_expensetype, parent.getExpense4Hotel());  


    document.forms[formStartNumber].expense_1_persplit.value = "1";
    
    MerchantType = "hotel"
    var merchArray = parent.getMerchants("4");
    var mArray = merchArray.concat(parent.getDBResult(parent.PersDBase,MerchantType));
    parent.setList(document.forms[formStartNumber].merchant, mArray.sort());
    
    var index = 0
    var headArray = parent.getArrayFromHead(index,parent.getList4Head());
    var thisPurpose = headArray[0];
    var this_xref = headArray[1];
    document.forms[formStartNumber].purpose.value = thisPurpose;
    document.forms[formStartNumber].xref.value = this_xref;
    //parent.setDefaultFromHead(document.forms[formStartNumber].purpose);
    popDates();
    parent.setTransaction(document.forms[formStartNumber]);

    //reseting the itemized expenses
    var DD;
    var xStr;
    var fields;
    var x;
    for (var y = 0; y < document.forms[formStartNumber].expenselist.length; y++) {
       DD = "";
       xStr = "";
       x = eval(document.forms[formStartNumber].expenselist.options[y].value);
       fields = x[1];
       disp = parent.getListDisplay("expenselist");
       for (var i = 0; i < disp.length; i++) {
          if (disp[i] == "expensetype") {  //cluche for translation work
             xStr += DD + parent.getNameValue(parent.getExpense4Hotel(),parent.getNameValue(fields,disp[i]));
          } else {   
             xStr += DD + parent.getNameValue(fields,disp[i]);
          }
          DD = ": ";
       }
       document.forms[formStartNumber].expenselist.options[y].text = xStr;
    }      

    setFXFormObj(document.forms[formStartNumber]);
    if (parent.isNew()) {  //changed 7/4/2002 
      defCurrency();
    } else {
      setFgnProtected(isEmpty(document.forms[formStartNumber].xrate.value));
    }
    fxCleanUp();
    resetDates(); 
    document.forms[formStartNumber].amount.focus();
  } else {
    alert("You must specify a purpose first, then choose hotel receipt again.");
    parent.ListMemory();
  }
}
function calcLodging(formObj) {
        var recAmt = ChkTotal1(formObj.amount.value);
        var exp2Amt = getTotals(formObj.expenselist,"amount");
        var workNum = Math.round(100 * (recAmt - exp2Amt));
        formObj.expense_1_amount.value = workNum / 100;
        return;
}

function getTotals(yListObj, zItemName) {
  var Sum = 0;
  var x;
  for (var i = 0; i < yListObj.length; i++) {
    x = eval(yListObj.options[i].value);
    Sum = Sum + parseFloat(parent.getNumericValue(x,zItemName));
  }
  return Sum;
}

function SubmitRec(xPost) {
  if (xPost == null) xPost = "Post";
  var retVal = true;
  with (document.forms[formStartNumber]) {
   rcptdate.value = enddate.value;
   expense_1_expdate.value = enddate.value;
   expense_1_expensetype.value = parent.getLodgingDef(parent.Category);  
   subtype.value = "1";
   if ((xPost == "Post") && CheckRoomAmount(amount)
      && checkdate(begdate)
      && checkdate(enddate)
      && doDateCheck(begdate.value,enddate.value)
      && doDateChkToday(enddate)
      && CheckAmount(expense_1_persplit)
      && CheckTotals()
      && CheckPerSplit()
      && CheckDedicated(expense_1_expensetype, charge)) {
      if (!isNaN(amount.value)) parent.makeCurrency(amount);

      ChkExtra2(expense_1_expensetype,expense_1_amount,expense_1_billtype);
      calcRoomAmt(document.forms[formStartNumber])
      if (ChkExtra1(expense_1_amount,expense_1_expensetype,expense_1_expdate,expense_1_comment)) parent.makeCurrency(expense_1_amount);
 
      if (expense_1_amount.value == null || expense_1_amount.value == "") {
          expense_1_amount.value = "0.00";  //allows zero hotel items through - parameterize
      } 

 
      if (CheckTotals()) {
        parent.UpdateReport('2','trans12fxnj',document.forms[formStartNumber]);
        // parent.ListDelay(); removed by jh 2012-06-28
      } else {
        alert("Hotel bill is out of balance - please review it.");  //12/13/02
        retVal = false;
      }
    } else {
      if (xPost = "Post") {
         retVal = false;
      } else {
        if (!confirm("Are you sure you want to cancel this entry?")) {
           retVal = false;
        }
      }        
    } 
  }
  return retVal;
}

function CheckPerSplit() {
  var retVal = true;
  var checkString = "12345678";
  with (document.forms[formStartNumber]) {
    if (expense_1_persplit.value.length == 1 && checkString.indexOf(expense_1_persplit.value) > -1) {
        if (expense_1_persplit.value != "1" && expense_1_comment.value.length < 5) {
           alert("If # persons is not 1, enter name of extra individual in comment box!");
           retVal = false;
           expense_1_persplit.focus();
        }
    } else {
        alert("The number of people must be a whole number between 1 and 8.");
        retVal = false;
        expense_1_persplit.focus();
    }
  }
  return retVal;
}

function doCheapCheck(x) {
//alert("step: " + x);
return true;
}

function CheckTotals(formObj) {
   formObj = document.forms[formStartNumber];
   var recAmt = ChkTotal1(formObj.amount.value);
   var exp1Amt = ChkTotal1(formObj.expense_1_amount.value);
   var exp2Amt = getTotals(formObj.expenselist,"amount");
   var expAmt = exp1Amt + exp2Amt;
   if (recAmt - expAmt < 0.005 && expAmt - recAmt < 0.005) {
     if (exp1Amt >= 0) {    // was just > (allows zero hotel items through - parameterize)
        return true;
     } else {
        alert("Room amount must be greater than zero")
        return false;
     }
   } else {
     alert("Receipt is out of balance by " + (recAmt - (exp1Amt + exp2Amt)));
     return false;
   } 
}

function ChkTotal1(v1) {
  if (isNaN(v1) || v1 == "") {
    return 0;
  }else{
    return Number(v1);
  }
}

function ChkExtra1(o1,o2,o3,o4) {
  if (isNaN(o1.value) || parent.rtrim(o1.value) == "" || o1.value == 0) {
    o1.value = "";
    o2.selectedIndex = 0;
    o3.value = "";
    o4.value = "";
    return false;
  } else {
    return true;
  }
}
// eventually combine these 2 functions 12/13/02
function ChkExtra2(o1,o2,o3,o4,o5) {
  if (o1.selectedIndex == 0 || isNaN(o2.value) || parent.rtrim(o2.value) == "" || o2.value == 0) {
    o2.value = "";
    o3.value = "";
    if (o4 != null) o4.value = "";
    if (o5 != null) o5.value = "";
  }
}

function CheckDedicated(expObj, chgObj) {
  var x = expObj.value;
  var y = chgObj.value;
  var retVal = true;
  var dedicated = parent.getDBValue(parent.getDedicatedMethod("1"), x);
  if (dedicated != "" && y != dedicated) { 
    retVal = false;
    alert("Invalid payment method " + y + " for expense type " + x + ". Need to use " + dedicated + ".");
  } else {
    if (y != dedicated && parent.getDBValue(parent.getDedicatedMethod("1"), y,0,1) > "") {
      retVal = false;
      alert("Payment method " + y + " cannot be used for expense type " + x + ".");
    }
  }  
  return retVal;
}  

function ChkBtween(xType,rdateObj) {

  if (xType.selectedIndex != 0) {
    //alert("from: " + document.forms[formStartNumber].begdate.value);
    //alert("to: " + document.forms[formStartNumber].enddate.value);
    //alert("rcpt: " + rdateObj.value);
    if (doBetweenChk(rdateObj.value,document.forms[formStartNumber].begdate.value,document.forms[formStartNumber].enddate.value)) {
      return true;
    } else {
      rdateObj.focus();
      return false;
    } 
  } else {
    return true;
  }
}

function CheckAttendee(tag,expense) {
  var retVal = true;
  if (expense.length > 0) {
    var Check = tag.value;
    var Xstr = parent.getAttendeeReq();
    if (Xstr.indexOf(";" + expense + ";") > -1 && Check.length < 3) {
      alert("Need to supply attendee list for " + expense + " expense");
      retVal = false;
    }
  }
  return retVal;
}

function CheckRoomAmount(tag) {
  if (isNaN(tag.value)) {
     alert("Data in the Amount field is not a valid numeric value");
     tag.focus();
     tag.select();
     return false;
  } else {
    var Check = parseFloat(tag.value);
    if (Check < .00 || Check >= 30000 || ("" + Check) == "NaN") {
      alert("Amount is invalid.");
      tag.focus();
      tag.select();
      return false;
    } else {
      return true;
    }
  }
}

function CheckAmount(tag, xType) {
  return parent.checkAmtFldOK(tag, xType);
}

function CheckExpType(object) {
  if (object.selectedIndex == 0) {
     alert("An Expense Type is required.");
     object.focus();
     return false;
  }  else {
          return true;
  }
}

var NeedComment = parent.getCommentReq();
function CheckComment(tag,expensetype) {
  var Check =  parent.alltrim(tag.value);
  var CmtLen = parent.getCommentLen();
  var StrV = expensetype.options[expensetype.selectedIndex].value;
  if (StrV != null && StrV != "" && NeedComment.indexOf(";" + StrV + ";") > -1 && Check.length < CmtLen) {
     alert("Need to supply a comment of at least " + CmtLen + " characters");
     tag.focus();
     return false;
  } else {
     return true;
  }
}


function CheckRequired(tag,expense,validation, msgtext) {
  var Check = "";
  var n = false 
  var CmtLen = parent.getCommentLen();
  expense = ";" + expense + ";";
  if (validation.indexOf(expense) > -1) {
    if (tag.type.indexOf("select") == 0) {
      Check = tag.options[tag.selectedIndex].value;
      if (Check.length > 2) n = true;     
    } else { 
      Check =  parent.alltrim(tag.value);
      if (Check.length >= CmtLen) n = true;
    } 
    if (!n) {
      alert(msgtext);
      tag.focus();
      return false;
    } else {
      return true;
    }
  } else {
     return true;
  }
}

function resetDates() {    
  with (document.forms[formStartNumber]) {
    if (!isDateLess(expense_2_expdate.value, enddate.value)) expense_2_expdate.value = enddate.value;
  }
}

function doubleChk(x) {
  if (checkdate(x)) resetDates();
}

function loadExpense() {
  with (document.forms[formStartNumber]) {  
   if (expenselist.selectedIndex > -1) {
     blankExpense();
     var dBase = eval(expenselist.options[expenselist.selectedIndex].value);
     dBase1 = dBase[1];
     expense_2_expdate.value = parent.getDBValue(dBase1, "expdate");
     parent.setListDfltWVal(expense_2_expensetype,parent.getDBValue(dBase1, "expensetype"));
     expense_2_amount.value = parent.getDBValue(dBase1, "amount");
     expense_2_recamt.value = parent.getDBValue(dBase1, "recamt");
     expense_2_comment.value = parent.getDBValue(dBase1, "comment");
     var x = parent.getDBString(dBase1, "attendeelist",[])
     if (typeof(x) == "string") {
       expense_2_attendeelist.value = x; 
     } else {   
       expense_2_attendeelist.value = parent.setArray2Str(x);
     }
     expense_2_persplit.value = parent.getDBValue(dBase1, "persplit");
     expense_2_billtype.value = "No";
   }
  }
}

function newExpense() {
  with (document.forms[formStartNumber]) {  
   if (expenselist.selectedIndex > -1) {
     blankExpense();
     expenselist.selectedIndex = -1;
   }
  }
}

function blankExpense() {
 with (document.forms[formStartNumber]) {
   //expense_2_expdate.value = begdate.value; 
   expense_2_expensetype.selectedIndex = 0;
   expense_2_amount.value = "";
   expense_2_recamt.value = "";
   expense_2_comment.value = "";
   expense_2_attendeelist.value = "[]";
   expense_2_billtype.value = "No";
   expense_2_persplit.value = "1";
 }
}


function removeExpense() {
  with (document.forms[formStartNumber]) {  
    if (expenselist.selectedIndex > -1) {
      var y = expenselist.length;
      for (var i = expenselist.selectedIndex; i < y - 1; i++) { 
        expenselist.options[i].text = expenselist.options[i + 1].text;
        expenselist.options[i].value = expenselist.options[i + 1].value;
      }
      expenselist.length = y - 1;
      newExpense();
      calcLodging(document.forms[formStartNumber]);
      //****CheckAmountAndDisburse(amount,expenselist,"amount",expense_1_disburse);
    }
  }
}

function addExpense() {
 with (document.forms[formStartNumber]) { 
  if (CheckAmount(expense_2_amount, expense_2_expensetype.options[expense_2_expensetype.selectedIndex].value)
      && CheckFGNAmount(expense_2_recamt)
      && CheckExpType(expense_2_expensetype)
      && checkdate(expense_2_expdate)
      && CheckAttendee(expense_2_attendeelist, expense_2_expensetype.options[expense_2_expensetype.selectedIndex].value)
      && ChkBtween(expense_2_expensetype,expense_2_expdate)
      && CheckComment(expense_2_comment,expense_2_expensetype)) {
     
    if (ChkExtra1(expense_2_amount,expense_2_expensetype,expense_2_expdate,expense_2_comment)) parent.makeCurrency(expense_2_amount);
    ChkExtra2(expense_2_expensetype,expense_2_amount,expense_2_billtype,expense_2_persplit,expense_2_attendeelist);
      

    var dBase
    var dBase1
 
    if (expenselist.selectedIndex == -1) {
        dBase = ["expense",[]]
    } else {
        dBase = eval(expenselist.options[expenselist.selectedIndex].value);
    }
    dBase1 = dBase[1];
    //if (!isNaN(recamt.value)) parent.makeCurrency(expense_2_recamt);
    parent.makeCurrency(expense_2_amount);
    parent.setDBPair(dBase1, "expdate",expense_2_expdate.value);
    parent.setDBPair(dBase1,"expensetype",expense_2_expensetype.options[expense_2_expensetype.selectedIndex].value);
    parent.setDBPair(dBase1, "amount",expense_2_amount.value);
    parent.setDBPair(dBase1, "recamt",expense_2_recamt.value);
    parent.setDBPair(dBase1, "comment",expense_2_comment.value);
    if (expense_2_attendeelist.value == null) alert("attendeelist error\ncontact support");//expense_2_attendeelist.value = "[]";
    parent.setDBPair(dBase1, "attendeelist",eval(expense_2_attendeelist.value));
    parent.setDBPair(dBase1,"billtype",expense_2_billtype.value);
    parent.setDBPair(dBase1,"persplit",expense_2_persplit.value);

    dBase[1] = dBase1;
    if (expenselist.selectedIndex == -1) {
      var j = expenselist.length;
      expenselist.length = j + 1;
      expenselist.selectedIndex = j;
    } 
    expenselist.options[expenselist.selectedIndex].value = parent.setArray2Str(dBase);
    var DD = "";
    var xStr = "";
    var x = parent.getListDisplay("expenselist");
    for (var i = 0; i < x.length; i++) {
      if (x[i] == "expensetype") {  //cluche for translation work
         xStr += DD + expense_2_expensetype.options[expense_2_expensetype.selectedIndex].text;
      } else {   
         xStr += DD + parent.getNameValue(dBase1,x[i]);
      }
      DD = ": ";
    }
    expenselist.options[expenselist.selectedIndex].text = xStr;
    calcLodging(document.forms[formStartNumber]);
    //***CheckAmountAndDisburse(document.forms[formStartNumber].AMOUNT,document.forms[formStartNumber].expenselist,"AMOUNT",document.forms[formStartNumber].expense_1_disburse);
  
    newExpense();
    expense_2_expdate.focus();

  }
 } 
}

function fxCleanUp() {
   adjListFX(document.forms[formStartNumber].expenselist);
   fgnLodging(document.forms[formStartNumber]);
   checkCurrency('recamt','amount');
   checkCurrency('expense_2_recamt','expense_2_amount');
}

function adjListFX(listObj) {
  var x;
  var fields;
  var y_amt;
  var z_rec;
  var DD;
  var xStr;
  var disp;
  var thisForm = document.forms[formStartNumber];
  if (thisForm.elements[FXFormNames[1]].value != null && thisForm.elements[FXFormNames[1]].value != "" && thisForm.elements[FXFormNames[2]].value != "") {
    if (!isEmpty(document.forms[formStartNumber].recamt) && !isEmpty(document.forms[formStartNumber].amount)) {   
      for (var k = 0; k < listObj.length; k++) {
        if (listObj.options[k].value != null) {
          x = eval(listObj.options[k].value);
          fields = x[1];
          y_amt = parent.getDBValue(fields, "amount");
          z_rec = parent.getDBValue(fields, "recamt");
          if (thisForm.elements[FXFormNames[2]].value == "0") { 
            y_amt = parseFloat(z_rec) / parseFloat(thisForm.elements[FXFormNames[1]].value);
          } else {
            y_amt = parseFloat(z_rec) * parseFloat(thisForm.elements[FXFormNames[1]].value);
          }  
          y_amt = parent.numberFormat(y_amt,2);
          parent.setDBPair(fields, "amount", "" + y_amt);        
          x[1] = fields;        
          listObj.options[k].value = parent.setArray2Str(x);
        
          DD = "";
          xStr = "";
          disp = parent.getListDisplay("expenselist");
          for (var i = 0; i < disp.length; i++) {
             if (disp[i] == "expensetype") {  //cluche for translation work
                xStr += DD + parent.getNameValue(parent.getExpense4Hotel(),parent.getNameValue(fields,disp[i]));
             } else {   
                xStr += DD + parent.getNameValue(fields,disp[i]);
             }
             DD = ": ";
          }
          listObj.options[k].text = xStr;
        }
      }
    }
  }
}

function checkCurrency(x,y) {
        var z = isEmpty(document.forms[formStartNumber].xrate.value)
        setFgnProtected(z, x, y, document.forms[formStartNumber]);  //JH 2010-06-24
        FXConvert(x, y, true, document.forms[formStartNumber]);     //JH 2010-06-24
}

function fgnLodging(formObj) {
        calcRoomAmt(formObj);
        FXConvert('expense_1_recamt', 'expense_1_amount');
        document.forms[formStartNumber].expense_2_recamt.readOnly = false;
        document.forms[formStartNumber].expense_2_amount.readOnly = true;
}

function calcRoomAmt(formObj) {
        var locAmt = ChkTotal1(formObj.recamt.value);
        var exp2Amt = getTotals(formObj.expenselist,"recamt");
        var workNum = Math.round(100 * (locAmt - exp2Amt));
        formObj.expense_1_recamt.value = workNum / 100;
}


function popDates() {
  with (document.forms[formStartNumber]) {  
      begdate.value = parent.getItemValue(parent.HeadList[0], "begdate");
      enddate.value = parent.getItemValue(parent.HeadList[0], "enddate");
      expense_2_expdate.value = begdate.value;
  }
}

function launchAttendees() {
 with (document.forms[formStartNumber]) {
  if (CheckAmount(expense_2_amount)
      && CheckExpType(expense_2_expensetype)) {
    initAttendeeList(document.forms[formStartNumber].expense_2_attendeelist,document.forms[formStartNumber].expense_2_persplit,document.forms[formStartNumber].expense_2_expensetype); 
    top.newWin = window.open('/ess/' + parent.language + '/attendee3c.html', 'attendee', 'dependent=yes, width=600, height=605, screenX=580, screenY=420, titlebar=yes, menubar=no, status=no, scrollbars=yes');
  } else {
    alert("You must have valid expense info before adding attendees.\nPlease supply missing data!");
  }
 }
}

function screenLoad() {
  FillForm();
  return true;
}

function setCancelRequest() {
  cancelThisRequest = "DoNotPost";
}


var cancelThisRequest = "";
function screenUnload() {
  var retVal; 
  if (cancelThisRequest != "DoNotPost") {
     retVal = SubmitRec("Post");
  } else {
     // retVal = SubmitRec("DoNotPost");
     retVal = true;
  }
  cancelThisRequest = "";
  return retVal;
}
