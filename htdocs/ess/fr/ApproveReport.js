
function initForm() {
  document.forms[formStartNumber].name.value = parent.getDBValue(parent.Header,"name");
  document.forms[formStartNumber].reference.value = "<%= reference %>";
  document.forms[formStartNumber].voucher.value = "<%= voucher %>";
  document.forms[formStartNumber].email.value = parentgetDBValue(parent.Header,"email");
  document.forms[formStartNumber].company.value = parent.company;
  document.forms[formStartNumber].ccode.value = parent.CCode;
  document.forms[formStartNumber].database.value = parent.database;
  document.forms[formStartNumber].status.value = "<%= status %>";
  document.forms[formStartNumber].action.value = "result";
  document.forms[formStartNumber].actiontype[0].checked = true;
  document.forms[formStartNumber].rcpt2.value = "<%= rcpt2 %>";
  document.forms[formStartNumber].reply2.value = "<%= reply2 %>";

//figure something out for reject
}
var submitSafetyFlag = true;
function Approve(){
  if (submitSafetyFlag) {
    var xfound = false;
    with (document.forms[formStartNumber]) {
      for (var i = 0; i < actiontype.length; i++) {
        if (actiontype[i].checked == true) {
          action.value = actiontype[i].value;
          xfound = true;
        }
      }

      if (!xfound) {
        alert("l'action n'a pas été vérifié !");
      } else if (action.value == "reject") {
        if (msgdata.value.length < 1) {
           alert("Veuillez saisir un message avant de refuser le rapport.");
           msgdata.focus();
        } else {
           if (confirm("Confirmez vous le refus de ce rapport?")) {
             postSimpleForm(parent.defaultApps + 'ajax/ApproveSave.jsp',document.forms[formStartNumber]);
             submitSafetyFlag = false;
           }
        }
      } else if (action.value == "result") {
           postSimpleForm(parent.defaultApps + 'ajax/ApproveSave.jsp',document.forms[formStartNumber]);
           submitSafetyFlag = false;
      } else {
        alert("Action non valide, veuillez contacter le support !");
      }
    }
    return;
  }
}

initForm();
