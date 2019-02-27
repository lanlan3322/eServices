<%--
UploadSelect.jsp - Specifies which file to import 
Copyright (C) 2006 R. James Holton

This program is free software; you can redistribute it and/or modify it 
under the terms of the GNU General Public License as published by the 
Free Software Foundation; either version 2 of the License, or (at your option) 
any later version.  This program is distributed in the hope that it will be 
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
Public License for more details.

You should have received a copy of the GNU General Public License along with 
this program; if not, write to the Free Software Foundation, Inc., 
675 Mass Ave, Cambridge, MA 02139, USA. 
--%>
<%@ page contentType="text/html" %>
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
     scope="page" />     
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "ESSDisplay"
     class="ess.DB2ESS"
     scope="session" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" /> 
          
<%@ include file="../../DBAccessInfo.jsp" %><%

Log.println("[000] UploadSelect.jsp by: " + PersFile.getEmailAddress());

String persnumber = PersFile.getPersNum();
String email = PersFile.getEmailAddress();

String CCode = "";
// Check to see if the personnelSession object is OK

Reg.setConnection(PersFile.getConnection());

Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

%>

<%@ include file="../../SystemInfo.jsp" %>
<%
String reportScript = SystemDOM.getDOMTableValueFor("history","ajaxscreenscript","ajax/HistoryReportV1.jsp");
String database = request.getParameter("database");
String ccode = request.getParameter("ccode");
%>
                 
<%     String pvoucher;
       String voucherViewed = request.getParameter("viewed");
       String historyViewed;
       
       // String pvoucherPrefix = SystemDOM.getDOMTableValueFor("vouchertable","voucherprefix","");
       voucherViewed = "00000000" + voucherViewed;
       voucherViewed = voucherViewed.substring(voucherViewed.length() - 8);  //may want to adjust for a prefix
       historyViewed = contructPVoucher(voucherViewed.substring(voucherViewed.length() - 8), SysTable);  //adjust for a prefix
       
       // String voucherViewed = ESSDisplay.getPreviousNumber();  //This logic is being moved to JS
       // int counter = 0;
       boolean foundReport = false;
       boolean historyReport = false;
       
       String SQLCommand = SystemDOM.getDOMTableValueFor("receiptmanagement","uploadselectsqlhistory");
       SQLCommand = Reg.SQLReplace(SQLCommand,"$persnum$",persnumber);
       Log.println("[000] UploadSelect.jsp Upload SQL (history) :" + SQLCommand);

       if (Reg.setResultSet(SQLCommand)) {
        	do{	
            	pvoucher = PersFile.getTrim(Reg.myResult.getString(1));
            	if (pvoucher.equals(historyViewed)) {
            		foundReport = true;
            		historyReport = true;
            	}
       		} while (Reg.myResult.next());
       } 
       
       SQLCommand = SystemDOM.getDOMTableValueFor("receiptmanagement","uploadselectsqlregister");
       SQLCommand = Reg.SQLReplace(SQLCommand,"$owner$",email.toUpperCase());
       Log.println("[000] UploadSelect.jsp Upload SQL (register):" + SQLCommand);
       
       //Consider putting in an array and then sorting the array
       if (!foundReport && Reg.setResultSet(SQLCommand)) {
        	do{	
            	pvoucher = PersFile.getTrim(Reg.myResult.getString(1));
            	pvoucher = "0000000" + pvoucher;
            	pvoucher = pvoucher.substring(pvoucher.length() - 8);  //adjust for a prefix
            	if (pvoucher.equals(voucherViewed)) {
            		foundReport = true;
                }
           	} while (Reg.myResult.next() && !foundReport);
       }    
  if (foundReport) {
  %> 
     
  <div id="receiptUploadScreen">
  <form method="POST" id="UploadSelectForm" name="UploadSelectForm" action="" ENCTYPE="multipart/form-data" target="upload_target" onSubmit="return startUpload();">
  <p><h2><%= Lang.getDataString("REC_UPL_SCANTITLE","Receipt scans for report") %>: <%= voucherViewed %> 
  <input type="hidden" id="pvoucherFld" name="pvoucher" value="<%= contructPVoucher(voucherViewed, SysTable) %>"></h2></p>   
  <p id="result"></p>
  <p>
  <table>
  <tr><td>
  <label for="receiptFileName"><%= Lang.getDataString("REC_UPL_SELECT","Select receipt file to upload(use browse button)") %>: </label> 
  <input type="file" id="receiptFileName" name="filename" size="50">
  </td></tr>
  
  <tr>
  <td> <label for="scanComment"><%= Lang.getDataString("REC_UPL_COMMENT","Comment (expense-type amount) ") %>: </label> 
  <input type="text" id="scanComment" name="scanComment" size="36""></td>
  </tr>
  
  
  <tr><td>
  <input id="btUploadReceipt" type="button" value="<%= Lang.getDataString("REC_UPL_BUTTON","Upload receipt scan file") %>" name="Process"  onClick="javascript: void this.form.submit()">
  </td></tr></table>
  <br/>
  </p>
</form>
<iframe id="upload_target" name="upload_target" src="" width="400" height="30" style="display: none"></iframe>  
<span id="upload_target"></span>

<p><h2><%= Lang.getDataString("REC_EMAIL_ASSOCIATED","Email scans waiting to be attached")%>:</h2></p>
<p><span id="emailScans"><%= Lang.getDataString("REC_EMAIL_HERE","Emailed scan files will appear here.")%></span></p>

<p><h2><%= Lang.getDataString("REC_UPL_ASSOCIATED","Receipt scan files associated with this report")%>:</h2></p>
<p><span id="scanFiles"><%= Lang.getDataString("REC_UPL_HERE","Uploaded scan files will appear here.")%></span></p>
<br>

<input id="btSaveSubmit" type="button" value="Submit" name=" "  onClick="javascript: void parent.loadHTMLScreenAJAX('submitWithGuide.html') ">
<!--
<p>
<% if (historyReport && ESSDisplay.getVoucherNumber().compareTo("") > 0) { // check to see which screen this was called from %>
<a href="javascript: void parent.writeDelayMsg('<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/<%= reportScript %>?email=<%= PersFile.getPrintableEmailAddress() %>&rcpt2=<%= PersFile.getPrintableEmailAddress()%>&reference=<%= ESSDisplay.getPersNum() %>&voucher=<%= ESSDisplay.getVoucherNumber() %>&ccode=<%= ccode %>&status=<%= ESSDisplay.getStatus()%>&database=<%= database%>')"><span class="ExpenseReturnLink"><%= Lang.getDataString("REC_UPL_RETURN","Return to report") %>&nbsp;<%= ESSDisplay.getVoucherNumber() %></span></a>
<% } else {  %>
<a href="javascript: void parent.loadHTMLScreenAJAX(parent.entryScreen)"><span class="ExpenseReturnLink"><%= Lang.getDataString("REC_UPL_RETURN","Return to report") %></span></a>
<% } %>
</p>-->
</div>
<span id="script" file="shared/receipts/UploadSelect.js"/>
<% } else { %>
<p><h2><%= Lang.getDataString("REC_NOT_FOUND","The expense report was not found.")%></h2></p>
<span id="script" file="shared/blank.js"/>
<% } %>

<%@ include file="../../ConstructPVoucher.jsp" %>
