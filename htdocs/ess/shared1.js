// shared1.js - general report management, xmling, and displaying routines 
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
var LastHTMLFile = "";     //Used to regrab the last request 
var NextHTMLFile = "";     //Used for linkage between HTMLFiles
var DefaultXref  = "";     //Stored the default into the HeadList (last item used)   

var DirectEdit = false;     //True means editing on the server, false on the browser
var BackSpaceToReport = -2; //Number of screens to go back to return to report - varies depending on the call

var $name$ = 0;            //Makes database array manipulation easier to read
var $value$ = 1;
var $type$ = 0;            //Good descriptions for items in the head and tail lists
var $items$ = 1;

function Logout(logoutProgram) {
  if (logoutProgram == null) logoutProgram = defaultApps + "Logout.jsp?email="+ parent.Header[8][1] + "&language=" + parent.language;
  if (HeadList.length > 0 && !ReportIsSaved && !DirectEdit) {
    if (!confirm("The current report has not been saved and you may lose it.  Do you wish to continue?")) {
      return;
    }
  }
  NewReport();              // Leaving in a "back button" acceptable state.
  ProcessHeader(parent.Header); 
  SetCookie("ESSHead","");
  SetCookie("ESSPurp","");
  SetCookie("ESSRcpt","");
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
    if (confirm("OK to close current report?\n\nClick OK to close current report and start\na new one.\n\nAny work that you have entered since your\nlast save will be lost!\n\nIf you don't start a new report, any new work\nwill be added to the current report.\n\nIf in doubt, cancel, save report and then\nstart a new report.")) {
      parent.defDateStr = "";
      NewReport();
      ProcessHeader(parent.Header);
      if (xfunc) eval(xfunc); 
    }
  }
}

function NewieIfNotSaved(ScreenHTML) {
  if (ReportIsSaved) {
   NewReport();
   TransWindow(ScreenHTML);
  } else {
   Newie(ScreenHTML);
  }
}

function ShowHistoryTrans(ScreenHTML) {
  if (ReportIsSaved || getAuditEdit()) {  //JH 2007-10-11
   BackSpaceToReport = -3;                //JH 2009-5-29  
   TransWindow(ScreenHTML);
  } else {
   alert("You must save your current report changes before viewing transaction detail.\n-- Select 'Show Report' above to view report.\n-- Select 'Save Report' on left to save work.");
  }
}

function Newie(ScreenHTML,singlePurpose) {
  if (singlePurpose == null) singlePurpose = false;
  if (HeadList.length > 0) {
    parent.main.document.open("text/html");
    parent.main.document.write("<html>\n");
    parent.main.document.write("<head><title>New Report</title></head>\n");
    parent.main.document.write("<body>\n");
    if (!ReportIsSaved) {
    parent.main.document.write("<p align=\"left\"><big><em><big>The current report has been modified but not yet saved on the server.&nbsp; Please select one of the following choices:</big></em></big></p>\n");
    } else {    
    parent.main.document.write("<p align=\"left\"><big><em><big>You currently have a report in memory.&nbsp; Please select one of the following choices:</big></em></big></p>\n");
    }
    parent.main.document.write("<font size=\"5\"><em><ul>\n");
    if (!ReportIsSaved) {
      parent.main.document.write("<li><p align=\"left\"><a href=\"javascript: void parent.contents.TransWindow('"+defaultHome +"saveXMLFile.html')\">Save - Save current report to server and then reselect option.</a></p></li>\n");
    }
    if (!singlePurpose) parent.main.document.write("<li><p align=\"left\"><a href=\"javascript: void parent.contents.TransWindow('" + ScreenHTML + "')\">Return - Continue working in current report.</a></p></li>\n");
    if (!ReportIsSaved) {
    parent.main.document.write("<li><p align=\"left\"><a href=\"javascript: void parent.contents.NewMaybe('parent.contents.TransWindow(\\\'" + ScreenHTML + "\\\')')\">Close - Close current report without saving changes.</a></p></li>\n");
    } else {
    parent.main.document.write("<li><p align=\"left\"><a href=\"javascript: void newReport()\">Close - Close current report and start a new report.</a></p></li>\n");
    }
    parent.main.document.write("</ul></em></font>\n");
    parent.main.document.write("<Script Language=\"JavaScript\">\n");
    parent.main.document.write("function newReport() {\n");
    parent.main.document.write("parent.defDateStr = \"\";\n");
    parent.main.document.write("parent.contents.NewReport();\n");
    parent.main.document.write("parent.contents.ProcessHeader(parent.Header);\n"); 
    parent.main.document.write("parent.contents.TransWindow(\"" + ScreenHTML + "\"); }\n"); 
    parent.main.document.write("</script></body></html>\n");
    parent.main.document.close();
  } else {
    parent.defDateStr = "";
    parent.contents.NewReport();
    if (getNameValue(Header,"persnum") == getDBValue(parent.Header,"persnum")) {
      parent.contents.ProcessHeader(parent.Header); 
    }
    parent.contents.TransWindow(ScreenHTML); 
  }
}

function Copie(ScreenHTML) {
  if (confirm("Click OK if you want to create a copy of this report\n\nThis option will make a copy of the \nreport that is currently open.\nUse the 'Show Current Report' option\nto see the report that is open.")) {
    ReProcessHeader(Header); 
    var x = setNameValue(Header,"editable","YES");
    x = setNameValue(Header,"credate",getNameValue(parent.Header,"credate"));
    x = setNameValue(Header,"cretime",getNameValue(parent.Header,"cretime"));
    if (getNameValue(parent.Header,"persnum") == getNameValue(Header,"persnum")) {
       x = setNameValue(Header,"email",getNameValue(parent.Header,"email"));
       x = setNameValue(Header,"name",getNameValue(parent.Header,"name"));
       x = setNameValue(Header,"phone",getNameValue(parent.Header,"phone"));
       x = setNameValue(Header,"location",getNameValue(parent.Header,"location"));
       x = setNameValue(Header,"depart",getNameValue(parent.Header,"depart"));
       x = setNameValue(Header,"company",getNameValue(parent.Header,"company"));
       x = setNameValue(Header,"currency",getNameValue(parent.Header,"currency"));
    }
    ListMemory()
    alert("Report copied - This is the new report");
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
ProcessHeader(parent.Header);

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
  var s = HTMLFile + commChar + "email=" + parent.Header[8][1] + "&reporter=" + getNameValue(Header,"persnum") + "&ccode=" + parent.CCode + "&database=" + parent.database;
  return s
}

function NeedAReport(HTMLFile,ListArray,index) { 
  if (HeadList.length > 0 || TailList.length > 0 || DirectEdit) {
    TransWindow(HTMLFile,ListArray,index);
  } else {
    alert("You cannot proceed with this option!\n\nThe current report doesn't contain any travel information.\nIf you have entered data on a form, ensure\nthat you have clicked the grey button.\nOtherwise you will lose your data.");
  }
}

function OnlyIfEditable(HTMLFile,ListArray,index) { 
  if ((HeadList.length > 0 || TailList.length > 0) && getEditable()) {
    var x = getNameValue(Header,"status");
    x = x.toUpperCase();
    if ( x == "NEW" || x == "CHANGED NEW" ||confirm("This option will resubmit this report for processing. It will unlink this\nreport from the current copy in the central database for tracking purposes.\nThe report will be relinked to the new copy in the central database after submission.\n\nContinue?") == true) {   
       TransWindow(HTMLFile,ListArray,index);
    }
  } else {
    alert("You cannot proceed with this option!\n\nEither the current report cannot be changed\nbecause of its status in the central database, or\nthe report doesn't contain any travel information.\n\nIf you have entered data on a form, ensure\nthat you have clicked the grey button.\nOtherwise you will lose your data.");
  }
}

function NeedAPurpose(HTMLFile,ListArray,index) { 
  if (HeadList.length > 0) {
    TransWindow(HTMLFile,ListArray,index);
  } else {
    alert("You cannot proceed with this option!\n\nThe current report doesn't contain any report purpose.\nIf you have entered data on a form, ensure\nthat you have clicked the grey button.\nOtherwise you will lose your data.");
  }
}

function OnlyIfChanged(HTMLFile,ListArray,index) {
  if (!ReportIsSaved && getEditable()) {
    NeedAReport(HTMLFile,ListArray,index);
  } else { 
    if (getEditable()) {  //if report is editable then if must be ReportIsSaved (not changed)
       alert("There have been no changes made to the current report!\n\nThe save action will not be performed.\n\nIf you have entered data on a form, ensure\nthat you have clicked the grey button.\nOtherwise you will lose your data.");
    } else {
       alert("You cannot proceed with this option!\n\nThe current report cannot be changed\nbecause of its status in the central database.");
    }
  }
}

var CommNotOK = "Error - Not all script has loaded yet!\nPlease retry this option after expense client is ready (lower left).\nIf not ready within a reasonable time,\nplease close browser and try again\nIf problem persists, contact support."

function TransWindow(HTMLFile,ListArray,index,noSaveFlag) {
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
        case "ListBuffer":
          break;
        default:
          alert(ListArray + " was not anticipated by TransWindow()!"); 
          ListBuffer = new Array();
      }
    } else {
      ListBuffer = new Array();
    }
    parent.main.location = HTMLFile;
  } else {
    alert(CommNotOK);
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
    alert(CommNotOK);
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

function setTransaction(TheForm) {
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
           if (TheForm.elements[ListBuffer[i][$name$]].subtype == "list") {
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
           TheForm.elements[ListBuffer[i][$name$]].value = ListBuffer[i][$value$];
           break; 
        default:
          alert("Form: cannot load " + ListBuffer[i][$name$] + ", type:" + TheForm.elements[ListBuffer[i][$name$]].type + ", value:" + ListBuffer[i][$value$]);
      }  //need to add the other types eventually
    }
  }
}

function deleteItem(ListName, index) {
  if (confirm("Are you sure you want to delete this item?")) {
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
        alert("Cannot delete this item - It still has receipts that reference it!");
        return;
      }
      var xThis = getNumericValue(HeadList[index],"weight");  //checking for weight being orphaned
      var xTotal = getTotalValueFor(HeadList,"weight");
      var SearchStr = "Weight;"
      if (xThis > 0 && xThis == xTotal) {
         if (getTotalValueFor(TailList,'amount','xref',SearchStr) > 0 || getTotalValueFor(TailList,'amount','expense_1_xref',SearchStr) > 0) {
          alert("Cannot delete this item - There are still items being split among purposes");
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

function UpdateReport(TransClass, TransType, TheForm) {
//updates the appropriate report array from a screen
 if (dupFlagOK) { 
  dupFlagOK = false;    
  if (genNoError() && cusNoError()) {
    if (!TheForm) var TheForm = parent.main.document.forms[0];  
    var ThisName;
    var SubType;
    var ListType;
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
    
      ListType = null;
      if (TheForm.elements[i].getAttribute) {
        ListType = TheForm.elements[i].getAttribute("listtype");
      } else if (TheForm.elements[i].listtype){
        ListType = TheForm.elements[i].listtype;
      } 
      if (ListType == null) ListType = "";
        
      switch (SubType) {
        case "text":      
            ThisTrans[j] = Array(ThisName, TheForm.elements[i].value);
            j = j + 1;
            break;    
        case "select-one":
            if (TheForm.elements[i].selectedIndex > -1) {
              if (ListType == "value-in") {
                WorkStr = Array(ThisName, TheForm.elements[i].options[TheForm.elements[i].selectedIndex].value);
              } else {
                WorkStr = Array(ThisName, TheForm.elements[i].options[TheForm.elements[i].selectedIndex].text);
              }
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
        case "textarea":      
            ThisTrans[j] = Array(ThisName, TheForm.elements[i].value);
            j = j + 1;
            break;    
        case "hidden":      
            ThisTrans[j] = Array(ThisName, TheForm.elements[i].value);
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
            var ThisList = new Array();
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
            alert("Field '" + SubType + "' not anticipated by UpdateReport() in : " + TransType);
      }
    }
    UpdateInternal(TransClass, TransType, ThisTrans);
  } else {
    alert("An error has been detected.");
  }
  dupFlagOK = true;
 } 
}

function getXrefElementName(eleObj) {
  var retVal = "";
  if (navigator.userAgent.indexOf("Mozilla") > -1 || navigator.appVersion.indexOf("compatible") > -1) {
     if (eleObj.attributes.getNamedItem("xref")) retVal = eleObj.attributes.getNamedItem("xref").value;
  } else if (navigator.appVersion.indexOf("MSIE") > -1) {
     if (eleObj.xref) retVal = eleObj.xref;
  } else {
     alert("Invalid Browser is being used.  You should use either\nMS IE or a Mozilla-based browser.");
  }
  return retVal;
} 

 function getVoucherValue(eleObj) {
   var retVal = "";
   if (navigator.userAgent.indexOf("Mozilla") > -1 || navigator.appVersion.indexOf("compatible") > -1) {
     if (eleObj.attributes.getNamedItem("voucher")) retVal = eleObj.attributes.getNamedItem("voucher").value;
   } else if (navigator.appVersion.indexOf("MSIE") > -1) {
     if (eleObj.voucher) retVal = eleObj.voucher;
   } else {
     alert("Invalid Browser is being used.  You should use either\nMS IE or a Mozilla-based browser.");
   }
   return retVal;
 }
 
 function getMsgdataValue(eleObj) {
   var retVal = "";
   if (navigator.userAgent.indexOf("Mozilla") > -1 || navigator.appVersion.indexOf("compatible") > -1) {
     if (eleObj.attributes.getNamedItem("msgdata")) retVal = eleObj.attributes.getNamedItem("msgdata").value;
   } else if (navigator.appVersion.indexOf("MSIE") > -1) {
     if (eleObj.msgdata) retVal = eleObj.msgdata;
   } else {
     alert("Invalid Browser is being used.  You should use either\nMS IE or a Mozilla-based browser.");
   }
   return retVal;
 } 
 
 function getReply2Value(eleObj) {
   var retVal = "";
   if (navigator.userAgent.indexOf("Mozilla") > -1 || navigator.appVersion.indexOf("compatible") > -1) {
     if (eleObj.attributes.getNamedItem("reply2")) retVal = eleObj.attributes.getNamedItem("reply2").value;
   } else if (navigator.appVersion.indexOf("MSIE") > -1) {
     if (eleObj.reply2) retVal = eleObj.reply2;
   } else {
     alert("Invalid Browser is being used.  You should use either\nMS IE or a Mozilla-based browser.");
   }
   return retVal;
 } 
 
 function getRcpt2Value(eleObj) {
   var retVal = "";
   if (navigator.userAgent.indexOf("Mozilla") > -1 || navigator.appVersion.indexOf("compatible") > -1) {
     if (eleObj.attributes.getNamedItem("rcpt2")) retVal = eleObj.attributes.getNamedItem("rcpt2").value;
   } else if (navigator.appVersion.indexOf("MSIE") > -1) {
     if (eleObj.rcpt2) retVal = eleObj.rcpt2;
   } else {
     alert("Invalid Browser is being used.  You should use either\nMS IE or a Mozilla-based browser.");
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
  var timer = setTimeout("ListMemory()",1000);
}

function ListMemory(){
//creates the simple on-screen report that can be used to view and select various items.
//this is normally called after most actions to show the used the current status of his report arrays.
  var xrefNum = getNameValue(Header,"reference");
  parent.main.document.open("text/html");
  parent.main.document.write("<HTML><HEAD><link rel=\"stylesheet\" href=\"" + defaultHome + "expense.css\" type=\"text/css\"></HEAD><BODY>\n");
  parent.main.document.write("<s" + "cript type=\"text/javascript\">");
  parent.main.document.write("if (screen.width < 1024) {");
  parent.main.document.write("var link = document.getElementsByTagName(\"link\" )[ 0 ];");
  parent.main.document.write("link.href = \"" + defaultHome + "expense800.css\"");
  parent.main.document.write("}");
  parent.main.document.write("</s" + "cript>");
  parent.main.document.write("<h1>Report Information</em>:</h1>\n"); 
  parent.main.document.write("<table border=\"0\" cellspacing=\"0\" width=\"70%\" bordercolordark=\"#008080\">\n");
  if (Header.length == 0) {
      parent.main.document.write("</table><br><strong>No Receipt information to display.</strong></BODY></HTML>");
      return;
  }
//place the next stuff in an array from company.js eventually
  ListRepHeader(xrefNum); //found in the ESS/AuditProfile.jsp
  parent.main.document.write("</table><BR>\n");
  
  if (HeadList.length <= 1) {
     parent.main.document.write("<h2>Report Purpose:</h2>");
  } else {
     parent.main.document.write("<h2>Report Purposes Entered:</h2>");
  }

  if (HeadList.length == 0) {
    parent.main.document.write("<h2>&nbsp;No report purpose entered yet!</h2><BR><BR>");
  } else {
    backcolor = "class=\"TableData offsetColor\"";  
    oldbackcolor = "class=\"TableData\"";
    parent.main.document.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"3\" width=\"90%\" bordercolordark=\"#008080\">\n");
    PrintHeadList();
    parent.main.document.write("</table><br>");
  }
  parent.main.document.write("<h2>Receipts Entered:</h2>\n");
  if (TailList.length == 0) {
    parent.main.document.write("<h2>&nbsp;No receipts entered yet!</h2><BR><BR>");
  } else {
    backcolor = "class=\"TableData offsetColor\"";  
    oldbackcolor = "class=\"TableData\"";
    parent.main.document.write("<form><table border=\"0\" cellspacing=\"0\" cellpadding=\"3\" width=\"90%\" bordercolordark=\"#008080\">\n");
    PrintTailList();
    parent.main.document.write("</table></form><BR>\n");
  }
  parent.main.document.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"3\" width=\"60%\" bordercolordark=\"#008080\">\n");
  
  // Following is located in company section
  setRepTotals();
  
  parent.main.document.write("</table><br>");
  parent.main.document.write("</BODY></HTML>");
  parent.main.document.close();
}

function ListHeader(title, value, link, text) {
  parent.main.document.write("<tr>\n");
  if (title != null && title != "") {
    parent.main.document.write("<td width=\"25%\" " + backcolor +"><strong>" + title + ": </strong></td>\n");
  } else {
    parent.main.document.write("<td width=\"25%\" " + backcolor +"></td>\n");
  }
  parent.main.document.write("<td width=\"50%\" " + backcolor +">" + value + "</td>\n");
  if (link && text != null) {
    parent.main.document.write("<td width=\"25%\" " + backcolor +"><a href=\"" + link + "\"><span class='ExpenseReturnLink'>" + text + "</span></a></td>\n");
  } else if (link && getEditable()) {
    parent.main.document.write("<td width=\"25%\" " + backcolor +"><a href=\"" + link + "\"><span class='ExpenseReturnLink'>edit</span></a></td>\n");
  } else {
    parent.main.document.write("<td width=\"25%\" " + backcolor +"></td>\n");
  }
  parent.main.document.write("</tr>\n");
  newbackcolor = backcolor;
  backcolor = oldbackcolor; 
  oldbackcolor = newbackcolor;
}

function dispPersNo(x) {
  if (x.substr(3,1) == "-" && x.substr(6,1) == "-") {
    x = "***-**-" + x.substr(7,4);
  }
  return x;
}

function PrintHeadList() {
  var Titles = getHLTitles();
  var cA = new Array("c1","c2","c3","c4");
  var fA = getHLFormat();
  PrintItems(Titles,"",0,cA,fA);
  cA = getHLPrint();
  var deletable = (HeadList.length == 1) ? false : true;
  for (var j = 0; j < HeadList.length; j++){
    PrintItems(HeadList[j],"HeadList",j,cA,fA,getHLSubLines(),defaultHead,deletable);
  }
}

function PrintTailList() {
  var Titles = getTLTitles();
  var cA = new Array("c1","c2","c3","c4");
  var fA = getTLFormat();
  PrintItems(Titles,"",0,cA,fA);
  cA = getTLPrint();
  for (var j = 0; j < TailList.length; j++){
    PrintItems(TailList[j],"TailList",j,cA,fA,getTLSubLines(),defaultTrans);
  }
}

function PrintItems(trans,list,index,cA,fA,subLines,defaultHTML,deletable){
  if (!subLines) {
     var subLines = Array();
  }
  if (deletable == null) deletable = true;
  var SubText = "";
  var link1;
  var link2;
  var outstring = "";
  if (cA.length > 3) {
     outstring = FlatDetail(trans,cA.slice(3));
  }
  if (subLines.length > 0) {
    var dd = "";
    for (var t = 0; t < subLines.length; t++) {
     SubText += dd + SubDetail(trans,subLines[t]);
     dd = "<br>";
    }
  }
  if (SubText.length > 0) {
     if (outstring.length > 0) {
       outstring += "<br>" + SubText; 
     } else {
       outstring = SubText;
     }
  }

  if (list == "") {
    link1 = "";
  } else {
    link1 = "parent.contents.TransWindow('"  + defaultHTML + trans[$type$] + ".html','"  + list + "'," + index + ")";
    link2 = "parent.contents.deleteItem('" + list + "', " + index +");parent.contents.ListDelay()"; 
  }
  parent.main.document.write("<tr>\n");
  parent.main.document.write("<td width=\"10%\" " + fA[0] + " " + backcolor +">" + FlatCell(trans,cA[0],index) + "</td>\n");
  parent.main.document.write("<td width=\"15%\" " + fA[1] + " " + backcolor +">" + FlatCell(trans,cA[1],index) + "</td>\n");
  parent.main.document.write("<td width=\"15%\" " + fA[2] + " " + backcolor +">" + FlatCell(trans,cA[2],index) + "</td>\n");
  parent.main.document.write("<td width=\"40%\" " + fA[3] + " " + backcolor +">" + outstring +"</td>\n");
  if (link1 == "" || !getEditable()) {
    parent.main.document.write("<td width=\"10%\" " + backcolor +"></td>\n");
    parent.main.document.write("<td width=\"10%\" " + backcolor +"></td>\n");
  } else {
    parent.main.document.write("<td width=\"10%\" " + backcolor +"><a href=\"javascript:void " + link1 + "\"><span class='ExpenseReturnLink'>edit</span></a></td>\n");
    if (deletable) {
       parent.main.document.write("<td width=\"10%\" " + backcolor +"><a href=\"javascript:void " + link2 + "\"><span class='ExpenseReturnLink'>delete</span></a></td>\n");
    } else {
       parent.main.document.write("<td width=\"10%\" " + backcolor +"></td>\n");
    }
  }
  parent.main.document.write("</tr>\n");
  newbackcolor = backcolor;
  backcolor = oldbackcolor; 
  oldbackcolor = newbackcolor;
}

function FlatDetail(trans, Arr) { 
  var outstring = "";
  var NameStr;   
  for (var i = 0; i < Arr.length; i++) {
    NameStr = Arr[i];
    outstring += FlatCell(trans, NameStr);
  }
  return outstring;
}

function FlatCell(trans, NameStr, index) {
  var outstring = "";
  //normally show a value in the items list, but if it starts with $ it is treated as
  //a literal.  Used to format the detailed string.
  if (NameStr.substr(0,1) == "$") {
     outstring = outstring + NameStr.substr(1) + "&nbsp;";
     if (index != null) {
       var regexp = /\$index\$/g ;
       outstring = outstring.replace(regexp,""+index);
     }
  } else {
     outstring = outstring + getItemValue(trans,NameStr) + " "; 
  }
  return outstring;
}

function SubDetail(trans,subLines) {
  var xStr = "";
  if (subLines.length > 0) {
    var x = subLines[0];
    if (x.substr(x.length -1,1) == "_") {
      xStr = SubFlatDetail(trans,subLines);
    } else {
      xStr = SubHierDetail(trans,subLines);
    }
  }
  return xStr;
}

function SubHierDetail(trans,subLines) {
  var xStr = "";
  var y = subLines.slice(1);
  var x = getItemValue(trans, subLines[0]);
  var dd = "";
  if (typeof(x) == "object") {   
    for (var i = 0; i < x.length; i++) {  
      xStr += dd + FlatDetail(x[i], y);
      dd = "<br>";
    }
  }
  return xStr;
}

function SubFlatDetail(trans,subLines) {
  var i;
  var j;
  var VN;
  var VIndex;
  var SL = trans[$items$];     //list of name value pairs to search through
  var MClass = subLines[0]; //primary class, just used for convenience
  var RL = new Array(); //working array -> [0,n] titles; [1,n] associated values...[n,n]
  RL[0] = subLines;
  var outstring = "";
  var D;
  var NP;
  var wStr;
  for (i = 0; i < SL.length; i++) {  //This part steps up
    if (SL[i][$name$].indexOf(MClass) == 0) {
      VN = SL[i][$name$];
      VIndex = parseInt(VN.substring( VN.indexOf("_") + 1 , VN.lastIndexOf("_") ));
      for (j = 1; j < subLines.length; j++) {
        if (VN.indexOf(subLines[j]) > -1) {
          if (!RL[VIndex]) RL[VIndex] = new Array();
          RL[VIndex][j] = SL[i][$value$];
        } else {
          wStr = subLines[j];
          if (wStr.substr(0,1) == "$") {
            if (!RL[VIndex]) RL[VIndex] = new Array();
            RL[VIndex][j] = wStr;
          }
        } 
      }
    }
  }
  NP = "";
  for (i = 1; i < RL.length; i++) {
    D = "";
    outstring += NP;
    NP = "";
    if (notEmptyLine(RL[i])) {
      for (j = 1; j < RL[i].length; j++) {
        if (RL[i][j]) {
          wStr = RL[i][j];
          if (wStr.substr) {                //8-13-2010
             if (wStr.substr(0,1) == "$") { ;
               outstring += D + wStr.substr(1);
               D = "&nbsp;";
             } else {
               outstring += D + wStr;
               D = " ";
             }
             NP = "<br>";
          }
        }
      }
    }
  }
  return outstring;
}

function notEmptyLine(x) {    
  var retVal = false;
  if (x && x != null) {  //2007-08-09 ?? added not null
    for (var k = 1; k < x.length; k++) {
      if (x[k] && x[k].substr(0,1) != "$"){
        retVal = true;      
        k = x.length;
      }
    }
  }
  return retVal;
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
  parent.main.document.open("text/xml");
  parent.main.document.write(CreatePersDBXML(dbarray));
  parent.main.document.close();
}
function PrintXML() {
//This function attempts to write the report in XML for debugging
  parent.main.document.open("text/xml");
  parent.main.document.write(CreateXML());
  parent.main.document.close();
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
      alert("Warning - Your report has not been safe-stored on your PC!\nProcessing will continue.");
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
  parent.main.document.open("text/html");
  parent.main.document.write("<HTML><BODY onLoad='DoLoad()'>\n");
  parent.main.document.write("<p><big><em><strong><big>Expense Submittal System: </big><br>\n");
  parent.main.document.write(Msg + "\n"); 
  parent.main.document.write("</strong></em></big></p>\n");
  parent.main.document.write("\n<S" + "cript Language='JavaScript1.2'>\n");
  parent.main.document.write("function DoLoad() {\n");
  parent.main.document.write("setTimeout('parent.contents.ListDelay()',3000);");
  parent.main.document.write("\n}\n");
  parent.main.document.write("\n</S" + "cript>\n");
  parent.main.document.write("</BODY></HTML>");
  parent.main.document.close();
 } else {
  alert("A saved report was not found.");
 }
} 

function writeDelayMsg(xJsp, xMsg) {

  if (xMsg == null) xMsg = "Server is processing your request...";
  parent.main.document.open("text/html");
  parent.main.document.write("<HTML><BODY onLoad='DoLoad()'>\n");
  parent.main.document.write("<BIG><STRONG>\n");
  parent.main.document.write(xMsg + "\n");
  parent.main.document.write("</BIG></STRONG>\n");
  parent.main.document.write("\n<S" + "cript Language='JavaScript'>\n");
  parent.main.document.write("function DoLoad() {\n");

  parent.main.document.write("parent.contents.TransWindow(\"");
  parent.main.document.write(xJsp);
  parent.main.document.write("\");");

  parent.main.document.write("\n}\n");
  parent.main.document.write("\n</S" + "cript>\n");
  parent.main.document.write("</BODY></HTML>\n");
  parent.main.document.close();
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
    alert ("Your browser does not support AJAX!");
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