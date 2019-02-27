
function checkAJAX (executionLine) {
   //defaults to the PreporButton.jsp but can be used generally.

   var that = this;  //question about the perspective of this variable???
   this.application2run = "/ess-app/ajax/PrepopButton.jsp";  //tested with /ess-app/Check.jsp 
   this.check2run = "prepoplink";  //from system.xml checksql
   this.param1 = null;  //passed as the "reporter"
   this.param2 = null;  //passed as the optional button to return
   this.aSync = true;  
   this.id2Update = "prepopButton";

   this.xmlHttp=null;
   try
   {
      // Firefox, Opera 8.0+, Safari
      this.xmlHttp=new XMLHttpRequest();
   }
   catch (e)
   {
      // Internet Explorer
      try
      {
          this.xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
      }
      catch (e)
      {
          try
          {
             this.xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
          } 
          catch (e)
          {
             alert("ERROR_WRONG_BROWSER");
          }      
      }
    }

   if (executionLine != null)
   {
          this.getCheck(executionLine);
   }
   
   this.updateElement = function() {  //see this and that variable above

      if (that.xmlHttp.readyState == 4)
      { 
         var newHTML = that.xmlHttp.responseText;
         document.getElementById(that.id2Update).innerHTML = newHTML;
      }
   }

   this.getCheck = function(routine2run)
   {
      if (this.xmlHttp==null)
      {
         alert ("ERROR_AJAX_UNSUPPORTED");
         return;
      } 
      this.xmlHttp.onreadystatechange=this.updateElement;
      this.xmlHttp.open("GET",routine2run,this.aSync);
      this.xmlHttp.send(null);
   } 
   
   this.set = function()
   {
      if (executionLine != null) 
      {
         this.getCheck(executionLine);
      } else {
         
      }
   }
   
   this.setStandard = function(p1)
   {
      if (p1 == null) p1 = this.param1;
      if (this.param2 == null)
      {
      		this.getCheck(this.application2run + "?check=" + this.check2run + "&param1=" + p1);
      } else {
      		this.getCheck(this.application2run + "?check=" + this.check2run + "&param1=" + p1 + "&param2=" + this.param2);
      }
   }
   
   this.postSimpleForm = function(url, obj, async, readyStateChange) {
      var parameters = "";
      pSeparator = "";   //See XReport.jsp - consider moving here
      if (async == null) async = true;
      if (readyStateChange == null) readyStateChange = this.updateElement;
      
      parameters = getPostParameters(obj, parameters).replace(new RegExp("%20", "g"), "+");;  //See Xreport - consider moving here
            // this.xmlHttp = GetXmlHttpObject();
      if (this.xmlHttp.overrideMimeType) {                     //??? JH 2010-05-11 Doesn't function in Mozilla
            // http_request.overrideMimeType('text/html');
      }      
      
      Log.println("check.postSimpleForm",url);
      Log.println("check.parameters",parameters);

      this.xmlHttp.onreadystatechange = readyStateChange;    //JH 2010-10-13
      this.xmlHttp.open('POST', url, async);
      this.xmlHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");  //jh 2014-9-22 
      this.xmlHttp.setRequestHeader("Content-length", parameters.length);
      this.xmlHttp.setRequestHeader("Connection", "close");
      this.xmlHttp.send(parameters);
   }

}