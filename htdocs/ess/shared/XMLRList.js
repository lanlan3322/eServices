//      function initForm() {
//        if (parent.getDBValue) {
//          document.forms[formStartNumber + 1].name.value = parent.getDBValue(parent.Header,"name");
          //reference was here
//          document.forms[formStartNumber + 1].reference.value = "";
//          document.forms[formStartNumber + 1].email.value = parent.getDBValue(parent.Header,"email");
//          document.forms[formStartNumber + 1].company.value = parent.company;
//          document.forms[formStartNumber + 1].database.value = parent.database;
//          document.forms[formStartNumber + 1].ccode.value = parent.CCode;
//          document.forms[formStartNumber + 1].status.value = "";
//          document.forms[formStartNumber + 1].action.value = "remove";
//        } else {
//          setTimeout("parent.initForm()",1000);
//        }    
//      }

      function Remove(){
        document.forms[formStartNumber + 1].name.value = parent.getDBValue(parent.Header,"name");
        //reference was here
        document.forms[formStartNumber + 1].reference.value = "";
        document.forms[formStartNumber + 1].email.value = parent.getDBValue(parent.Header,"email");
        document.forms[formStartNumber + 1].company.value = parent.company;
        document.forms[formStartNumber + 1].database.value = parent.database;
        document.forms[formStartNumber + 1].ccode.value = parent.CCode;
        document.forms[formStartNumber + 1].status.value = "";
        document.forms[formStartNumber + 1].action.value = "remove";
      
        var delim = "";
        for (var i = 0; i < document.forms[formStartNumber].length; i++) {
          if (document.forms[formStartNumber].elements[i].name == "select_this_report" && document.forms[formStartNumber].elements[i].checked == true) {
            document.forms[formStartNumber + 1].reference.value += delim + getReferenceValue(document.forms[formStartNumber].elements[i]); //jh 2010-01-05 from voucher
            document.forms[formStartNumber + 1].status.value += delim + document.forms[formStartNumber].elements[i].value;
            delim = ";";   
          }
        }
        if (delim == ";") {
          if (confirm(getJSX("JS_CHECKED1"))) {
            postSimpleForm(parent.defaultApps + 'ajax/RemoveSave.jsp', document.forms[formStartNumber + 1]);
          }
        } else {
          alert(getJSX("JS_CHECKED2"));
        }
      }
      function getReferenceValue(eleObj) {  //JH 9-12-2013
         var retVal = "";
         if (navigator.userAgent.indexOf("Mozilla") > -1) {
            if (eleObj.attributes.getNamedItem("reference")) retVal = eleObj.attributes.getNamedItem("reference").value;
         } else if (navigator.appVersion.indexOf("MSIE") > -1) {
            if (eleObj.reference) retVal = eleObj.reference; 
         }
         return retVal;
      } 
      
      function screenUnload() {
         return true;     
      }
      
      function screenLoad() {
         return true;     
      }
 
