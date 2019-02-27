// xshared1.js - general report management, xmling, and displaying routines 
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


var Header;                //Report header information
var HeadList;              //Purposes, timesheets, odometer readings, etc
var TailList;              //Receipts and expense transactions
var ListBuffer;            //Serves as a flag/contents for editing transaction
var ListIndex;             //Index to place in the list for head and TailList editing
var ReportIsSaved = true;  //Whether latest form of report has been saved
var SetReportIsSaved = false;  //user to set above when the listDelay occurs
var LastHTMLFile = "";     //Used to regrab the last request 
var NextHTMLFile = "";     //Used for linkage between HTMLFiles
var DefaultXref  = "";     //Stored the default into the HeadList (last item used)   

var DirectEdit = false;     //True means editing on the server, false on the browser
var BackSpaceToReport = -2; //Number of screens to go back to return to report - varies depending on the call

var $name$ = 0;            //Makes database array manipulation easier to read
var $value$ = 1;
var $type$ = 0;            //Good descriptions for items in the head and tail lists
var $items$ = 1;


function setRepChgd() {
   ReportIsSaved = false;
   setIntervalCheck();   //JH 2014-10-8
}

function setRepChgd_leave() {
   ReportIsSaved = false;
   setIntervalCheck_leave();   //JH 2014-10-8
}

function Logout(logoutProgram) {
  // if (screenUnload) screenUnload();
  if (logoutProgram == null) logoutProgram = defaultApps + "ajax/LogoutAndRemove.jsp?email="+ parent.myHeader[8][1] + "&language=" + parent.language;
  // if (HeadList.length > 0 && !ReportIsSaved && !DirectEdit) {
  if (!ReportIsSaved && !DirectEdit) {
    if (!confirm(getJSX("JS1_NOT_SAVED"))) {
      parent.myESSMenu.setReport();
      return;
    }
  }
  NewReport();              // Leaving in a "back button" acceptable state.
  ProcessHeader(parent.myHeader);
  SetCookie("ESSHead","");
  SetCookie("ESSPurp","");
  SetCookie("ESSRcpt","");
  parent.DontRunSaveWork = true;
  top.location.href = logoutProgram;
}

function isNew() {
 if (ListBuffer.length == 0) {
   return true;
 } else {
   return false;
 }
}

function setKeyField(x) {
//x = css class to show protected field
 if (!isNew()) {
   return(" class=\"" + x + "\" readOnly=true ");
 }
}

function NewMaybe(xfunc) {
  if (HeadList.length > 0) {
    if (confirm(getJSX("JS1_NEW_REPORT"))) {
      parent.defDateStr = "";
      NewReport();
      ProcessHeader(parent.myHeader);
      if (xfunc) eval(xfunc); 
    }
  }
}

function NewieIfNotSaved(ScreenHTML) {
  if (ReportIsSaved) {
    switchScript("shared/blank.js");
    setTimeout("screenNewReport('" + ScreenHTML + "')" , 500);
  } else {
    if (screenUnload) screenUnload();
    Newie(ScreenHTML);
  }
}

function screenNewReport(ScreenHTML) {
    defDateStr = "";
    NewReport();
    parent.ProcessHeader(parent.myHeader); 
    TransWindow(ScreenHTML); 
}

function ShowHistoryTrans(ScriptJSP) {
     var repScript = document.getElementById("historyScript");
     if (repScript != null) document.body.removeChild(repScript); 
     try {
       var oScript = document.createElement("script");
       oScript.src = ScriptJSP;
       oScript.id = "historyScript";
     } catch (e) {
       var oScript = document.createElement("<sc" + "ript language='Javascript' id = 'historyScript' src='" + ScriptJSP + "'>");
     }
     document.body.appendChild(oScript);
}

function Newie(ScreenHTML,singlePurpose) {
  if (singlePurpose == null) singlePurpose = false;
  if (HeadList.length > 0) {
    var newScreenHTML = "";
    if (!ReportIsSaved) {
    newScreenHTML += "<p align=\"left\"><big><em><big>" + getJSX("JS1_REP1") + "</big></em></big></p>\n";
    } else {    
    newScreenHTML += "<p align=\"left\"><big><em><big>" + getJSX("JS1_REP2") + "</big></em></big></p>\n";
    }
    newScreenHTML += "<font size=\"5\"><em><ul>\n";
    if (!ReportIsSaved) {
      newScreenHTML += "<li><p align=\"left\"><a href=\"javascript: void parent.loadHTMLScreenAJAX('saveXMLFile.html')\">" + getJSX("JS1_REP3") + "</a></p></li>\n";
    }
    if (!singlePurpose) newScreenHTML += "<li><p align=\"left\"><a href=\"javascript: void parent.TransWindow('" + ScreenHTML + "')\">" + getJSX("JS1_REP4") + "</a></p></li>\n";
    if (!ReportIsSaved) {
    newScreenHTML += "<li><p align=\"left\"><a href=\"javascript: void parent.NewMaybe('parent.TransWindow(\\\'" + ScreenHTML + "\\\')')\">" + getJSX("JS1_REP5") + "</a></p></li>\n";
    } else {
    newScreenHTML += "<li><p align=\"left\"><a href=\"javascript: void scriptNewReport('" + screenHTML + "')\">" + getJSX("JS1_REP6") + "</a></p></li>\n";
    }
    newScreenHTML += "</ul></em></font>\n";
    document.getElementById("main").innerHTML = newScreenHTML;
    switchScript("shared/blank.js"); //JH 2010-06-29
  } else {
    parent.defDateStr = "";
    parent.NewReport();
    if (getNameValue(Header,"persnum") == getDBValue(parent.myHeader,"persnum")) {
      parent.ProcessHeader(parent.myHeader); 
    }
    parent.TransWindow(ScreenHTML); 
  }
}

function Copie(ScreenHTML) {
  if (confirm(getJSX("JS1_MAKE_COPY"))) {
    ReProcessHeader(Header); 
    var x = setNameValue(Header,"editable","YES");
    x = setNameValue(Header,"credate",getNameValue(parent.myHeader,"credate"));
    x = setNameValue(Header,"cretime",getNameValue(parent.myHeader,"cretime"));
    if (getNameValue(parent.myHeader,"persnum") == getNameValue(Header,"persnum")) {
       x = setNameValue(Header,"email",getNameValue(parent.myHeader,"email"));
       x = setNameValue(Header,"name",getNameValue(parent.myHeader,"name"));
       x = setNameValue(Header,"phone",getNameValue(parent.myHeader,"phone"));
       x = setNameValue(Header,"location",getNameValue(parent.myHeader,"location"));
       x = setNameValue(Header,"depart",getNameValue(parent.myHeader,"depart"));
       x = setNameValue(Header,"company",getNameValue(parent.myHeader,"company"));
       x = setNameValue(Header,"currency",getNameValue(parent.myHeader,"currency"));
    }
    ListMemory()
    alert(getJSX("JS_REPORT_COPIED"));
  }
}

function NewReport() {
  //Header = new Array();  remove later is no problems
  HeadList = new Array();
  TailList = new Array();
  ListBuffer = new Array();
  ReportIsSaved = true;
}

NewReport();              // Initializes to new report on load.
ProcessHeader(parent.myHeader);

function PersWithDBase(X, Tag, DefVal) {
  var A = X + getDBString(parent.PersDBase, Tag, DefVal)
  PersWindow(A);
}

function PersWindow(HTMLFile,ListArray,index) {
  var s = PersGetCreate(HTMLFile);
  TransWindow(s,ListArray,index);
}

function PersGetCreate(HTMLFile) {
  var commChar = "?";
  if (HTMLFile.indexOf("?") > -1) commChar = "&";
  var s = HTMLFile + commChar + "email=" + parent.myHeader[8][1] + "&reporter=" + getNameValue(Header,"persnum") + "&ccode=" + parent.CCode + "&database=" + parent.database + "&force=" + Math.random();
  return s
}

function NeedAReport(HTMLFile,ListArray,index) { 
  if (HeadList.length > 0 || TailList.length > 0 || DirectEdit) {
    TransWindow(HTMLFile,ListArray,index);
  } else {
    alert(getJSX("JS_CANNOT_PROCEED1"));
  }
}

function OnlyIfEditable(HTMLFile,ListArray,index) { 
  if ((HeadList.length > 0 || TailList.length > 0) && getEditable()) {
    var x = getNameValue(Header,"status");
    x = x.toUpperCase();
    if ( x == "NEW" || x == "CHANGED NEW" ||confirm(getJSX("JS_RESUBMIT")) == true) {   
       TransWindow(HTMLFile,ListArray,index);
    }
  } else {
    alert(getJSX("JS_CANNOT_PROCEED2"));
  }
}

function NeedAPurpose(HTMLFile,ListArray,index) { 
  if (HeadList.length > 0) {
    TransWindow(HTMLFile,ListArray,index);
  } else {
    alert(getJSX("JS_CANNOT_PROCEED3"));
  }
}

function OnlyIfChanged(HTMLFile,ListArray,index) {
  if (!ReportIsSaved && getEditable()) {
    NeedAReport(HTMLFile,ListArray,index);
  } else { 
    if (getEditable()) {  //if report is editable then if must be ReportIsSaved (not changed)
       alert(getJSX("JS_NO_CHANGES"));
    } else {
       alert(getJSX("JS_CANNOT_PROCEED4"));
    }
  }
}

function TransWindow(HTMLFile,ListArray,index,noSaveFlag) {  //Load a screen tied to a buffer item
  dupFlagOK = true;
  if (parent.CommOK) { 
    if (noSaveFlag) {
    } else{
      LastHTMLFile = HTMLFile;
    } 
    if (ListArray) {
      switch (ListArray) {
        case "HeadList":
          ListBuffer = HeadList[index][$items$];
          ListIndex = index;
          break;
        case "TailList":
          ListBuffer = TailList[index][$items$];
          ListIndex = index;
          break;
        case "TailOmitIndexList":  //Need to set ListBuffer and ListIndex manually
          break;
        case "ListBuffer":
          break;
        default:
          alert(ListArray + " " + getJSX("JS_TRANSWINDOW")); 
          ListBuffer = new Array();
      }
    } else {
      ListBuffer = new Array();
    }
    Log.println("xshared1.js","Loading: " + HTMLFile);
    parent.loadScreenAJAX(HTMLFile);
  } else {
    alert(getJSX("JS_LOAD_ERROR"));
  }
}

function TwoMenuItems(X,Y) {
    NextHTMLFile = Y;
    TransWindow(X);
}

function helpWindow(HTMLFile,x,y,extra) {
  if (x == null) x = '580';
  if (y == null) y = '540';
  if (extra == null){ 
      extra = "";
  } else {
      extra = ", " + extra;
  }
  if (parent.CommOK) {
    top.newWin = window.open(defaultHome + 'help/' + HTMLFile , 'Help', 'dependent=yes, width=' + x + ', height=' + y + ', screenX=580, screenY=420, titlebar=yes, menubar=no, status=no, scrollbars=yes' + extra)
  } else {
    alert(getJSX("JS_LOAD_ERROR"));
  }
}

function setListBuffer(AddArray)
{
   ListBuffer = AddArray;
//  var x;
//  var y;
//  var z;
//  ListBuffer = new Array();
//  ListBuffer.length = AddArray.length;
//  for (var i = 0; i < AddArray.length; i++)
//
// {
//     y = new String(AddArray[i][0]);     
//     z = new String(AddArray[i][1]);     
//     x = new Array(y,z);   
//     ListBuffer[i] = x;
//  }
}

function setTransaction(TheForm) {   //This routine sends the buffered items to a screen
  var j;
  var k;        //location of m in string
  var m = ": "; //delimiter for recover values
  var n;        // recover value
  var z;        //Will preserve a value not found in the list
  var XrefWork;
  for (var i = 0; i < ListBuffer.length; i++) {
    if (TheForm.elements[ListBuffer[i][$name$]]) {
      switch (TheForm.elements[ListBuffer[i][$name$]].type) {
        case "text":  
           TheForm.elements[ListBuffer[i][$name$]].value = ListBuffer[i][$value$];
           break; 
        case "password":  
           TheForm.elements[ListBuffer[i][$name$]].value = ListBuffer[i][$value$];
           break; 
        case "textarea":  
           TheForm.elements[ListBuffer[i][$name$]].value = ListBuffer[i][$value$];
           break;   
        case "select-one":
           if (isSubtypeEqual(TheForm.elements[ListBuffer[i][$name$]],"list")) {
             var showValues = getListDisplay(ListBuffer[i][$name$]);          
             setListWithKey(TheForm.elements[ListBuffer[i][$name$]],ListBuffer[i][$value$],showValues,0,1);
           } else { 
             j = 0;
             z = true;
             XrefWork = getXrefElementName(TheForm.elements[ListBuffer[i][$name$]]);
             if ((XrefWork == null) || (XrefWork == "")) { //jh 2006-02-02 Groundhogs' Day
               do {
                 if (TheForm.elements[ListBuffer[i][$name$]].options[j].text == ListBuffer[i][$value$] 
                   || (TheForm.elements[ListBuffer[i][$name$]].listtype == "value-in" && TheForm.elements[ListBuffer[i][$name$]].options[j].value == ListBuffer[i][$value$])) {
                   TheForm.elements[ListBuffer[i][$name$]].selectedIndex = j;
                   z = false;
                 }
                 j = j + 1;
               } while (z && j < TheForm.elements[ListBuffer[i][$name$]].length); 
               if (z) {  
                 TheForm.elements[ListBuffer[i][$name$]].length = j + 1; 
                 TheForm.elements[ListBuffer[i][$name$]].options[j].text = ListBuffer[i][$value$];
                 n = ListBuffer[i][$value$];
                 k = n.indexOf(m);
                 if (k > 0) n = n.substring(0,k);
                 TheForm.elements[ListBuffer[i][$name$]].options[j].value = n;
                 TheForm.elements[ListBuffer[i][$name$]].selectedIndex = j;
               }
             } else {
	           var xreference = null;
               if (TheForm.elements[ListBuffer[i][$name$]].getAttribute) {
	              xreference = getNameValue(ListBuffer,TheForm.elements[ListBuffer[i][$name$]].getAttribute("xref"));
               } else {
                  xreference = getNameValue(ListBuffer,TheForm.elements[ListBuffer[i][$name$]].xref);
               } 
               // var xreference = getNameValue(ListBuffer,TheForm.elements[ListBuffer[i][$name$]].xref);  // chk 2006-02-02
               
               do {
                 if (TheForm.elements[ListBuffer[i][$name$]].options[j].value == xreference) {
                   TheForm.elements[ListBuffer[i][$name$]].selectedIndex = j;
                   z = false;
                 }
                 j = j + 1;
               } while (z && j < TheForm.elements[ListBuffer[i][$name$]].length); 
             }
           } //subtype list if clause
           break;
        case "hidden": 
           if (isSubtypeEqual(TheForm.elements[ListBuffer[i][$name$]],"hiddenlist")) {
             if (typeof(ListBuffer[i][$value$]) == "string") {
                TheForm.elements[ListBuffer[i][$name$]].value = ListBuffer[i][$value$];
             } else {
                TheForm.elements[ListBuffer[i][$name$]].value = setArray2Str(ListBuffer[i][$value$],"'");    //was setArray2Str
              }
           } else {      
             TheForm.elements[ListBuffer[i][$name$]].value = ListBuffer[i][$value$];
           }
           break; 
        default:
           alert("Form: cannot load " + ListBuffer[i][$name$] + ", type:" + TheForm.elements[ListBuffer[i][$name$]].type + ", value:" + ListBuffer[i][$value$]);
      }  //need to add the other types eventually
    }
  }
}

function isSubtypeEqual(eleObj,checkString) {  //Need a special function for IE and Mozzila compatability
   var retVal = false; 
   var eleObjSubtype = null;
   if (eleObj && eleObj.getAttribute) eleObjSubtype = eleObj.getAttribute("subtype");
   if (eleObj != null) {
   } else {
   }   
   if ((eleObjSubtype != null) && (eleObjSubtype == checkString)) {
          retVal = true;
   } else {
     if ((eleObj != null) && eleObj.subtype && (eleObj.subtype != null)) {
         if (eleObj.subtype == checkString) {
           retVal = true
         } 
     }  
   }
return retVal;
}

function deleteItem(ListName, index) {
  if (confirm(getJSX("JS_DELETE?"))) {
    var List;
    if (ListName == "HeadList") {  //replace with getHeadName function from company.js
      var PurpTied = false;
      for (var i = 0; i < TailList.length; i++) {
         if (getItemValueSubstr(TailList[i], "xref") != "") {
           if (getItemValue(HeadList[index],"xref") == getItemValueSubstr(TailList[i],"xref")) {
             PurpTied = true;
             i = TailList.length;
           }
         }
      }
      if (PurpTied) {
        alert(getJSX("JS_DEL_RECEIPTS"));
        return;
      }
      var xThis = getNumericValue(HeadList[index],"weight");  //checking for weight being orphaned
      var xTotal = getTotalValueFor(HeadList,"weight");
      var SearchStr = "Weight;"
      if (xThis > 0 && xThis == xTotal) {
         if (getTotalValueFor(TailList,'amount','xref',SearchStr) > 0 || getTotalValueFor(TailList,'amount','expense_1_xref',SearchStr) > 0) {
          alert(getJSX("JS_DEL_SPLIT"));
          return;
        }
      }
      List = HeadList;
    } else {
      List = TailList;
    }  
    var CurArrayEnd = List.length - 1;
    if (index < CurArrayEnd) {
      var List2 = List.slice(0,index)
      List = List2.concat(List.slice(index+1));
    } else {
      List = List.slice(0,index);
    } 
    if (ListName == "HeadList") { 
      HeadList = List;
    } else {
      TailList = List;
    } 
    ReportIsSaved = false;
  } 
}

function TransCell(name, value){
//the object describes the smallest report unit that is called a cell in the report array.    
  //this.name = name this.value = value;
  return new Array(name, value);
}

function ProcessHeader(LocalList) {   //Used by populate report options
  Header = new Array();
  for (var i = 0; i < LocalList.length; i++) {
    Header.length = Header.length + 1;
    Header[Header.length - 1] = new TransCell(LocalList[i][0], LocalList[i][1]);
  }  
}

function ReProcessHeader(xHead) {   //Used by copie report option
  Header = new Array();
  var DontCopy = "status;reference;subdate;subtime;rcamt;reamt;adamt;"
  for (var i = 0; i < xHead.length; i++) {
    if (DontCopy.indexOf(xHead[i][$name$]) == -1) { 
      Header.length = Header.length + 1;
      Header[Header.length - 1] = new TransCell(xHead[i][$name$], xHead[i][$value$]);
    }
  }
  Header.length = Header.length + 1;
  Header[Header.length - 1] = new TransCell("status", "New");
}


function ProcessRepList(TransClass, LocalList) {
//used primarily by the cookie retreival and report download function to 
//add information to the report arrays    
  for (var i = 0; i < LocalList.length; i++) {
    UpdateInternal(TransClass, LocalList[i][0], LocalList[i][1]);
  }
}

var dupFlagOK = true;

function UpdateReport(TransClass, TransType, TheForm) {  //Sends the items from a single screen to the buffer
//updates the appropriate report array from a screen
 if (dupFlagOK) { 
  dupFlagOK = false;  
  if (genNoError() && cusNoError()) {
    if (!TheForm) var TheForm = parent.document.forms[1];  //WAS 0
    var ThisName;
    var SubType;
    var WorkStr;
    var XrefWork;
    var ThisTrans = new Array(0);
    var j = 0;
    for (var i = 0; i < TheForm.length; i++) {

      ThisName = TheForm.elements[i].name;

      SubType = null;
      if (TheForm.elements[i].getAttribute) {
        SubType = TheForm.elements[i].getAttribute("subtype");
      } else if (TheForm.elements[i].subtype){
        SubType = TheForm.elements[i].subtype;
      } 
      if (SubType == null) SubType = TheForm.elements[i].type;
  
      switch (SubType) {
        case "text":      
            ThisTrans[j] = Array(ThisName, TheForm.elements[i].value);
            j = j + 1;
            break;    
        case "select-one":
            if (TheForm.elements[i].selectedIndex > -1) {
              WorkStr = Array(ThisName, TheForm.elements[i].options[TheForm.elements[i].selectedIndex].text);
              if ((WorkStr[1] > " ") || iXMLB) {  // jh 20060421
                ThisTrans[j] = WorkStr;
                j = j + 1;     
              } 
              XrefWork = getXrefElementName(TheForm.elements[i]);
              if ((XrefWork != null) && (XrefWork != "")) { //processing the alternative xref value jh 20060421
                ThisTrans[j] = Array(XrefWork, TheForm.elements[i].options[TheForm.elements[i].selectedIndex].value);
                DefaultXref = TheForm.elements[i].options[TheForm.elements[i].selectedIndex].value; //later change to check for a name
                j = j + 1;
              } 
            }
            break;
        case "select-value":
            if (TheForm.elements[i].selectedIndex > -1) {
              WorkStr = Array(ThisName, TheForm.elements[i].options[TheForm.elements[i].selectedIndex].text);
              if ((WorkStr[1] > " ") || iXMLB) {  // jh 20060421
                ThisTrans[j] = WorkStr;
                j = j + 1;     
              } 
            }
            break;

        case "textarea":      
            ThisTrans[j] = Array(ThisName, TheForm.elements[i].value);
            j = j + 1;
            break;    
        case "hidden":      
            ThisTrans[j] = Array(ThisName, TheForm.elements[i].value);
            j = j + 1;
            break;
        case "hiddenlist": 
            var ThisList = new Array();
            ThisList = eval(TheForm.elements[i].value);
            // ThisList = eval(TheForm.elements[i].value);
            ThisTrans[j] = Array(ThisName, ThisList);
            j = j + 1;
            break;
        case "exclude":   // excludes type and processes the xref attribute only
            XrefWork = getXrefElementName(TheForm.elements[i]);
            if ((XrefWork != null) && (XrefWork != "")) {           
              ThisTrans[j] = Array(XrefWork, TheForm.elements[i].options[TheForm.elements[i].selectedIndex].value);
              j = j + 1;
            } 
            break;
        case "nonzero": //does not store a value if it is equal to zero.
            if (isNaN(TheForm.elements[i].value) || parseFloat(TheForm.elements[i].value) == 0) {
              break;
            }
            ThisTrans[j] = Array(ThisName, TheForm.elements[i].value);
            j = j + 1;
            break;
        case "list":
            var ThisList = new Array();
            for (var k = 0; k < TheForm.elements[i].length; k++) {
                if (TheForm.elements[i].options[k].value != null) {
                  ThisList.length = ThisList.length + 1
                  ThisList[ThisList.length - 1] = eval(TheForm.elements[i].options[k].value);
                }
            }
            ThisTrans[j] = Array(ThisName, ThisList);
            j = j + 1;
            break;    
        case "liststring":
            var ThisList = new Array();            //This is not being used - JH
            ThisTrans[j] = Array(ThisName, eval(TheForm.elements[i].value));
            j = j + 1;
            break;    
        case "radio": // not implemented yet
            alert("radio buttons not implemented: " + ThisName);
            break;
        case "checkbox": // not implemented yet
            alert("checkbox not implemented: " + ThisName);        
            break;
        case "button": // don't capture any of the following
            break;
        case "submit":
            break;
        case "reset":
            break;
        case "nosave": // don't save if this subtype
            break;
        default:
            // alert("Field '" + SubType + "' not anticipated by UpdateReport() in : " + TransType);
      }
    }
    UpdateInternal(TransClass, TransType, ThisTrans);
  } else {
    alert(getJSX("JS_UPDATE_ERROR"));
  }
  dupFlagOK = true;
 } 
}

function getXrefElementName(eleObj) {
  var retVal = "";
  if (navigator.userAgent.indexOf("Mozilla") > -1) {
      if (eleObj.attributes.getNamedItem("xref")) retVal = eleObj.attributes.getNamedItem("xref").value;
  } else if (navigator.appVersion.indexOf("MSIE") > -1) {
     if (eleObj.xref) retVal = eleObj.xref; 
  } else {
     alert(getJSX("JS_INVALID_BROWSER"));
  }
  return retVal;
} 

function UpdateInternal(TransClass, TransType, ThisTrans) {
//selects the appropraite array and updates it.    
    var ElementList = new Array(ThisTrans.length);
    for (var i = 0; i < ThisTrans.length; i++) {
      ElementList[i] = TransCell(ThisTrans[i][0],ThisTrans[i][1]);
    }
    switch(TransClass) {
      case "1":
        Add2HeadList(TransType, ElementList);
        break;
      case "2":
        Add2TailList(TransType, ElementList);
    }
    ReportIsSaved = false;
}

function ListItem(TransType, Transaction){
//object for a transaction, i.e., screen name with an array of field names and values
  // this.type = TransType;  this.items = Transaction;
  return new Array(TransType, Transaction);
}

function Add2HeadList(HeadType, Information) {
  var NextCell;
  if (isNew()) {
    NextCell = HeadList.length;
  } else {
    NextCell = ListIndex;
  }
  HeadList[NextCell] = new ListItem(HeadType, Information);
  ListBuffer = new Array();  
}

function Add2TailList(TransType, Transaction) {
  var NextCell;
  if (isNew()) {
    NextCell = TailList.length;
  } else {
    NextCell = ListIndex;
  }
  TailList[NextCell] = new ListItem(TransType, Transaction);
  ListBuffer = new Array();
}

function NextXref(xItem, nPackZeros) {
  if (xItem == null || xItem == "") xItem = "xref";
  var NextRef = 1;
  var StringRef;
  if (HeadList.length == 0) {
    StringRef = NextRef.toString();
    if (nPackZeros != null) StringRef = zeroPack(StringRef,nPackZeros);
  } else {
    var xref = getItemValue(HeadList[HeadList.length-1],xItem);  //Splits are marked with 'S'
    if (xref.length > 6) xref = xref.substring(1);
    NextRef = parseInt(xref);
    do {
      NextRef = NextRef + 1;
      StringRef = NextRef.toString();
      if (nPackZeros != null) StringRef = zeroPack(StringRef,nPackZeros);
    } while (getResultWhere(HeadList, xItem, StringRef) != null);
  }
  return StringRef;
} 

function getXref(position, crossRef) {
  if (crossRef == null) crossRef = "xref";  
  return getItemValue(HeadList[position],crossRef);
} 

var backcolor = "class=\"TableData offsetColor\"";  //These are used for alternating a colored line with a white one
var oldbackcolor = "class=\"TableData\"";
var newbackcolor; 

function ListDelay() {
  var timer = setTimeout("parent.loadHTMLScreenAJAX(parent.entryScreen)",1000);
}

function ListMemory(){
  if (HeadList.length != 0) {
    PrintHeadList();
  }
  if (TailList.length != 0) {
    PrintTailList();
  }
  //setRepTotals();
}

function ListHeader(title, value, link, text) {
}

function dispPersNo(x) {
  if (x.substr(3,1) == "-" && x.substr(6,1) == "-") {
    x = "***-**-" + x.substr(7,4);
  }
  return x;
}

function PrintHeadList() {
    var j = 0;
    ListBuffer = HeadList[j][$items$];
    ListIndex = j;
    parent.setTransaction(getPurposeLine());
}

var numberMileageLines;
var numberReceiptLines;
var numberPlaneReceiptLines;
function PrintTailList() {
  numberMileageLines = 0;  //necessary here??
  numberReceiptLines = 0;
  numberPlaneReceiptLines = 0;
  for (var j = 0; j < TailList.length; j++){
    ListBuffer = TailList[j][$items$];
    ListIndex = j;
    if (TailList[j][$type$] == "trans5") {     //want to make this a substring check for all the checks
       numberMileageLines++;
       parent.setTransaction(AddMileageLine());
    } else if (TailList[j][$type$].indexOf("trans12") > -1){
       numberReceiptLines++;
       parent.setTransaction(AddHotelLine());
    } else if (TailList[j][$type$] == "trans7"){
       numberReceiptLines++;
       parent.setTransaction(ShowAdvanceLine());   //More than one advance???
    } else if (TailList[j][$type$] == "trans8"){
       numberReceiptLines++;
       parent.setTransaction(ShowReturnLine());    //More than one return???
    } else if (TailList[j][$type$] == "trans1air"){
       numberPlaneReceiptLines++;
	   var iNode = AddPlaneReceiptLine();
       parent.setTransaction(iNode);
	   addScanRefLink(iNode);

    } else {
       numberReceiptLines++;
	   var iNode = AddReceiptLine();
       parent.setTransaction(iNode);
	   addScanRefLink(iNode);
    }
  }
}

function addScanRefLink(iNode) {
	  var magnify = iNode.getElementsByTagName("a");
	  if (magnify.length > 0) {
		  for (var i = 0; i < magnify.length; i++ ) {
			  if (magnify[i].name == "magnify" && (iNode.scanref.value != null && iNode.scanref.value != ""))
			  {
			      var hlink = "javascript: void window.open('" + "/ess-app/receipts/ReceiptView.jsp?image=" + iNode.scanref.value + "' , 'Receipt Image', 'dependent=yes, width=700, height=540, screenX=580, screenY=420, resizable, titlebar=yes, menubar=yes, status=no, scrollbars=yes')";
			  	  magnify[i].href = hlink; 
				  magnify[i].innerHTML="<img SRC='/ess/images/ess-View.gif' title='" + parent.getJSX("view") + "' />";
			  }
		  }
	  }
	}
function setCheckBox(obj,db,i,item2Set) {
  var z;
  var x = db[i][$items$]; 
  if (obj.checked) {
    z = setNameValue(x,item2Set,"Yes")
  } else {
    z = setNameValue(x,item2Set,"No")
  }
  if (getNameValue(x,"persistance") != "insert") z = setNameValue(x,"persistance","update");
}  


//End of the ListMemory functions

//The following functions are used to create XML formated strings for transmission to the host

function PrintPersXML(dbarray) {
//This function attempts to write the persdata xml to a 
//browser as an xml file and is only used for debugging
  var thisXML = CreatePersDBXML(dbarray);
  document.getElementById("main").innerHTML = thisXML;
}

function PrintXML() {
//This function attempts to write the report in XML for debugging
  //parent.main.document.open("text/xml");
  //parent.main.document.write(CreateXML());
  //parent.main.document.close();
  var thisXML = CreateXML();
  document.getElementById("main").innerHTML = thisXML;
}

var iXMLB = false; //iXMLB = includeXMLBlanks
function CreateXML() {  // change name 2 CreateRepXML
//Creates an xml file from the report arrays, the primary purpose is to submit/save reports
//on the web server.  This xml file corresponds to how the browser's forms see the data.
//there exists normalization and translation routines on the web serber.
  var outstring = "<report>\n"; 
  outstring += "<header>\n";
  for (var i = 0; i < Header.length; i++) {
    if (Header[i][$value$].length > 0 || iXMLB) {
      outstring += "<" + Header[i][$name$] + ">";   
      outstring += XMLReplace(Header[i][$value$]); 
      outstring += "</" + Header[i][$name$] + ">\n";
    }
  }
  outstring += "</header>\n";
  for (var j = 0; j < HeadList.length; j++){
    outstring += "<" + getHLTagName() + " type=\"" + HeadList[j][$type$] + "\">\n";
    outstring += CellDrill(HeadList[j][$items$]);
    outstring += "</" + getHLTagName() + ">\n";
  }
  for (var j = 0; j < TailList.length; j++){  //could get modularized
    outstring += "<" + getTLTagName() + " type=\"" + TailList[j][$type$] + "\">\n";
    outstring += CellDrill(TailList[j][$items$]);
    outstring += "</" + getTLTagName() + ">\n";
  }
  outstring += "</report>";
  return outstring;
}

function CellDrill(items) {
  var outstring = "";
  for (var i = 0; i < items.length; i++) {
    if ((items[i][$value$].length > 0  || iXMLB) && (typeof(items[i][$value$]) != "string" || items[i][$value$] != "[]")) {
      outstring += "<" + items[i][$name$] + ">";
      if (typeof(items[i][$value$]) == "string") {
        outstring += XMLReplace(items[i][$value$]); 
      } else {
        outstring += "\n" + CellDrill(items[i][$value$]);
      }
      outstring += "</" + items[i][$name$] + ">\n";
    }
  }
  return outstring;
}


function XMLReplace(x) {
//replace later with a function that doesn't change a valid unicode (&...;)
  var regexp = /&/g ;
  x = x.replace(regexp,"&amp;");
  regexp = /</g ;
  x = x.replace(regexp,"&lt;");
  regexp = /´/g ;
  x = x.replace(regexp,"");  // was &#180;
  regexp = />/g ;
  x = x.replace(regexp,"&gt;");
  regexp = /"/g ;
  x = x.replace(regexp,"'");
  regexp = /\n/g ;
  x = x.replace(regexp,"&#10;");
  regexp = /\r/g ;
  x = x.replace(regexp,""); 
  regexp = /\\/g ;
  x = x.replace(regexp,"&#92;");

  var z = 0;
  var y = "";
  for (var j = 0; j < x.length; j++) {
     z = x.charCodeAt(j);
     if (z > 127) {
        if (z < 256) {
           y = "&#" + z + ";";
        } else {
           y = "?";
        }
        x = x.substring(0,j) + y + x.substr(j+1);
        j = j + y.length - 1;
     }
  }

  //regexp = /\[/g ;
  //x = x.replace(regexp,"&#91;");   
  //regexp = /\]/g ;
  //x = x.replace(regexp,"&#93;");   
  return x;
}

function CreatePersDBXML(DBArray) {
  var outString = "";
  outString += "<personal>\n";
  outString += CreateDBXML(DBArray);
  outString += "</personal>\n";
  return outString;
}

function CreateDBXML(DBArray) {
  var outString = "";
  for (var i = 0; i < DBArray.length; i++) {
    outString += "<" + DBArray[i][0] + ">";
    if ( typeof(DBArray[i][1]) == "string") {
      outString += XMLReplace(DBArray[i][1]);
    } else {
      outString += "\n";
      var copyArray = new Array();
      if (DBArray[i].length > 1) {  //jh 2007-10-25
        for (var j = 0; j < DBArray[i][1].length; j++) {
          copyArray[copyArray.length] = DBArray[i][1][j];
        } 
        outString += CreateDBXML(copyArray);
      }
    }
    outString += "</" + DBArray[i][0] + ">\n";
  }
  return outString;
}



//End of XML stuff

//These functions will save the current report to UserData or Cookie
//The actual set and get functions dealing with app variables/arrays
//can probably be rewritten as these have been kind of hacked.

function SetLocal() {
  if (getDBValue(parent.PersDBase,"cookie").toUpperCase() != "NO") {
    CreateCookies();
  }
}

function GetLocal() {
 var msg = "The previous report you were working on has been reclaimed.";
 populateReport(GetCookie("ESSHead"), GetCookie("ESSPurp"), GetCookie("ESSRcpt"), msg);
 ReportIsSaved = false;
}

function GetCookie(EntryName) {
  if (navigator.appVersion.indexOf("MSIE") > -1 && navigator.appVersion.indexOf("compatible") < 0) {    
    document.Userdata.ReportData.load(EntryName);
    var ThisCookie = document.Userdata.ReportData.getAttribute("data");
    if (ThisCookie == null) ThisCookie = "";
    return(ThisCookie);
  } else { 
    var search = EntryName + '=';
    if (document.cookie.length > 0) {
      offset = document.cookie.indexOf(search);
      if (offset != -1) {
        offset += search.length;
        end = document.cookie.indexOf(';', offset);
        if (end == -1) end = document.cookie.length;
        return unescape(document.cookie.substring(offset, end));
      }
    }
  }
}

var safeFlag = true;
function SetCookie(EntryName, value) {
  try {
    if (navigator.appVersion.indexOf("MSIE") > -1 && navigator.appVersion.indexOf("compatible") < 0) {
      document.Userdata.ReportData.setAttribute("data", value);
      document.Userdata.ReportData.save(EntryName);
    } else {
      var today = new Date();
      var exp = new Date();
      exp.setTime(today.getTime() + (30 * 24 * 60 * 60 * 1000));
      document.cookie = EntryName+'='+escape(value)+'; expires='+exp.toGMTString();
    }
  } catch (e) {
    if (safeFlag) {
      alert(getJSX("JS_SAFESTORE"));
      safeFlag = false;
    }
  }
}

function EraseCookie(EntryName) { //This hasn't yest been debugged
  if (navigator.appVersion.indexOf("MSIE") > -1 && navigator.appVersion.indexOf("compatible") < 0) {
    document.SelectionList.ReportData.removeAttribute("data");
    document.SelectionList.ReportData.save(EntryName);
  } else {
    var today = new Date();
    var exp = new Date();
    exp.setTime(today.getTime() - 1 );
    document.cookie = EntryName+'=\"\"; expires='+exp.toGMTString();
  }
}

var O = "["; //These are the standard delimiters,etc.
var C = "]"; //and they are used below for formatting.
var D = ",";
var Q = "\"";

function CreateCookies() {
  
  SetCookie("ESSHead",setArray2Str(Header));  //was outstring
  SetCookie("ESSPurp",setArray2Str(HeadList));
  SetCookie("ESSRcpt",setArray2Str(TailList));
}

// Next function is deprecated
function setOutString(itemList) {
    return setArray2Str(itemList)
}


function populateReport(HeadString, PurpString, RcptString, Msg) {
//Used to create a page that will then update report arrays thru the ProcessRepList function
if (HeadString.length > 0) {
  Header = eval(HeadString);
  HeadList = eval(PurpString);
  TailList = eval(RcptString);  
  parent.ListDelay();
 } else {
  alert(getJSX("JS_NO_REPORT"));
 }
} 

function writeDelayMsg(xJsp, xMsg) {

  if (xMsg == null) xMsg = getJSX("JS_PROCESSING");
  xMsg = "<BIG><STRONG>\n" + xMsg + "\n</BIG></STRONG>\n";
  document.getElementById("main").innerHTML = xMsg;
  if (xJsp > "") xJsp = xJsp + "&force=" + Math.random()
  eval("parent.TransWindow('" + xJsp + "')");

}

//end of the cookie save and retrieval functions

//AJAX functions for communicating with the server 1/29/2008
// xmlHttp -> HTTP Request Object, define globally in calling object/script (i.e., var xmlHttp;)
// url -> url to execute (i.e., var url="/ess-app/AJAXTest.jsp";)
// stateChanged -> name of routine to run
// aSync -> true runs asynchronously (i.e., parallel), false run serially
function getInfo(xmlHttp, url, stateChanged, aSync)
{
  if (aSync == null) aSync = true;
  // xmlHttp=GetXmlHttpObject();
  if (xmlHttp==null)
  {
    alert (getJSX("JS_NO_AJAX"));
    return;
  } 
  xmlHttp.onreadystatechange=stateChanged;
  xmlHttp.open("GET",url,aSync);
  xmlHttp.send(null);
} 

// Example - need to check for the readyState == 4
//function stateChanged() {
//  if (xmlHttp.readyState==4)
//  { 
//     document.forms[0].Test.value = xmlHttp.responseText;
//  }

function GetXmlHttpObject()
{
  var xmlHttp=null;
  try
  {
  // Firefox, Opera 8.0+, Safari
    xmlHttp=new XMLHttpRequest();
  }
  catch (e)
  {
  // Internet Explorer
  try
    {
      xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
    }
    catch (e)
    {
      xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
    }
  }
return xmlHttp;
}

//End of the script file
