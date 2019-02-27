function SubmitLevel() {
  with(document.forms[formStartNumber]) {
    if (downlevel.value >= "1" && downlevel.value <= "9" && downlevel.value.length == 1) {
      parent.setDBPair(parent.PersDBase,"approvallevel",downlevel.value);
      email.value = parent.getNameValue(parent.Header, "email");
      database.value = parent.database;
      persdbase.value = parent.CreatePersDBXML(parent.PersDBase);
      ccode.value = parent.CCode;
      postSimpleForm(parent.defaultApps + 'ajax/ApproveList.jsp', document.forms[formStartNumber]); 
    } else {
      alert("'Approval levels to show' must be between 1 and 9 inclusive");
    }
  }
}
 
function screenLoad() {
  return true;
}

function screenUnload() {
  return true;
}
