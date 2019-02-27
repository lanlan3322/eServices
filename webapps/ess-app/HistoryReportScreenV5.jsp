<%--
HistoryReportScreenV5.jsp - Displays report from central db for investigations
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
<jsp:useBean id = "V2ESSDisplay"
     class="ess.V5DB2ESS"
     scope="session" />
<jsp:useBean id = "GL"
     class="ess.Guideline"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />           
<jsp:useBean id = "ESSDisplay"
     class="ess.DB2ESS"
     scope="session" />
<jsp:useBean id = "Scan"
     class="ess.Scan"
     scope="session" />   
          
<%@ include file="../DBAccessInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>
<%@ include file="../NoCaching.jsp" %>
<% 
   String database = request.getParameter("database");
   String reference  = request.getParameter("reference");
   String voucher  = request.getParameter("voucher");
   String status = request.getParameter("status");
   String email = request.getParameter("email");

boolean pFlag = PersFile.setPersInfo(email); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 

if (pFlag && PersFile.getChallengeCode().equals(CCode)) {
//if (pFlag) {

   Log.println("[000] ajax/HistoryReport.jsp - Start - " + email); 
   
   // include file="StatusInfo.jsp"  {optional for older classes}

   // Very ugly...need to replace soon!!!
   
   V2ESSDisplay.setConnection(PersFile.getConnection());
   V2ESSDisplay.setSQLTerminator(PersFile.getSQLTerminator());
   V2ESSDisplay.setUpFiles();
   V2ESSDisplay.setLanguage(PersFile.getLanguage());
   V2ESSDisplay.setDateFormat(PersFile.getDateFormat());
   V2ESSDisplay.setDecimal(PersFile.getDecimal());
   V2ESSDisplay.setSeparator(PersFile.getSeparator());
   V2ESSDisplay.setSummaries("history");
   
   ESSDisplay.setConnection(PersFile.getConnection());
   ESSDisplay.setSQLTerminator(PersFile.getSQLTerminator());
   ESSDisplay.setUpFiles();
   ESSDisplay.setLanguage(PersFile.getLanguage());
   ESSDisplay.setDateFormat(PersFile.getDateFormat());
   ESSDisplay.setDecimal(PersFile.getDecimal());
   ESSDisplay.setSeparator(PersFile.getSeparator());
   ESSDisplay.setSummaries("history");
     
   GL.setConnection(PersFile.getConnection());
   GL.setSQLTerminator(PersFile.getSQLTerminator());
   GL.setLanguage(PersFile.getLanguage());
   GL.setDateFormat(PersFile.getDateFormat());
   GL.setDecimal(PersFile.getDecimal());
   GL.setSeparator(PersFile.getSeparator());
   // GL.setSystemTable(Sys);   {optional for older classes}
   GL.setUpFiles();

   GL.setLanguage(PersFile.getLanguage());
   GL.setDateFormat(PersFile.getDateFormat());
   GL.setDecimal(PersFile.getDecimal());
   GL.setSeparator(PersFile.getSeparator());
  
   
   V2ESSDisplay.reset();
   V2ESSDisplay.setDenormalizeClient(true);
   V2ESSDisplay.set(voucher);
   V2ESSDisplay.setReportReferenceName("voucher");
   V2ESSDisplay.setJavaScriptFunction("parent.ShowHistoryTrans");
   V2ESSDisplay.setDisplayHTML("/ajax/DisplayReportItem.jsp");
      
   ESSDisplay.reset();
   ESSDisplay.setDenormalizeClient(true);
   ESSDisplay.set(voucher);
   ESSDisplay.setReportReferenceName("voucher");
   ESSDisplay.setJavaScriptFunction("parent.ShowHistoryTrans");
   ESSDisplay.setDisplayHTML("/ajax/DisplayReportItem.jsp");
   
   
   Log.println("[000] ajax/HistoryReport.jsp - Set - " + email); 
   
   //examples javascript:window.print(), javascript('$appserver$/$appfolder$/custom/HistoryReport.jsp','printing','dependent,width=1,height=1,title,resizable,titlebar')
   String ajaxPrintHref = SystemDOM.getDOMTableValueFor("history","ajaxprinthref","javascript:window.print()");
   ajaxPrintHref = ess.Utilities.replaceStr(ajaxPrintHref,"$appserver$",PersFile.getAppServer());
   ajaxPrintHref = ess.Utilities.replaceStr(ajaxPrintHref,"$appfolder$",PersFile.getAppFolder());
   ajaxPrintHref = ess.Utilities.replaceStr(ajaxPrintHref,"$webserver$",PersFile.getWebServer());
   ajaxPrintHref = ess.Utilities.replaceStr(ajaxPrintHref,"$webfolder$",PersFile.getWebFolder());
   ajaxPrintHref = ess.Utilities.replaceStr(ajaxPrintHref,"$datebase$", database);
   ajaxPrintHref = ess.Utilities.replaceStr(ajaxPrintHref,"$reference$",reference);
   ajaxPrintHref = ess.Utilities.replaceStr(ajaxPrintHref,"$voucher$",voucher);
   ajaxPrintHref = ess.Utilities.replaceStr(ajaxPrintHref,"$status$", status);
   ajaxPrintHref = ess.Utilities.replaceStr(ajaxPrintHref,"$email$", email);

%>

<% GL.setReport(voucher);%>
<% Log.println("[000] ajax/HistoryReport.jsp - G/L finished - " + email); %>
<p class="alignRight"><a href="javascript: void parent.PersWindow(parent.defaultApps + 'ajax/HistoryList.jsp')"><span class="ReturnLink"><%= Lang.getString("retToHistory") %></span></a></p>

<p align="right" id="btPrint"><a href="<%= ajaxPrintHref %>"><span class="ReturnLink"><%= Lang.getString("print") %></span></a></p>
<%@ include file="HistoryReportLayoutV5.jsp" %>
<%@ include file = "../ScanImageDisplay.jsp" %>

<span language="javascript" id="script" folder="<%= PersFile.getAppServer() + "/" + PersFile.getAppFolder() %>" file="ajax/HistoryReportJS.jsp?reference=<%= reference%>&voucher=<%= voucher%>&status=<%= status%>"/>

<% Log.println("[000] ajax/HistoryReport.jsp - End - " + email); %>

<% } else { %>
   <%@ include file="../ajax/ReloginRedirectMsg.jsp" %>
<% } %>


