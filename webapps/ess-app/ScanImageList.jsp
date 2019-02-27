<%
String Look4Scans = SystemDOM.getDOMTableValueFor("receiptmanagement","scan_receipts","yes");
String PopupScans = SystemDOM.getDOMTableValueFor("receiptmanagement","receipt_popup_list","yes");
String BottomScans = SystemDOM.getDOMTableValueFor("receiptmanagement","receipt_at_report_bottom","no");
String GladminScans = SystemDOM.getDOMTableValueFor("receiptmanagement","receipt_for_gladmin","yes");

if (Look4Scans.equalsIgnoreCase("yes"))
{
	ESS.setScanLinks();   //reset the scans in case a receipt was added or deleted.
	ESS.setReceiptScanLinks();
	PersFile.setImagesViewed();  //security - reset the list of images that can be viewed to zero
	String[] receiptScans = ESS.getReceiptScanLinks();
	String[] receiptComments = ESS.getReceiptScanComments();
	String[] receiptReceipts = ESS.getReceiptScanReceipts();
	
	if (receiptScans.length > 0  && (PopupScans.equalsIgnoreCase("yes") && !(GladminScans.equalsIgnoreCase("yes") && PersFile.isGLAdmin())))
	{
	// String ScanFolder = SystemDOM.getDOMTableValueFor("receiptmanagement","htmlfolder","/receipts");
	String HrefLink = SystemDOM.getDOMTableValueFor("receiptmanagement","hreflink","$link$");
	String HrefString;
	String FreeIcon = SystemDOM.getDOMTableValueFor("receiptmanagement","freeicon","<img SRC='/ess/images/ess-Free.gif' title='' />");
    String FreeImage;
	%>Receipts attached:&nbsp;&nbsp;<%
		for (int i = 0; i < receiptScans.length; i++)
    	{
			if (receiptReceipts[i].equals("")) {
				FreeImage = FreeIcon;
			} else {
				FreeImage = "";
			}
			
			HrefString =  "<a href=\"" + PersFile.SQLReplace(HrefLink, "$link$", "/ess-app/receipts/ReceiptView.jsp?image=" + receiptScans[i]) + "\">";
			HrefString =  PersFile.SQLReplace(HrefString, "$window$", "Receipt_" + receiptScans[i]);
			if (receiptComments[i] == null)
			{
				HrefString =  HrefString + receiptScans[i] + FreeImage + "</a>&nbsp;&nbsp;";
    	    } else 
    	    {
    	    	HrefString =  HrefString + receiptScans[i]  + "&nbsp;" + receiptComments[i]  + FreeImage + "</a>&nbsp;&nbsp;";
    	    }
			PersFile.addImage(receiptScans[i]);
		    %><%= HrefString %> 
		    <%
    	}
	}
}
%>
