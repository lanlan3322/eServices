<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />           

var submitSafetyFlag = true;

function screenLoad() {
   if (submitSafetyFlag) {
    submitSafetyFlag = false;
	setTimeout("redirect()",2000);
   }
  return true;
}

function redirect() {
  loadHTMLScreenAJAX("screen_leave.html");
  return true;
}

function screenUnload() {
  return true;
}



   
