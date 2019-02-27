function StartUp() {
  document.forms[formStartNumber].action = parent.defaultApps + "SubmitForm.jsp";
  var today = new Date();
  document.forms[formStartNumber].FormDate.value = today.toString();
  document.forms[formStartNumber].appName.value = navigator.appName;
  document.forms[formStartNumber].appVersion.value = navigator.appVersion;
  document.forms[formStartNumber].userAgent.value = navigator.userAgent;
  document.forms[formStartNumber].platform.value = navigator.platform;
  if (document.forms[formStartNumber].cookieEnabled) {
    document.forms[formStartNumber].cookieEnabled.value = "true";
  } else {
    document.forms[formStartNumber].cookieEnabled.value = "false";
  }
  document.forms[formStartNumber].rcpt2.value = "@@emailname@@";
}

function screenLoad() {
  StartUp();
  return true;
}

function screenUnload() {
  return true;
}
