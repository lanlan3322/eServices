<jsp:useBean id="Address"
     class="ess.Address"
     scope="page" />
<%
Address.setConnection(PersFile.getConnection());
Address.setSQLTerminator(PersFile.getSQLTerminator());
if (Address.setAddresses2Confirm(PersFile.getPersNum()))  //Add an option to turn this off entirely
{ 
String address2Confirm = Address.getAddressFromTable();%>
<script language="javascript">
	
function checkAddress()
{

		
		if (confirm("Do you want to use <%= address2Confirm %> to send in receipt scans?\nIf a cell phone address, this address may contain information\nthat has been added by your carrier. This is normal."))
		{
		    acceptAddressAJAX("<%= address2Confirm %>");
		} else {
			rejectAddressAJAX("<%= address2Confirm %>");
		}

}

var acceptXMLObj
function acceptAddressAJAX(confirmAddress) {
// might want to do str addition in a separate window
  addressAJAX(acceptXMLObj,appServer + "/" + appFolder + "/ajax/AcceptAddress.jsp?address=" + confirmAddress);
}
function rejectAddressAJAX(confirmAddress) {
// might want to do str addition in a separate window
  addressAJAX(acceptXMLObj,appServer + "/" + appFolder + "/ajax/RejectAddress.jsp?address=" + confirmAddress);
}

function addressAJAX(xmlObj,appName) {
      acceptXMLObj = GetXmlHttpObject();  
      getInfo(acceptXMLObj, appName, addressShowResult, true);
      Log.println("addressAJAX",appName);
}

function addressShowResult() {
  var x = acceptXMLObj.readyState;
   
  if ( x == 4 )
  { 
      var acceptResults = acceptXMLObj.responseText;
      acceptResults = acceptResults.replace(/\n/g,"");
      acceptResults = acceptResults.replace(/\r/g,"")
      alert(alltrim(acceptResults));
  }
}
</script>
<%  } %>
