function guideSubmit() {

  if (parent.HeadList.length > 0) {

    var DateObj = new Date();
    parent.setDBPair(parent.PersDBase,"last_save",DateObj.toString());
    var status = parent.getNameValue(parent.Header,"status");
    if (status == "" || status == "Not Saved") status = "New";
    document.forms[formStartNumber].status.value = status;
    var reference = parent.getNameValue(parent.Header, "reference");
    document.forms[formStartNumber].reference.value = reference;
    document.forms[formStartNumber].ccode.value = parent.CCode;
    document.forms[formStartNumber].email.value = parent.getNameValue(parent.Header, "email");
    document.forms[formStartNumber].database.value = parent.database;
    document.forms[formStartNumber].report.value = parent.CreateXML();
    document.forms[formStartNumber].displayText.value = parent.getJSX("submit_screen_msg");
    document.forms[formStartNumber].submitMethod.value = "submitFromGuideChk.html";
    parent.SetLocal()
    
    postSimpleForm(parent.defaultApps + 'ajax/SubmitwithGuide.jsp', document.forms[formStartNumber]);

  } else {

    alert("Vous ne pouvez continuer avec cette option !\n\nLe rapport actuel ne contient pas de description.\nSi vous avez entré des données dans le formulaire,/nveuillez appuyer sur le bouton bleu.\nSinon, les données seront perdues..");

  }

}

function XSubmit() {
   var x = setTimeout("guideSubmit()",2000);
}
function screenLoad() {
  XSubmit();
  return true;
}

function screenUnload() {
  return true;
}


