<%--
ApproveReport.jsp - displays report along with approval option
Copyright (C) 2004 R. James Holton

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
<jsp:useBean id = "ESS"
     class="ess.DB2ESS"
     scope="page" />
<jsp:useBean id = "GL"
     class="ess.Guideline"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Sys"
     class="ess.ServerSystemTable"
     scope="page" />
<!-- check on the scope of the ServerSystemTavle -->
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Currency"
     class="ess.Currency"
     scope="session" />   
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />        
<jsp:useBean id = "Scan"
     class="ess.Scan"
     scope="session" />   
     
<%@ include file="../DBAccessInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>
<% 
   String database = request.getParameter("database");
   String reference  = request.getParameter("reference");
   String voucher  = request.getParameter("voucher");
   String status = request.getParameter("status");
   String reply2 = request.getParameter("email");
   String rcpt2 = request.getParameter("rcpt2");

boolean pFlag = PersFile.setPersInfo(reply2); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
//if (pFlag) { 
   Sys.setConnection(PersFile.getConnection()); 
   Sys.setSQLTerminator(PersFile.getSQLTerminator()); //JH 2006-3-1
   String NeedPassword = Sys.getSystemString("pwd_approval","yes");

   Log.println("[000] ApproveReport.jsp - Start - " + reply2); 
   
   ESS.setConnection(PersFile.getConnection());
   ESS.setSQLTerminator(PersFile.getSQLTerminator());
   ESS.setUpFiles();
   
   ESS.setLanguage(PersFile.getLanguage());
   ESS.setDateFormat(PersFile.getDateFormat());
   ESS.setDecimal(PersFile.getDecimal());
   ESS.setSeparator(PersFile.getSeparator());
   ESS.setSummaries("approve");
   
   ESS.setReportReferenceName("voucher");  //uses ess.properties values

   if (!Currency.isAlreadyLoaded()) {
     Currency.setConnection(PersFile.getConnection());
     Currency.setSQLTerminator(PersFile.getSQLTerminator()); 
     Currency.setSQLStrings();
   }

   GL.setConnection(PersFile.getConnection());
   GL.setSQLTerminator(PersFile.getSQLTerminator());
   GL.setLanguage(PersFile.getLanguage());
   GL.setDateFormat(PersFile.getDateFormat());
   GL.setDecimal(PersFile.getDecimal());
   GL.setSeparator(PersFile.getSeparator());
   GL.setSystemTable(Sys); // JH 2006-03-01
   GL.setUpFiles();

   Log.println("[000] ApproveReport.jsp - Connect - " + reply2); 

   ESS.set(voucher);
//   ESS.setReportReferenceName("Voucher");
   GL.setCompany(ESS.getCompany());

   Log.println("[000] ApproveReport.jsp - Set - " + reply2); 

%>




<% //if (request.getParameter("ReportTitle").equals("Yes")) { %>
<%=ESS.printTitle(Lang.getString("APP_REPORT_TITLE")) %>
<% //} %>

<small>

<%= ESS.printHeader() %>
<% Log.println("[000] ApproveReport.jsp - DB2 - " + reply2); 
String homeCurrencyCheck = ";" + SystemDOM.getDOMTableValueFor("configuration","currency","US Dollar") + ";Local Currency;";
String reportCurrency = ESS.getCurrency();
// if (reportCurrency.equals("") || homeCurrencyCheck.indexOf(reportCurrency) > -1) { 
if(false) {   //bypassing the guidelines
   GL.setReport(voucher);
   Log.println("[000] ApproveReport.jsp - DB2Guide - " + reply2); 
%>
<p><big><%= Lang.getString("guidelineTitle") %></big></p>
<small>
<% if (GL.getStatus().equalsIgnoreCase("passed")) { %>
<%= Lang.getStringWithReplace("REPORT_PASSED_GUIDELINE","$guideType$",GL.getGuideType() )%><br><br>
<% } else { %>    
<%= Lang.getStringWithReplace("REPORT_FAILED_GUIDELINE","$guideType$",GL.getGuideType() )%><br><br>
<% }
} %>
<%= ESS.printCrossChargeWarning() %> 
<%
//if (reportCurrency.equals("") || homeCurrencyCheck.indexOf(reportCurrency) > -1) { 
if (false) {  //Bypassing the guidelines 
  Log.println("[000] ApproveReport.jsp - Guide - " + reply2); %>
<%= GL.toString() %></small><br>
<% } %>


<%=ESS.printTripByDay() %>

<%=ESS.printFleetItems() %>
<%=ESS.printAdvanceItems() %>

<%=ESS.printExpenseSummary() %>
<%=ESS.printReceipts() %>
<%@ include file="../ScanImageList.jsp" %>
<%=ESS.printExpenseGrid() %>

</small>

<br>
<%=ESS.printConversion() %>
<%=ESS.printEApproval() %>

<div id="approveSection" style="BORDER-BOTTOM: 1px solid; BORDER-LEFT: 1px solid; BORDER-TOP: 1px solid; BORDER-RIGHT: 1px solid">
    <form method="POST" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ajax/ApproveSave.jsp">
      <input type="hidden" name="email" value>
      <input type="hidden" name="company" value>
      <input type="hidden" name="ccode" value>
      <input type="hidden" name="database" value>
      <input type="hidden" name="voucher" value>
      <input type="hidden" name="reference" value>
      <input type="hidden" name="status" value>
      <input type="hidden" name="action" value>
      <input type="hidden" name="rcpt2" value>
      <input type="hidden" name="reply2" value>
      <input type="hidden" name="msgdata" value>
    <% if (NeedPassword.equalsIgnoreCase("NO"))
       {
    %> 
      <input type="hidden" name="password" value="">
    <% }
    %>
    <div class="col1of2">
        <input class="actiontype" type="radio" value="result" checked name="actiontype"><%= Lang.getString("approveReport") %><br />
        <input class="actiontype" type="radio" name="actiontype" value="reject"><%= Lang.getString("rejectReport") %><br />
        <label for="msgdata"><%= Lang.getLabel("message") %></label>
        <textarea rows="2" name="msgdataRaw" cols="29" onChange="resolveMsgData()"></textarea>
	</div>
    <div class="col1of2">
        <label for="name"><%= Lang.getLabel("approvedBy") %></label>
        <input type="text" name="name" readOnly>
    
    <% if (!NeedPassword.equalsIgnoreCase("NO"))
       {
    %> 
        <label for="password"><%= Lang.getLabel("password") %></label>
        <input type="password" name="password">
    <% }
    %>
    </div>
    <div class="col1of1">
		<input type="button" id="btApprove" value="<%= Lang.getString("REPORT_PROCESS_ACCORDINGLY") %>" name="B2" onClick="Javascript: void Approve()">
    </div>
    </form>
	</div>

<small>
<%=ESS.printAuditInfo() %>
<%=ESS.printDepartSummary() %>
</small>
<br>
<%@ include file = "../ScanImageDisplay.jsp" %>

***
<span language="javascript" id="script" folder="<%= PersFile.getAppServer() + "/" + PersFile.getAppFolder() %>" file="ajax/ApproveReportJS.jsp?reference=<%= reference%>&voucher=<%= voucher%>&status=<%= status%>&rcpt2=<%= rcpt2%>&reply2=<%= reply2%>&NeedPassword=<%= NeedPassword%>"/>

<% Log.println("[000] ApproveReport.jsp - End - " + reply2); %>

<% } else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } %>
