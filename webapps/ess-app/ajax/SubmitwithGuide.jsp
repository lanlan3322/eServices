<%--
SubmitwithGuide.jsp - runs guidecheck and provides link the SubmitDbase.jsp
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

<!-- Copyright (c) 2003 Adisoft, Inc., All rights reserved -->
<%@ page contentType="text/html" %>

<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "GL"
     class="ess.Guideline"
     scope="page" />
<jsp:useBean id = "ReportDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "Enh"
     class="ess.Enhancement"
     scope="page" />
<jsp:useBean id = "SaveXML"
     class="ess.ReportContainer"
     scope="page" />
<jsp:useBean id = "SavePers"
     class="ess.SavePersData"
     scope="page" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />   
<jsp:useBean id = "CheckDup"
	class="ess.XML2ESS"
	scope="page" />


<%@ include file="../DBAccessInfo.jsp" %>

<%
String ownersName = request.getParameter("email");

boolean pFlag = PersFile.setPersInfo(ownersName); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 

if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
// if (pFlag) { 
	
  Log.println("[005] Start SubmitwithGuide: " + ownersName);
%> 

<%@ include file="../SystemInfo.jsp" %>

<% String database = request.getParameter("database");
   String submitMethod = request.getParameter("submitMethod");
//Log.println("[---] submitMethod : " + submitMethod);
   if (submitMethod == null) submitMethod = "SubmitXML.jsp";
   
   ReportDOM.setConnection(PersFile.getConnection());
   ReportDOM.setSQLTerminator(PersFile.getSQLTerminator());
   GL.setConnection(PersFile.getConnection());
   GL.setSQLTerminator(PersFile.getSQLTerminator());
   GL.setLanguage(PersFile.getLanguage());
   GL.setDateFormat(PersFile.getDateFormat());
   GL.setDecimal(PersFile.getDecimal());
   GL.setSeparator(PersFile.getSeparator());
   GL.setUpFiles();
   Enh.setConnection(PersFile.getConnection());
   Enh.setSQLTerminator(PersFile.getSQLTerminator());
   SaveXML.setConnection(PersFile.getConnection());  
   SaveXML.setSQLTerminator(PersFile.getSQLTerminator());
   SaveXML.setOwner(ownersName);
   if (SaveXML.getDOMProcessed()) {
   String reportString = request.getParameter("report");
   String reference = request.getParameter("reference");
   SaveXML.setXMLFile(reportString, reference);
   ReportDOM.setDOM(reportString);
   ReportDOM.setNormal(); 
   ReportDOM.setPromoteSubElements("expenselist");
   Enh.setExp2Cat(ReportDOM);
   Enh.setTable("CHARGE");
   Enh.setSearch4("charge");
   Enh.setCompliment("reimb");
   Enh.setParentType("charge");
   Enh.setEnhancement("reimb");
   Enh.setGeneric(ReportDOM);
   GL.setReport(ReportDOM.getDOM()); 
   String submissionMsg = Lang.getString("SUBMIT_MSG","Confirm to submit");
   java.util.Date now = new java.util.Date();  
Log.println("[000] ajax/SubmitwithGuide.jsp setup is complete");    
%>
<h2><%= Lang.getString("SUBMIT_TITLE") %></h2><div id="submitSection">
<% 
String homeCurrencyCheck = ";" + SystemDOM.getDOMTableValueFor("configuration","currency","US Dollar") + ";Local Currency;";
String reportCurrency = ReportDOM.getDOMTableValueFor("header","currency","US Dollar");
Log.println("[000] ajax/SubmitwithGuide.jsp currency set");    


String checkForDuplicates = SystemDOM.getDOMTableValueFor("receiptmanagement","duplicatecharge","");

if (!checkForDuplicates.equals(""))
{
	CheckDup.setConnection(PersFile.getConnection());
	CheckDup.setSQLTerminator(PersFile.getSQLTerminator());
	CheckDup.setUpFiles();
	CheckDup.setLanguage(PersFile.getLanguage());
	CheckDup.setDateFormat(PersFile.getDateFormat());
	CheckDup.setDecimal(PersFile.getDecimal());
	CheckDup.setSeparator(PersFile.getSeparator());
	CheckDup.reset();
	CheckDup.setDenormalizeClient(true);
	CheckDup.setReference(reference);
	CheckDup.setVoucherPrefix(SystemDOM.getDOMTableValueFor("configuration","alternateprefix","A"));
	CheckDup.set(ReportDOM);
	
   if (CheckDup.isDuplicateReceipts()) { %>
<p><%= Lang.getString("DUPLICATE_RECEIPTS_FOUND","Duplicate Receipts Have Been Found!")%></p>
<% 
   		String duplicates[] = CheckDup.getDuplicateReceipts();
   		for (int i = 0; i < duplicates.length; i++) 
   		{
   			%> <%= duplicates[i] %>&nbsp;<%= Lang.getString("DUPLICATE_RECEIPT_FOUND","is duplicated on this report")%><br/> <%
   		}
   		%><br/><br/><%
   } 
}



if (reportCurrency.equals("") || homeCurrencyCheck.indexOf(reportCurrency) > -1) { 
	
if (GL.getStatus().equals("Passed")) { %>
<!-- <%= Lang.getStringWithReplace("REPORT_PASSED_GUIDELINE","$guideType$",GL.getGuideType()) %><br> -->
<% } else { %>    
<!-- <%= Lang.getStringWithReplace("REPORT_FAILED_GUIDELINE","$guideType$",GL.getGuideType()) %><br> -->
<% } 
Log.println("[000] ajax/SubmitwithGuide.jsp guideline message complete");    

%>
<!-- <br></h2>
<%= GL.toString() %><br>
End of guideline check --> 
<% } //End of currency loop %>

<%= Lang.getString("submit_screen_msg") %>

</div>
<form method="get" action="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/<%= submitMethod %>"> 
<input id="btSave" type="button" value="<%= submissionMsg %>" name="B1" onClick="Javascript: void guideSubmit()">
</form>
<input id="cancelReport" type="button" value="Cancel" name=" "  onClick="javascript: void cancelThisReport()" onDblClick="screenDupFlagOK = false">

<script language="javascript" id="script" folder="<%= PersFile.getAppServer() + "/" + PersFile.getAppFolder() %>" file="ajax/SubmitwithGuideJS.jsp?email=<%= ownersName%>&reference=<%= reference %>&ccode=<%= CCode%>&lastReference=<%= SaveXML.getLastReference()%>&screen=<%= submitMethod%>"/>

<% } else {
     Log.println("[500] ajax/SubmitwithGuide.jsp Register access failure for: " + PersFile.getEmailAddress()); 
%>
     <%= Lang.getString("ERROR_ACCESSING_PERSONAL_DATA") %>
<% }
%>
 
<% } else { %>

   <%@ include file="ReloginRedirectMsg.jsp" %>

<% } %>
<% Log.println("[000] SubmitwithGuide.jsp finished");
%>
