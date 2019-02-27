<%
// The ScanImageList.jsp option must be executed prior to run this code.
if (Look4Scans.equalsIgnoreCase("yes") && (BottomScans.equalsIgnoreCase("yes") || (GladminScans.equalsIgnoreCase("yes") && PersFile.isGLAdmin() )))
{
	//ESS.setScanLinks();   //reset the scans in case a receipt was added or deleted.
	//ESS.setReceiptScanLinks();
	//PersFile.setImagesViewed();  //security - reset the list of images that can be billed to zero
	String[] imageScans = ESS.getReceiptScanLinks();
    String scanInfoTemplate = SysTable.getSystemString("receiptmanagement","scaninfo","SELECT * FROM SCAN WHERE SCAN_REF = '$reference$'" + PersFile.getSQLTerminator());
    String scanInfoSQL;
    String filetype;
    double imageWidth;
    String imageWidthStr;
    double imageHeight;
    
    double resizeBeyondWidth = java.lang.Double.valueOf(SystemDOM.getDOMTableValueFor("receiptmanagement","resizebeyondwidth","550"));
    Log.println("[000] ScanImageDisplay.jsp resizeBeyondWidth: " + java.lang.Double.toString(resizeBeyondWidth));
    double resizeBeyondHeight = java.lang.Double.valueOf(SystemDOM.getDOMTableValueFor("receiptmanagement","resizebeyondheight","700"));
    Log.println("[000] ScanImageDisplay.jsp resizeBeyondHeight: " + java.lang.Double.toString(resizeBeyondHeight));
    double maxWidth = resizeBeyondWidth;
    double maxHeight = resizeBeyondHeight;
 
    double PDFimageWidth;
    double PDFimageHeight;
   
    double PDFresizeBeyondWidth = java.lang.Double.valueOf(SystemDOM.getDOMTableValueFor("receiptmanagement","pdfresizebeyondwidth","600"));
    Log.println("[000] ScanImageDisplay.jsp PDF resizeBeyondWidth: " + java.lang.Double.toString(resizeBeyondWidth));
    double PDFresizeBeyondHeight = java.lang.Double.valueOf(SystemDOM.getDOMTableValueFor("receiptmanagement","pdfresizebeyondheight","800"));
    Log.println("[000] ScanImageDisplay.jsp PDF resizeBeyondHeight: " + java.lang.Double.toString(PDFresizeBeyondHeight));
    double PDFmaxWidth = PDFresizeBeyondWidth;
    double PDFmaxHeight = PDFresizeBeyondHeight;
    
    String applicationTypes = SystemDOM.getDOMTableValueFor("receiptmanagement","applicationtypes",";pdf;doc;xdoc;xls;");
    String ignoreApplicationTypes = SystemDOM.getDOMTableValueFor("receiptmanagement","ignoreatbottomapplicationtypes",";pdf;");
    String parentFolder = SystemDOM.getDOMTableValueFor("receiptmanagement","parentfolder","/var/ess/receipts/");
    
    int numberOfPDFPages;
    int pdfDocumentNumber = -1;
    Scan.resetPDFsList();
    
	if (imageScans.length > 0)
	{
		for (int i = 0; i < imageScans.length; i++)
    	{
			scanInfoSQL = PersFile.SQLReplace(scanInfoTemplate, "$reference$", imageScans[i]); 
			if (PersFile.setResultSet(scanInfoSQL))
			{
				filetype = PersFile.myResult.getString("FILE_TYPE");
				// 
				if  (filetype.equalsIgnoreCase("pdf")) {
					java.sql.Blob file_blob = PersFile.myResult.getBlob("FILE_CONTENT");
					byte[] decompressedBytes = null;
       				if (file_blob == null || file_blob.length() == 0) {
       					decompressedBytes = ess.InputTextFile.readWholeFile(parentFolder + ESS.getPersNum() + "/" + imageScans[i] + "." + filetype);
       				} else {
       					decompressedBytes = Scan.decompress(file_blob.getBytes((long) 1, (int) file_blob.length()));
       				}
					if(Scan.loadPDFDocumentObject(decompressedBytes))
					{	
						
						pdfDocumentNumber++;
						numberOfPDFPages = Scan.getNumberOfPages(pdfDocumentNumber);
						for (int j = 0; j < numberOfPDFPages; j++) {
							org.apache.pdfbox.pdmodel.PDPage mypage = Scan.getPage(pdfDocumentNumber,j);
							// org.apache.pdfbox.pdmodel.common.PDRectangle mediaBox = mypage.getMediaBox();
							org.apache.pdfbox.pdmodel.common.PDRectangle mediaBox = mypage.findMediaBox();
							PDFimageWidth = java.lang.Math.round(mediaBox.getWidth());
							Log.println( "[000] ScanImageDisplay.jsp PDF page width:" + PDFimageWidth );
							PDFimageHeight = java.lang.Math.round(mediaBox.getHeight());
							Log.println( "[000] ScanImageDisplay.jsp PDF page length:" + PDFimageHeight );


							if (PDFimageWidth > PDFresizeBeyondWidth) {
								Log.println("[000] ScanImageDisplay.jsp PDF width resized multiplier: " + java.lang.Double.toString(PDFmaxWidth / PDFimageWidth));
								PDFimageHeight = (PDFmaxWidth / PDFimageWidth) * PDFimageHeight;
								Log.println("[000] ScanImageDisplay.jsp resized PDFimageHeight: " + java.lang.Double.toString(PDFimageHeight));
								PDFimageWidth = PDFmaxWidth;
							}

							if (PDFimageHeight > PDFresizeBeyondHeight) {
								Log.println("[000] ScanImageDisplay.jsp PDF height resized multiplier: " + java.lang.Double.toString(PDFmaxHeight / PDFimageHeight));
								PDFimageWidth = (PDFmaxHeight / PDFimageHeight) * PDFimageWidth;  //JH 2014-9-11
								Log.println("[000] ScanImageDisplay.jsp resized PDFimageWidth: " + java.lang.Double.toString(PDFimageWidth));
								PDFimageHeight = PDFmaxHeight;
							}

						%><div class="PDF-break"><img width="<%= java.lang.Double.toString(PDFimageWidth) %>" height="<%= java.lang.Double.toString(PDFimageHeight) %>"src="/ess-app/receipts/ReceiptPDF2Image.jsp?image=<%= imageScans[i] %>&pdf=<%= pdfDocumentNumber %>&page=<%= j %>"/></div> 
						<%
						}
					} else {
						%> [**PDF** <%= imageScans[i] %> ****]<br/><br/><br/> 
						<%
					}
				} else {
					imageWidthStr = PersFile.myResult.getString("IMAGE_WIDTH");
					if (imageWidthStr != null) {
						imageWidth = java.lang.Double.valueOf(imageWidthStr);
						Log.println("[000] ScanImageDisplay.jsp imageWidth: " + java.lang.Double.toString(imageWidth));
						imageHeight = java.lang.Double.valueOf(PersFile.myResult.getString("IMAGE_HEIGHT"));
						Log.println("[000] ScanImageDisplay.jsp imageHeight: " + java.lang.Double.toString(imageHeight));
					} else {
						imageWidth = 0;
						imageHeight = 0;
						Log.println("[000] ScanImageDisplay.jsp null imageWidth detected");
					}
					if (imageWidth > resizeBeyondWidth) {
						Log.println("[000] ScanImageDisplay.jsp width resized multiplier: " + java.lang.Double.toString(maxWidth / imageWidth));
						imageHeight = (maxWidth / imageWidth) * imageHeight;
						Log.println("[000] ScanImageDisplay.jsp resized imageHeight: " + java.lang.Double.toString(imageHeight));
						imageWidth = maxWidth;
					}

					if (imageHeight > resizeBeyondHeight) {
						Log.println("[000] ScanImageDisplay.jsp height resized multiplier: " + java.lang.Double.toString(maxHeight / imageHeight));
						imageWidth = (maxHeight / imageHeight) * imageWidth;    //JH 2014-9-11
						Log.println("[000] ScanImageDisplay.jsp resized imageWidth: " + java.lang.Double.toString(imageWidth));
						imageHeight = maxHeight;
					}

            		if ((applicationTypes.indexOf(filetype) == -1) || (ignoreApplicationTypes.indexOf(filetype) > -1))
            		{ 
            			if (imageWidth == 0 || imageHeight == 0) {
							%><p> <img src="/ess-app/receipts/ReceiptViewImage.jsp?image=<%= imageScans[i] %>"/> 
							<% 
            			}else {
        					%><p> <img width="<%= java.lang.Double.toString(imageWidth) %>" height="<%= java.lang.Double.toString(imageHeight) %>" src="/ess-app/receipts/ReceiptViewImage.jsp?image=<%= imageScans[i] %>"/> 
        					<% 
            			}
            			%><br/>Scan: <%= imageScans[i] %><br/><br/></p>
            			<%
					} else
            		{%> <iframe width="660" height="500" src="/ess-app/receipts/ReceiptViewImage.jsp?image=<%= imageScans[i] %>"/> <br/><br/><br/>
            		<%}
				}
    		}
    	}
	}
}
%>
