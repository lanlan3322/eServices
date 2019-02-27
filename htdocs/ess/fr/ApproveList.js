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
      alert("'Niveau d'approbation' doit être entre 1 et 9 inclusivement");
    }
  }
}
 
function screenLoad() {
  return true;
}

function screenUnload() {
  return true;
}
