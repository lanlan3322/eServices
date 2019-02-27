var dupFlagOK = true;
var updateWithPrepopItems = new checkAJAX();   //see check.js
function SubmitRec() {
 if (dupFlagOK) {
    dupFlagOK = false;
    // document.forms[formStartNumber].xref.value = document.forms[0].xref.value;
    if (parent.HeadList.length > 0) document.forms[formStartNumber].purpose.value = parent.getStringFmHead(parent.HeadList.length - 1);

//    var trxElements = document.getElementsByName("Trx");
//    for (var i; i < trxElements.length; i++)
//    {
//    	if (trxElements[i].checked == false)
//    	{
//    		trxElements[i].value = "";
//   		}
//    }

	for (var i=0; i<document.forms[formStartNumber].Trx.length; i++){
		if (document.forms[formStartNumber].Trx[i].checked == false) 
		{
			document.forms[formStartNumber].Trx[i].value = "";
		}
 	}
 	
    updateWithPrepopItems.postSimpleForm(parent.defaultApps + 'ajax/prepopulated/FeedPost.jsp',document.forms[formStartNumber], true,doTheDeal);    // document.forms[1].submit();
 }
}
 
function doTheDeal() {
  if (updateWithPrepopItems.xmlHttp.readyState == 4) {
     var reponseText = updateWithPrepopItems.xmlHttp.responseText;
     var ReceiptString = eval(alltrim(reponseText));
     parent.ProcessRepList('2',ReceiptString);
     dupFlagOK = true;
     parent.ListDelay();
  }
}



function screenUnload() {
  return true;
}

function screenLoad() {
   return true;
}
