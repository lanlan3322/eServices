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
       
       boolean foundReport = false;
       boolean historyReport = false;
	   String newLeaveFrom = "";
	   String newLeaveFromAMPM = "";
	   String newLeaveTo = "";
	   String newLeaveToAMPM = "";
	   String newLeaveReason = "";
	   String newLeaveTotal = "";
	   String newLeaveType = "";
	   String newLeaveStatus = "";
	   String textTitle = Lang.getDataString("REC_UPL_SCANTITLE","Receipt scans for report");

       String SQLCommand = SystemDOM.getDOMTableValueFor("receiptmanagement","uploadselectsqlhistory_leave");
       SQLCommand = Reg.SQLReplace(SQLCommand,"$leavenum$",voucherViewed);
       Log.println("[000] UploadSelect.jsp Upload SQL (history) :" + SQLCommand);

       if (Reg.setResultSet(SQLCommand)) {
            foundReport = true;
           	historyReport = true;
 	        newLeaveFrom = PersFile.getTrim(Reg.myResult.getString(4));
	        newLeaveFromAMPM = PersFile.getTrim(Reg.myResult.getString(5));
	        newLeaveTo = PersFile.getTrim(Reg.myResult.getString(6));
	        newLeaveToAMPM = PersFile.getTrim(Reg.myResult.getString(7));
	        newLeaveReason = PersFile.getTrim(Reg.myResult.getString(8));
	        newLeaveTotal = PersFile.getTrim(Reg.myResult.getString(11));
	        newLeaveType = PersFile.getTrim(Reg.myResult.getString(3));
			newLeaveStatus = PersFile.getTrim(Reg.myResult.getString(1));
			if(newLeaveStatus.equals("Pending")){
				textTitle = "Please upload receipt for your pending leave";
			}
       } 
       boolean bAttachmentRequired = true;
	   if(newLeaveType.equals("Annual")
		   || newLeaveType.equals("Childcare")
		   || newLeaveType.equals("Maternity")
		   || newLeaveType.equals("Off In Lieu")
		   || newLeaveType.equals("Unpaid"))
	   {
		   bAttachmentRequired = false;
	   }
  if (foundReport) {
  %> 
     
  <div id="receiptUploadScreen">
  <form method="POST" id="UploadSelectForm" name="UploadSelectForm" action="" ENCTYPE="multipart/form-data" target="upload_target" onSubmit="return startUpload();">
  <p><h2><%= textTitle%>: <%= voucherViewed %> 
  <input type="hidden" id="pvoucherFld" name="pvoucher" value="<%= voucherViewed%>"></h2></p>   
  <p id="result"></p>
  <p>
     <table id="previousTable" border="0" cellspacing="0" cellpadding="0">
         <tr>
             <th width="5%">&nbsp;</th>
             <th width="10%">Total</th>
             <th width="10%"><%= Lang.getColumnTitle("LEAVE_TYPE") %></th>
             <th width="10%"><%= Lang.getColumnTitle("LEAVE_FROM") %></th>
             <th width="5%"><%= Lang.getColumnTitle("LEAVE_FROM_AMPM") %></th>
             <th width="10%"><%= Lang.getColumnTitle("LEAVE_TO") %></th>
             <th width="5%"><%= Lang.getColumnTitle("LEAVE_TO_AMPM") %></th>
             <th width="10%"><%= Lang.getColumnTitle("LEAVE_STATUS") %></th>
             <th width="35%"><%= Lang.getColumnTitle("LEAVE_REASON") %></th>
         </tr>
            <tr>
			<td width="5%">&nbsp;</td>
            <td width="10%"><%= newLeaveTotal%></td>
            <td width="10%"><%= newLeaveType%></td>
            <td width="10%"><%= newLeaveFrom%></td>
            <td width="5%"><%= newLeaveFromAMPM%></td>
            <td width="10%"><%= newLeaveTo%></td>
            <td width="5%"><%= newLeaveToAMPM%></td>
            <td width="10%"><%= newLeaveStatus%></td>
            <td width="35%"><%= newLeaveReason%></td>
            </tr>

  <p>
	 <table>
  <tr><td>
  <label for="receiptFileName"><%= Lang.getDataString("REC_UPL_SELECT","Select receipt file to upload(use browse button)") %>: </label> 
  <input type="file" id="receiptFileName" name="filename" size="50">
  </td></tr>
  
  <tr>
  <td style="display: none"> <label for="scanComment"><%= Lang.getDataString("REC_UPL_COMMENT","Comment (expense-type amount) ") %>: </label> 
  <input style="display: none" type="text" id="scanComment" name="scanComment" size="36""></td>
  </tr>
  
  
  <tr><td>
  <input id="btUploadReceipt" type="button" value="<%= Lang.getDataString("REC_UPL_BUTTON","Upload receipt scan file") %>" name="Process"  onClick="javascript: void this.form.submit()">
  </td></tr></table>
  <br/>
  </p>
</form>
<iframe id="upload_target" name="upload_target" src="" width="400" height="30" style="display: none"></iframe>  
<span id="upload_target"></span>

<div style="display: none"><h2><%= Lang.getDataString("REC_EMAIL_ASSOCIATED","Email scans waiting to be attached")%>:</h2></div>
<div style="display: none"><span id="emailScans"><%= Lang.getDataString("REC_EMAIL_HERE","Emailed scan files will appear here.")%></span></div>

<p><h2><%= Lang.getDataString("REC_UPL_ASSOCIATED","Receipt scan files associated with this report")%>:</h2></p>
<p><span id="scanFiles"><%= Lang.getDataString("REC_UPL_HERE","Uploaded scan files will appear here.")%></span></p>
<br>

<%
	if(bAttachmentRequired)
	{
		%>
<p><span style="color:red" align="left">Attachment is required!!!</span></p>
		<%
	}
%>
<!--<input id="btSaveSubmit" type="button" value="Submit" name=" "  onClick="javascript: void parent.loadHTMLScreenAJAX('submitWithGuide_leave.html') ">-->
<input id="btSaveSubmit" type="button" value="Submit" name=""  onClick="SubmitLeave(<%=bAttachmentRequired%>)">

</div>
<span id="script" file="shared/receipts/UploadSelect_leave.js"/>
<% } else { %>
<p><h2><%= Lang.getDataString("REC_NOT_FOUND","The expense report was not found.")%></h2></p>
<span id="script" file="shared/blank.js"/>
<% } %>
