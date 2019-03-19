<%--
XReport.jsp - Main ESS frameset 
Copyright (C) 2004, 2011  R. James Holton

This program is free software; you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation; either version 2 of the License, or (at your option) 
any later version.  This program is distributed in the hope that it will be 
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
Public License for more details.

You should have received a copy of the GNU General Public License along with 
this program; if not, write to the Free Software Foundation, Inc., 
675 Mass Ave, Cambridge, MA 02139, USA. 
--%>
<jsp:useBean id = "Extract"
     class="ess.EditTables"
     scope="page" />

                    
<%-- See XLogin.jsp for other beans being used --%>
<%
Extract.setConnection(PersFile.getConnection()); 
Extract.setSQLTerminator(PersFile.getSQLTerminator());

Lang.setLanguage(PersFile.getLanguage());

String essCustomFolder = SystemDOM.getDOMTableValueFor("configuration","customfolder","ess");
String essAppFolder = SystemDOM.getDOMTableValueFor("configuration","appfolder","ess-app");
String essWebFolder = SystemDOM.getDOMTableValueFor("configuration","webfolder","ess");
String essDateFormat = SystemDOM.getDOMTableValueFor("configuration","dateformat","MM/dd/yyyy"); //Not yet used

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<!-- Copyright R. James Holton, Inc. 2002, 2014, All rights reserved -->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="/ess/expenseLinko.css" type="text/css">
<!--[if IE 7]> <link rel="stylesheet" href="/ess/expenseLinko_ie7.css" type="text/css" media="screen" /> <![endif]-->
<!--[if IE 8]> <link rel="stylesheet" href="/ess/expenseLinko_ie8.css" type="text/css" media="screen" /> <![endif]-->
<link rel="stylesheet" href="/ess/expenseReceipts.css" type="text/css">
  <title>e-Services</title>
  <link rel="stylesheet" href="//code.jquery.com/ui/1.12.0/themes/base/jquery-ui.css">
  <link rel="stylesheet" href="/resources/demos/style.css">
  <script src="https://code.jquery.com/jquery-1.12.4.js"></script>
  <script src="https://code.jquery.com/ui/1.12.0/jquery-ui.js"></script>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
</head>
<body onLoad="SetCommOK();loadImageAJAX();runLoadWork();checkForAddresses()" onUnload="saveWork()">
<div id="wrapper"><!--linkoCode-->
	<script language = "Javascript">
    var database = "<%= database %>";
    var company = "<%= company %>";
    var syslevel = "ess 8.0.0";
    var DateObj = new Date();
    
    var myHeader = new Array();  //Report header information
    myHeader[0] = ["persnum","<%= PersFile.getPersNum() %>"];
    myHeader[1] = ["name","<%= PersFile.getName() %>"];
    myHeader[2] = ["phone","<%= PersFile.getPhone() %>"];
    myHeader[3] = ["location","<%= PersFile.getLocation() %>"];
    myHeader[4] = ["depart","<%= PersFile.getDepartment() %>"];
    myHeader[5] = ["credate","<%= CD.getStrFromDate(CD.date,PersFile.getDateFormat()) %>"];
    myHeader[6] = ["cretime","<%= CD.getSimpleTime(CD.date) %>"];
    myHeader[7] = ["admin1","<%= PersFile.getPersNum() %>"];
    myHeader[8] = ["email","<%= PersFile.getEmailAddress() %>"];
    myHeader[9] = ["status","New"];
    myHeader[10] = ["currency","<%= PersFile.getCurrency() %>"];
    myHeader[11] = ["company","<%= PersFile.getCompany() %>"];
    myHeader[12] = ["dateformat","<%= PersFile.getDateFormat() %>"];
    myHeader[13] = ["numberformat","<%= PersFile.getNumberFormat() %>"];
    
    var Vehicle = "<%= PersFile.vehicle %>";
    <% if (!PersFile.getServiceDate().equals("")) { %>
    var Servdate ="<%= CD.getSimpleDate(CD.getDateFromXBase(PersFile.getServiceDate())) %>";
    <% } else { %>
    var Servdate ="";
    <% } %>
    var Weekend = "<%= CD.getPreviousWeekend(CD.date) %>";
    var Mileage = "<%= PersFile.getMileage() %>"; 
    var MilesType = "<%= PersFile.getMilesType() %>"; 
    var MList = <%= Extract.getMileage(PersFile.getCompany(),PersFile.getDateFormat(),PersFile.getDecimal()) %>;
    var Category = "<%= PersFile.getCategory() %>";
    var Level = "<%= PersFile.getSecurityLevel() %>";
    var PersDBase = <%= Rep2.getDBase() %>;
    var PersDBSave = false;
    var WorkDBase = [];
    var defPurpose = "0";  //used in calendar.js
    var defDateStr = ""
    var CCode = "<%= PersFile.getChallengeCode()%>";
    var CommOK = false;
    var activityFlag = true;
    var messageFlag = true;
    
    var webServer = "<%= PersFile.getWebServer() %>";
    var appServer = "<%= PersFile.getAppServer() %>";
    var customFolder = "<%= essCustomFolder %>";
    var webFolder = "<%= essWebFolder %>";
    var appFolder = "<%= essAppFolder %>";
    <% if (PersFile.isAuditor()) {%>var isAuditor = true; <%} else {%>var isAuditor = false;<%}%> 
    <% if (PersFile.isAdmin() || PersFile.isClerk(PersFile.getDepartment())) {%>var isClerk = true; <%} else {%>var isClerk = false;<%}%>
    var language  = "<%= PersFile.getLanguage() %>";
    var dateFormat  = "<%= PersFile.getDateFormat() %>";
    var numberFormat  = "<%= PersFile.getNumberFormat() %>";
    var decimal = "<%= PersFile.getDecimal() %>";
    var separator = "<%= PersFile.getSeparator() %>";
    
    var defaultHome = webServer + "/" + webFolder + "/";
    var defaultHead = webServer + "/" + webFolder + "/" + customFolder + "/";
    var defaultTrans = webServer + "/" + webFolder + "/aa/";  
    var defaultApps = appServer + "/" + appFolder + "/";
    var entryScreen = "<%= PersFile.getEntryScreen() %>";
    
    var formStartNumber = 2;
    
    window.defaultStatus = "<%= Lang.getString("JAVASCRIPT_LOADING") %>";
    function SetCommOK() {
      CommOK = true;
      window.defaultStatus = "<%= Lang.getString("JAVASCRIPT_READY") %>";
      //sendLog();
    
      setGeneralLimit("<%= PersFile.getCurrency() %>");
      DirectEdit = false;  
      setDBPair(PersDBase,"last_report", "");
    
    }
    
    function SetLogoutOK() {
      if (HeadList.length > 0 && !ReportIsSaved && getDBValue(PersDBase,"cookie").toUpperCase() != "NO") {
          parent.contents.CreateCookies();
          newWin = window.open('<%= PersFile.getWebServer() %>/<%= essWebFolder %>/' + getCustomFolder() + '/recover.html', 'InvalidExit', 'dependent=no, width=580, height=440, screenX=580, screenY=420, titlebar=yes, menubar=no, status=no, scrollbars=yes');
      }
    }
    
    //function sendLog() {
    //  if (!activityFlag) {
    //    parent.hidden.location = "<%= PersFile.getAppServer() %>/<%= essAppFolder %>/logging/Log.jsp?email=<%=email%>&database=<%=database%>&ccode=<%=PersFile.getChallengeCode()%>";
    //  } else {
    //    activityFlag = false;
    //  }
    //  var timehandle = setTimeout("sendLog()", 900000);
    //}
    
    </script>
    
    <form name="Userdata" id="Userdata">
      <input type="hidden" class="userData" style="behavior:url(#default#userdata)" id="ReportData" name="ReportData">
    </form>
    <form name="Serverdata" id="Serverdata">
      <input type="hidden" id="email" name="email">
      <input type="hidden" id="ccode" name="ccode">
      <input type="hidden" id="reference" name="reference">
      <input type="hidden" id="report" name="report">
      <input type="hidden" id="xaction" name="xaction">
		<input type="hidden" id="newLeaveType" name="newLeaveType">
		<input type="hidden" id="newLeaveFrom" name="newLeaveFrom">
		<input type="hidden" id="newLeaveFromAMPM" name="newLeaveFromAMPM">
		<input type="hidden" id="newLeaveTo" name="newLeaveTo">      
		<input type="hidden" id="newLeaveToAMPM" name="newLeaveToAMPM">
		<input type="hidden" id="newLeaveTotal" name="newLeaveTotal">
		<input type="hidden" id="newLeaveReason" name="newLeaveReason">
		<input type="hidden" id="newLeaveStatus" name="newLeaveStatus">
		<input type="hidden" id="newLeaveNum" name="newLeaveNum">
    </form>
    <!-- general formatting routines -->
    <script language="Javascript" type="text/javascript" src="/ess/shared/xshared1.js"></script>
    <!-- site specific error check routines -->
    <script language="Javascript" type="text/javascript" src="/ess/shared/xshared2.js"></script>
    <!-- site specific lists, generated from tables -->
    <script language="Javascript" type="text/javascript" src="/ess-app/ajax/ESSProfile.jsp"></script>
    <script language="Javascript" type="text/javascript" id="companyScript" src="/ess-app/ajax/Company.jsp"></script>
    <script language="Javascript" type="text/javascript" src="/ess-app/ajax/JSXlation.jsp"></script>
    
    <!--<div id="bannerLogo" class="ESSName">eClaim System</a></div>-->
    <div id="MenuOptions">
		<div id="menu">
			<ul id="essmenu"></ul>
			<p><%= PersFile.getName() %></p>
			<a href="javascript: void Logout()"><span id="logout">Logout</span></a>
		</div>
		<%if(false)//PersFile.depart.equalsIgnoreCase("TEST"))
		{
		%>
			<%@ include file="Menu_POWERsup.jsp" %>
		<%}
		else
		{%>
			<%@ include file="Menu_Main.jsp" %>
		<%}%>
    </div><br />
    <br />
    <br />
    <br />
    
    <script language="javascript">
    Log.println("User Agent",navigator.appVersion);
    window.onerror = function(error, url, line) {
        Log.println("Error", error + ", " + url + ", " + line);
        Log.println("Error Trace",stacktrace());
    };
    
    
    var httpLogoObj;
    
    function loadImageAJAX() {
      httpLogoObj = GetXmlHttpObject();
      getInfo(httpLogoObj, appServer + "/" + appFolder + "/GetLogo.jsp", bannerStateChanged, true);
    }
    
    function bannerStateChanged() {
      var x = httpLogoObj.readyState;
      if ( x == 4 )
      { 
           var newLogo = httpLogoObj.responseText;
           document.getElementById("bannerLogo").innerHTML = newLogo;
      }
    }
    
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
        alert ("<%= Lang.getString("ERROR_AJAX_UNSUPPORTED") %>");
        return;
      } 
      xmlHttp.onreadystatechange=stateChanged;
      xmlHttp.open("GET",url,aSync);
      xmlHttp.send(null);
    } 
    
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
          try
          {
             xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
          } 
          catch (e)
          {
             alert("<%= Lang.getString("ERROR_WRONG_BROWSER") %>");
          }      
        }
      }
    return xmlHttp;
    }
    
    
    </script>
	
    <br />

	<div id="main" name="main">Loading...</div>
	<div id="ShowAttendance" style="width:100%">
		<%@ include file="../AttendanceVOShowing.jsp" %>
	</div>
    
    <span id="ESSxScript"></span>

	</div><!--close Wrapper-->

<script language="javascript">

var httpXMLObj
function loadHTMLScreenAJAX(screenName) {
  loadScreenAJAX(webServer + "/" + webFolder + "/" + language + "/" + screenName);
}

function loadScreenAJAX(screenName) {
   Log.println("loadScreenAJAX",screenName);
   Log.println("loadScreenAJAX",stacktrace());
   var performLoad = true;
   if ( typeof screenUnload == "function") {
             performLoad = screenUnload();   //is the screen unload successful??
             Log.println("loadScreenAJAX","unload returns: " + performLoad.toString());             
   }          
   if (performLoad) {   
      httpXMLObj = GetXmlHttpObject();  
      getInfo(httpXMLObj, screenName, screenChanged, true);  //was true
      Log.println("loadScreenAJAX","getInfo() called");
   }   
}

function screenChanged() {
  var x = httpXMLObj.readyState;
  var newScript = null;
  var newFolder = null;
   
  if ( x == 4 )
  { 
     var newScreen = httpXMLObj.responseText;
     Log.println("screenChanged","Loading");
     document.getElementById("main").innerHTML = newScreen;
     Log.println("screenChanged","Done");
     var scriptTag = document.getElementById("script");  //Do we want to remove the old script? JH 2010-5-11
     if (scriptTag != null)
     {
        if ( typeof screenLoad == "function") screenLoad = null;
        if (navigator.appVersion.indexOf("MSIE") > -1 && navigator.appVersion.indexOf("compatible") < 0) {
            newScript = scriptTag.file;
            newFolder = scriptTag.folder;
            Log.println("screenChanged","MSIE");
        } else {   //SB Mozilla
            newScript = scriptTag.attributes.getNamedItem("file").value;            
            if (scriptTag.attributes.getNamedItem("folder")) newFolder = scriptTag.attributes.getNamedItem("folder").value;
            Log.println("screenChanged","Mozilla");
        }     
        Log.println("screenChanged","script: " + newScript );   
        if (newScript != null && newScript != "") {
           switchScript(newScript, newFolder);
        }
        setTimeout("startingScreen(0)", 500);  //JS multitasking doesn't work too good, was 500.  Need to come up with something better - Maybe a return value 
        // like ActiveScript = screenLoad() and change allow a null to pass through
        Log.println("screenChanged",stacktrace());
     }  else {
        Log.println("screenChanged","Null script");
     }
  }
}

function startingScreen(n) {
        Log.println("startingScreen","Checking"); 
        if ( typeof screenLoad == "function") {
             if (!screenLoad()) alert("<%= Lang.getString("JAVASCRIPT_UNSUPPORTED") %>");   //is the screen unload successful??
        }  else {
           if (n < 40) {
               Log.println("startingScreen","Not loaded yet");   
               var m = n + 1;        
               setTimeout("startingScreen(" + m + ")", 400);
           } else {
               Log.println("startingScreen","timeout");
               //alert("<%= Lang.getString("ERROR_AJAX_SCRIPT_LOAD") %>");
           }    
        }   
}

var pSeparator; 
function postSimpleForm(url, obj, async, readyStateChange) {
   var parameters = "";
   pSeparator = "";
   if (async == null) async = true;
   if (readyStateChange == null) readyStateChange = screenChanged;
   parameters = getPostParameters(obj, parameters);
   httpXMLObj = GetXmlHttpObject();
   if (httpXMLObj.overrideMimeType) {                     //??? JH 2010-05-11 Doesn't function in Mozilla
            // http_request.overrideMimeType('text/html');
   }
   httpXMLObj.onreadystatechange = readyStateChange;    //JH 2010-10-13
   httpXMLObj.open('POST', url, async);
   httpXMLObj.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
   httpXMLObj.setRequestHeader("Content-length", parameters.length);
   httpXMLObj.setRequestHeader("Connection", "close");
   httpXMLObj.send(parameters);
   Log.println("postSimpleForm",url);
}

function getPostParameters(obj,parameters) {
   for (var i=0; i<obj.childNodes.length; i++) {
      if (obj.childNodes[i].tagName == "INPUT" || obj.childNodes[i].tagName == "TEXTAREA") {
            parameters += pSeparator + obj.childNodes[i].name + "=" + encodeURIComponent( obj.childNodes[i].value );  
            pSeparator = "&";
      } else {
            parameters = getPostParameters(obj.childNodes[i], parameters);
      }      
   }
   return parameters;
}


var activeScript = "";
function switchScript(newScript,scriptLocation) 
{
   if (scriptLocation == null) scriptLocation = webServer + "/" + webFolder;
   if (newScript != activeScript) 
   {
     Log.println("switchScript",scriptLocation + "==>" + newScript);   
     var repScript = document.getElementById("activeScript");
     if (repScript != null) {
           Log.println("switchScript","removing script here");     
           repScript.parentNode.removeChild(repScript);  //This is probably useless as the JS seems to get compiled somewhere
     } 
     try {
       var oScript = document.createElement("script");
       oScript.src = scriptLocation + "/" + newScript;
       oScript.id = "activeScript";
       Log.println("switchScript","element load: " + scriptLocation + "/" + newScript);
     } catch (e) {
       Log.println("switchScript","switched to tag load");
       var oScript = document.createElement("<sc" + "ript language='Javascript' id = 'activeScript' src='" + scriptLocation + "/" + newScript + "'/>");
       Log.println("switchScript","tag load: " + scriptLocation + "/" + newScript);
     }
     document.body.appendChild(oScript);
     Log.println("switchScript","script appended");     
     activeScript = newScript;           //JH 2010-05-25
   } else {
	 Log.println("switchScript","script is already active"); 
   }
}

var intervalCheckInt = 0;  //jh 2014-10-8 - to save reports
function setIntervalCheck()
{
	if (intervalCheckInt == 0)
	{
		intervalCheckInt = setTimeout(saveIntervalCheck, 900000);
	}
}
function setIntervalCheck_leave()
{
	if (intervalCheckInt == 0)
	{
		intervalCheckInt = setTimeout(saveIntervalCheck_leave, 900000);
	}
}
function saveIntervalCheck()
{
	intervalCheckInt = 0;
	saveWork();
}      //end of 2014-10-8 
function saveIntervalCheck_leave()
{
	intervalCheckInt = 0;
	saveWork_leave();
}      //end of 2014-10-8 

function ShowAttendance(){
	document.getElementById("ShowAttendance").style.display = "block";
}
function HideAttendance(){
	document.getElementById("ShowAttendance").style.display = "none";
}
var DontRunSaveWork = false;
function saveWork()  //add check to see if the work is worth saving
{
   if (!DontRunSaveWork) {
      var url;
      if (activeScript.indexOf("screen.js") > -1) functionPostScreen();
      document.forms.Serverdata.email.value = "<%= PersFile.getEmailAddress() %>";
      document.forms.Serverdata.ccode.value = "<%= PersFile.getChallengeCode()%>";
      var reference = parent.getNameValue(parent.Header, "reference");
      document.forms.Serverdata.reference.value = reference;
      // if (status == "New") parent.setNameValue(parent.Header,"xref",reference);  //Need to QA this change a bit JH 20101112
      parent.setNameValue(parent.Header,"xref",reference);
      if (!parent.ReportIsSaved) {         //Do we need isNew() check ??
   		  url = appServer + "/" + appFolder + "/ajax/SaveWork.jsp";
   		  document.forms.Serverdata.report.value = "<work><reference>" + reference + "</reference>" + CreateXML() + "</work>"; 
   		  postSimpleForm(url, document.forms.Serverdata, false, saveWorkMsg);
  	  } else {
   		  url = appServer + "/" + appFolder + "/ajax/RemoveWork.jsp";         //need to block when Logout is used
   		  postSimpleForm(url, document.forms.Serverdata, false, saveWorkMsg);
   	  }
   }
}
function saveWork_leave()  //add check to see if the work is worth saving
{
   if (!DontRunSaveWork) {
      var url;
      if (activeScript.indexOf("screen_leave.js") > -1) functionPostScreen();
      document.forms.Serverdata.email.value = "<%= PersFile.getEmailAddress() %>";
      document.forms.Serverdata.ccode.value = "<%= PersFile.getChallengeCode()%>";
      var reference = parent.getNameValue(parent.Header, "reference");
      document.forms.Serverdata.reference.value = reference;
      // if (status == "New") parent.setNameValue(parent.Header,"xref",reference);  //Need to QA this change a bit JH 20101112
      parent.setNameValue(parent.Header,"xref",reference);
      if (!parent.ReportIsSaved) {         //Do we need isNew() check ??
   		  url = appServer + "/" + appFolder + "/ajax/SaveWork_leave.jsp";
   		  document.forms.Serverdata.report.value = "<work><reference>" + reference + "</reference>" + CreateXML() + "</work>"; 
   		  postSimpleForm(url, document.forms.Serverdata, false, saveWorkMsg);
  	  } else {
   		  url = appServer + "/" + appFolder + "/ajax/RemoveWork_leave.jsp";         //need to block when Logout is used
   		  postSimpleForm(url, document.forms.Serverdata, false, saveWorkMsg);
   	  }
   }
}
function saveWorkMsg() {             //This is really just a plug.
  var x = httpXMLObj.readyState;
  if ( x == 4 )
  { 
     var msg = httpXMLObj.responseText;
  }
}

function runLoadWork() {
	HideAttendance();
    setTimeout("loadWork()", 100);
    document.getElementById("logout").innerHTML = "<img src='" + webServer + "/" + webFolder + "/images/butLogoutNR.png' />";// + getJSX("JS_LOGOUT");
}


function loadWork()
{
  //Log.println("loadWork","CCode = " + parent.CCode);
  //var url = appServer + "/" + appFolder + "/ajax/getWork.jsp?email=" + "<%= PersFile.getEmailAddress() %>";
  var url = webServer + "/" + webFolder + "/en/loading.html";
  loadScreenAJAX(url);
  setTimeout("showHistory()", 100);
}  
function showHistory()
{
  PersWindow(defaultApps + "ajax/HistoryList.jsp");
}   
function checkForAddresses()
{
   if (typeof checkAddress == 'function') var timehandle = setTimeout("checkAddress()", 3000);
}

</script>
     <script>
      function Change(num,t){
		  var obj = document.getElementById(num);
		  var obj2 = document.getElementById(num + "AMPM");
		  var obj3 = document.getElementById(num + "Role");
			document.forms[formStartNumber].reference.value = "";
        if(obj.options[obj.selectedIndex].value != t)
		{
			document.getElementById(num).style.backgroundColor = "red";
			document.getElementById(num + "select_this_item").checked = true;
			document.getElementById(num + "select_this_item").value = num + "," + obj.options[obj.selectedIndex].value + "," + obj2.options[obj2.selectedIndex].value + "," + obj3.options[obj3.selectedIndex].value;
		}
		else
		{
			document.getElementById(num).style.backgroundColor = "initial";
			document.getElementById(num + "select_this_item").checked = false;
			document.getElementById(num + "select_this_item").value = "";
		}
      }
		function ChangeHalfday(num,t){
		  var obj = document.getElementById(num);
		  var obj2 = document.getElementById(num + "AMPM");
		  var obj3 = document.getElementById(num + "Role");
			document.forms[formStartNumber].reference.value = "";
			if(obj2.options[obj2.selectedIndex].value != "")
			{
				document.getElementById(num + "AMPM").style.backgroundColor = "red";
				document.getElementById(num + "select_this_item").checked = true;
				document.getElementById(num + "select_this_item").value = num + "," + obj.options[obj.selectedIndex].value + "," + obj2.options[obj2.selectedIndex].value + "," + obj3.options[obj3.selectedIndex].value;
			}
			else
			{
				document.getElementById(num + "AMPM").style.backgroundColor = "initial";
				document.getElementById(num + "select_this_item").checked = false;
				document.getElementById(num + "select_this_item").value = "";
			}
		}
		
		function ChangeRole(num,t){
		  var obj = document.getElementById(num);
		  var obj2 = document.getElementById(num + "AMPM");
		  var obj3 = document.getElementById(num + "Role");
			document.forms[formStartNumber].reference.value = "";
			if(obj3.options[obj3.selectedIndex].value != t)
			{
				document.getElementById(num + "Role").style.backgroundColor = "red";
				document.getElementById(num + "select_this_item").checked = true;
				document.getElementById(num + "select_this_item").value = num + "," + obj.options[obj.selectedIndex].value + "," + obj2.options[obj2.selectedIndex].value + "," + obj3.options[obj3.selectedIndex].value;
			}
			else
			{
				document.getElementById(num + "Role").style.backgroundColor = "initial";
				document.getElementById(num + "select_this_item").checked = false;
				document.getElementById(num + "select_this_item").value = "";
			}
		}

		function SetNewValues(){
			var delim = "";
			document.forms[formStartNumber].reference.value = "";
			for (var i = 0; i < document.forms[formStartNumber].length; i++) {
				 if (document.forms[formStartNumber].elements[i].id.indexOf("select_this_item") && document.forms[formStartNumber].elements[i].checked == true) {
				   document.forms[formStartNumber].reference.value += document.forms[formStartNumber].elements[i].value;
				   delim = ";";
				   document.forms[formStartNumber].reference.value += delim;
				 }
			}
			if (delim == ";") {
				document.forms.Serverdata.reference.value = document.forms[formStartNumber].reference.value;
				document.forms.Serverdata.newLeaveFrom.value = document.forms[formStartNumber].dateSelected.value;
				//alert(document.forms.Serverdata.reference.value);
				loadHTMLScreenAJAX('AttendanceVOConfirm.html');
			} else {
			  alert("There is no change!");
				document.forms.Serverdata.reference.value = document.forms[formStartNumber].reference.value;
				document.forms.Serverdata.newLeaveFrom.value = document.forms[formStartNumber].dateSelected.value;
				//alert(document.forms.Serverdata.reference.value);
				loadHTMLScreenAJAX('AttendanceVOConfirm.html');
			}
		}
      </script>

<script LANGUAGE="JavaScript" type="text/javascript" SRC="/ess/shared/validation.js"></script>
<script LANGUAGE="JavaScript" type="text/javascript" SRC="/ess/shared/calendar.js"></script>
<script LANGUAGE="JavaScript" type="text/javascript" SRC="/ess/shared/attendee.js"></script>
<script LANGUAGE="JavaScript" type="text/javascript" SRC="/ess/shared/addmerchant.js"></script>
<script LANGUAGE="JavaScript" type="text/javascript" SRC="/ess/shared/fx1.js"></script>
<script LANGUAGE="JavaScript" type="text/javascript" SRC="/ess/shared/check.js"></script>

<%@ include file="CheckAddress.jsp" %>

</body>

</html>

