
//trans1afx.js - generic reciept with fx and billing (this is the basic expense entry)
//Copyright (C) 2004 R. James Holton

//This program is free software; you can redistribute it and/or modify it 
//under the terms of the GNU General Public License as published by the 
//Free Software Foundation; either version 2 of the License, or (at your option) 
//any later version.  This program is distributed in the hope that it will be 
//useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
//Public License for more details.

//You should have received a copy of the GNU General Public License along with 
//this program; if not, write to the Free Software Foundation, Inc., 
//675 Mass Ave, Cambridge, MA 02139, USA. 


function SubmitRec() {
  with (document.forms.trans1afx) {
    if (CheckAmount(amount)
      && checkdate(rcptdate)
      && doDateChkToday(rcptdate)
      && CheckExpType(expense_1_expensetype)
      && CheckPaidBy(charge)
      && CheckDedicated(expense_1_expensetype, charge)
      && CheckMerchant(expense_1_merchant, expense_1_expensetype.options[expense_1_expensetype.selectedIndex].text) 
      && CheckComment(expense_1_comment, expense_1_expensetype.options[expense_1_expensetype.selectedIndex].text)
      && CheckAttendee(expense_1_attendeelist, expense_1_expensetype.options[expense_1_expensetype.selectedIndex].text)
      && cCheckBill()) {
        parent.makeCurrency(amount);
        expense_1_amount.value = amount.value;
        if (!isNaN(recamt.value)) parent.makeCurrency(recamt);
        parent.UpdateReport('2','trans1afx');
        parent.defDateStr = document.forms.trans1afx.rcptdate.value;
        parent.ListDelay();
    }
  }
}

function CheckPaidBy(object) {
  if (object.selectedIndex == 0) {
     alert("Un type de paiement est requis.");
     object.focus();
     return false;
  }  else {
          return true;
  }
}

function CheckExpType(object) {
  if (object.selectedIndex == 0) {
     alert("Un type de dépenses est requis.");
     object.focus();
     return false;
  }  else {
          return true;
  }
}

function CheckAmount(tag) {
  return parent.checkAmtFldOK(tag);
}

function CheckAttendee(tag,expense) {
  var Check = tag.value;
  var Xstr = parent.getAttendeeReq();
  if (Xstr.indexOf(";" + expense + ";") > -1 && Check.length < 3) {
     alert("Fournir la liste des participants " + expense + " dépense");
     return false;
  } else {
     return true;
  }
}

function CheckComment(tag,expense) {
  return CheckRequired(tag,expense,parent.getCommentReq(),"Commentaire requis");
}

function CheckMerchant(tag,expense) {
  return CheckRequired(tag,expense,parent.getMerchantReq(),"Nom du marchand requis");
}

function CheckRequired(tag,expense,validation, msgtext) {
  var Check = "";
  var n = false 
  var CmtLen = parent.getCommentLen();
  expense = ";" + expense + ";";
  if (validation.indexOf(expense) > -1) {
    if (tag.type.indexOf("select") == 0) {
      Check = tag.options[tag.selectedIndex].text;
      if (Check.length > 2) n = true;     
    } else { 
      Check = parent.alltrim(tag.value);
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

function applyExp() {
  with (document.forms.trans1afx){
  parent.setListValue(parent.getDedicatedMethod("1"), charge, expense_1_expensetype.options[expense_1_expensetype.selectedIndex].text);
  }
}

function CheckDedicated(expObj, chgObj) {
  var x = expObj.options[expObj.selectedIndex].text;
  var y = chgObj.options[chgObj.selectedIndex].text;
  var retVal = true;
  var dedicated = parent.getDBValue(parent.getDedicatedMethod("1"), x);
  if (dedicated != "" && y != dedicated) { 
    retVal = false;
    alert("Méthode de paiement non valide " + y + " pour type de dépense " + x);
  }
  return retVal;
}

function cCheckBill() {
  if (parent.companyBillCheck) {
    return parent.companyBillCheck("trans1",document.forms.trans1afx.expense_1_billtype,document.forms.trans1afx.expense_1_purpose.selectedIndex);
  } else {
    return true;
  }
}

function cBillLoad() {
  if (parent.companyBillLoad) parent.companyBillLoad("trans1",document.forms.trans1afx.expense_1_billtype,document.forms.trans1afx.expense_1_purpose.selectedIndex);
}    

function initForm() {

 // if (parent.HeadList.length > 0) {
    document.forms.trans1afx.rcpttype.value = "3"
    //Gets a simple list found in personal.js
    parent.setList(document.forms.trans1afx.expense_1_expensetype, parent.getExpenseTypes(parent.Category));
    parent.setList(document.forms.trans1afx.charge, parent.getPaymentTypes("1"));
    parent.setListDefault(document.forms.trans1afx.charge, parent.getChargeDef());
    //Sets the purpose pulldown from the HeadList
    parent.setDfltFrmHdWSplit(document.forms.trans1afx.expense_1_purpose);

    //Fills in the merchant array with the proper stuff
    MerchantType = "marchand"
    var merchArray = parent.getMerchants("1");
    var mArray = merchArray.concat(parent.getDBResult(parent.PersDBase,MerchantType));
    parent.setList(document.forms.trans1afx.expense_1_merchant, mArray.sort());

    //Sets the default dates
    parent.setRcptDefDate(document.forms.trans1afx.rcptdate,-1);
    //Brings in any transaction information (note date above can be optimized against this later)
    document.forms.trans1afx.expense_1_persplit.value = "1";
    cBillLoad();
    parent.setTransaction(document.forms.trans1afx);
    if (parent.isNew()) {  //changed 7/4/2002 
      defCurrency();
    } else {
      setFgnProtected(isEmpty(document.forms.trans1afx.xrate.value));
    }
    document.forms.trans1afx.rcptdate.focus();
 // } else {
 //   alert("You must specify a purpose first, then choose Quick Receipt again.");
 //   parent.TransWindow(parent.defaultHead + parent.getPurposeHTML("head2"));
 // }
}
function screenLoad() {
  initForm();
  return true;
}

function screenUnload() {
  return true;
}
