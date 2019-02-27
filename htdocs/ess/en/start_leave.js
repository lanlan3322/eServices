function guideSubmit() {

    document.forms["form-start-leave"].ccode.value = parent.CCode;
    document.forms["form-start-leave"].email.value = parent.getNameValue(parent.Header, "email");
    document.forms["form-start-leave"].database.value = parent.database;
    parent.SetLocal()
    postSimpleForm(parent.defaultApps + 'ajax/start_leave.jsp', document.forms["form-start-leave"]);
}

function XSubmit() {
   var x = setTimeout("guideSubmit()",200);
}
function screenLoad() {
  XSubmit();
  return true;
}

function screenUnload() {
  return true;
}