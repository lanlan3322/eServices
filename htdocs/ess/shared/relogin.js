//relogin.js 
//copyright James Holton, 2010

var ReloginObj1;
var ReloginObj2;
var ReloginObj3;

function screenLoad() {
   ReloginObj1 = GetXmlHttpObject();
   ReloginObj2 = GetXmlHttpObject();
   ReloginObj3 = GetXmlHttpObject();
   loadMessage("EXPIRED_SESSION_LOGIN", reloginMsgChanged, ReloginObj1);
   loadMessage("reloginPassword", reloginPasswordChanged, ReloginObj2);
   loadMessage("Login", reloginSubmitChanged, ReloginObj3);
   document.forms[formStartNumber].password.focus();
   return true;
}

var cancelThisRequest = "";
function screenUnload() {
  var retVal = true; 
  return retVal;
}

function loadMessage(msgCode, msgHandler, httpAjaxObj) {
//  httpAjaxObj = GetXmlHttpObject();
  getInfo(httpAjaxObj, appServer + "/" + appFolder + "/GetMsg.jsp?language=" + parent.language + "&message=" + msgCode, msgHandler, true);
}

function reloginMsgChanged() {
  var x = ReloginObj1.readyState;
  if ( x == 4 )
  { 
       var newMsg = ReloginObj1.responseText;
       document.getElementById("reloginMessage").innerHTML = newMsg;
  }
}

function reloginPasswordChanged() {
  var x = ReloginObj2.readyState;
  if ( x == 4 )
  { 
       var newMsg = ReloginObj2.responseText;
       document.getElementById("reloginPassword").innerHTML = newMsg;
  }
}

function reloginSubmitChanged() {
  var x = ReloginObj3.readyState;
  if ( x == 4 )
  { 
       var newMsg = parent.hardTrim(ReloginObj3.responseText);
       document.getElementById("btEnter").value = newMsg;
  }
}

function systemMsg() {
  var x = httpLogoObj.readyState;
  if ( x == 4 )
  { 
       var newMsg = httpLogoObj.responseText;
       document.getElementById("main").innerHTML = newMsg;
  }
}

function submitRec() {
  with (document.forms[formStartNumber]) {
    email.value = parent.XMLReplace(parent.getNameValue(parent.myHeader, "email"));
    language.value = parent.language;
    password.value = parent.XMLReplace(alltrim(password.value)); 
  }
//  postSimpleForm(parent.defaultApps + "ajax/Relogin.jsp", document.forms[formStartNumber], false, saveLoginMsg);
  postSimpleForm("/ess-app/ajax/Relogin.jsp", document.forms[formStartNumber], true, saveLoginMsg);
}

function saveLoginMsg() {
  var x = httpXMLObj.readyState;
  if ( x == 4 )
  { 
     var msg = httpXMLObj.responseText;
     var msgStart = msg.indexOf("~OK");
     if (msgStart > -1) {
        initValues(msg.substring(msgStart + 4, msg.indexOf("]")), msg.substring(msg.indexOf("]")+ 1));
     } else {
        msgStart = msg.indexOf("~NO");
        if (msgStart > -1) {
           alert(msg.substring(msgStart + 3));   
        } else {
           httpLogoObj = GetXmlHttpObject();
           loadMessage("ERROR_INVALID_RELOGIN_ATTEMPT",systemMsg,httpLogoObj);
        }  
     }     
  }
}

function initValues(msgCCode, displayMsg) {
   var workStr = parent.LastHTMLFile;
   parent.CCode = msgCCode;
   if (workStr != null && workStr != "") {
       var regExp = /&ccode=\d*&/g
       parent.LastHTMLFile = workStr.replace(regExp, "&ccode=" + parent.CCode + "&");
//       var Timer = setTimeout("parent.TransWindow(parent.LastHTMLFile)",2000);
         httpLogoObj = GetXmlHttpObject();
         loadMessage("RELOGIN_OK",systemMsg,httpLogoObj);
   } else {
        document.getElementById("main").innerHTML = displayMsg;
   }     
}

function hardTrim(arg) {
	var trimvalue = "";

	arglen = arg.length;
	if (arglen < 1) return trimvalue;

	i = 0;
	pos = -1;
	while (i < arglen) {
		if (arg.charCodeAt(i) > 32 && !isNaN(arg.charCodeAt(i))) {
			pos = i;
			break;
		}
		i++;
	}

	var lastpos = -1;
	i = arglen;
	while (i >= 0) {
		if (arg.charCodeAt(i) > 32 && !isNaN(arg.charCodeAt(i))) {
			lastpos = i;
			break;
		}
		i--;
	}

		trimvalue = arg.substring(pos,lastpos + 1);

	return trimvalue;

}

