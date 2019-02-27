<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />           


function DataDownload() {
//Do this no matter what

parent.setNameValue(parent.Header, "reference","<%= request.getParameter("lastReference") %>");
parent.setNameValue(parent.Header, "status","<%= request.getParameter("status") %>");
sendPersDbase();

<%
boolean errorCondition;
String errorCond = request.getParameter("errorcond");

if (errorCond.equalsIgnoreCase("True"))
{
   errorCondition = true;
} else 
{
   errorCondition = false;
}   
   errorCondition = false;

if (!request.getParameter("endproc").equals(null) && !errorCondition) {
%>
<%= request.getParameter("endproc") %>; 
<% } %>
}

function blankOutReport() {
<%
   if (!errorCondition) {
%>
       if (AJAXProcessDone) {
          parent.NewReport();
          parent.ProcessHeader(parent.Header); 
          parent.myESSMenu.setReport();
          alert("<%= Lang.getString("REPORT_SAVED_ALERT") %>");
		  parent.PersWindow(parent.defaultApps + "ajax/HistoryList.jsp");
       } else {
          var x = setTimeout("blankOutReport()",1000);
       }   
<%  }
%>
}

   var http_request = false;
   var AJAXProcessDone = false;
   
   function makePOSTRequest(url, parameters) {
      http_request = false;
      if (window.XMLHttpRequest) { // Mozilla, Safari,...
         http_request = new XMLHttpRequest();
         if (http_request.overrideMimeType) {
         	// set type accordingly to anticipated content type
            //http_request.overrideMimeType('text/xml');
            http_request.overrideMimeType('text/html');
         }
      } else if (window.ActiveXObject) { // IE
         try {
            http_request = new ActiveXObject("Msxml2.XMLHTTP");
         } catch (e) {
            try {
               http_request = new ActiveXObject("Microsoft.XMLHTTP");
            } catch (e) {}
         }
      }
      if (!http_request) {
         alert("<%= Lang.getString("ERROR_AJAX_INSTANCE_ERROR") %>");
         AJAProcessDnne = true;
         return false;
      }
      
      http_request.onreadystatechange = checkMessage;
      http_request.open('POST', url, true);
      http_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      http_request.setRequestHeader("Content-length", parameters.length);
      http_request.setRequestHeader("Connection", "close");
      http_request.send(parameters);
   }

   function checkMessage() {
      if (http_request.readyState == 4) {
         if (http_request.status == 200) {
            result = http_request.responseText;
            document.getElementById('personalData').innerHTML = result;            
         } else {
            alert('<%= Lang.getString("ERROR_AJAX_PERSONAL_DATABASE") %>');
         }
         AJAXProcessDone = true;
      }
   }
   
   function sendPersDbase() {
      var poststr = "email=" + encodeURIComponent( parent.getNameValue(parent.Header, "email") ) +
                    "&persdbase=" + encodeURIComponent( parent.CreatePersDBXML(parent.PersDBase) );
      makePOSTRequest(parent.defaultApps + "ajax/SavePersXMLAJAX.jsp", poststr);
   }
<%
if (request.getParameter("saved").equalsIgnoreCase("Yes"))
{ 
%> 
parent.ReportIsSaved = true;
parent.SetReportIsSaved = true;
<%
}
%>

      function screenUnload() {
         return true;     
      }
      
      function screenLoad() {
         DataDownload();
         return true;     
      }


//

