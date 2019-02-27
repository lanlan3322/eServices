<%--
HistoryReportPrintStH.jsp - Displays report from central db for investigations
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
     class="ess.V4DB2ESS"
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
<jsp:useBean id = "Scan"
     class="ess.Scan"
     scope="session" />        
     
<%@ include file="../DBAccessInfo.jsp" %>
<%@ include file="../SystemInfo.jsp" %>
<% 
   //String database = request.getParameter("database");
   //String reference  = request.getParameter("reference");
   String voucher  = request.getParameter("voucher");
   //String status = request.getParameter("status");
   String email = request.getParameter("email");

//boolean pFlag = PersFile.setPersInfo(email); 
boolean pFlag = true;
//String CCode = "";
//if (pFlag) {
//  if(PersFile.getChallengeCode().equals("")) {
//    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
//  }
//  CCode = request.getParameter("ccode"); 
//} 

//if (pFlag && PersFile.getChallengeCode().equals(CCode)) {
if (pFlag) {

   Log.println("[000] ajax/HistoryReportPrintV4.jsp - Start - " + email); 
   
   // include file="StatusInfo.jsp"  {optional for older classes}

   //V2ESSDisplay.setConnection(PersFile.getConnection());
   //V2ESSDisplay.setSQLTerminator(PersFile.getSQLTerminator());
   //V2ESSDisplay.setUpFiles();
  
   //V2ESSDisplay.setLanguage(PersFile.getLanguage());
   //V2ESSDisplay.setDateFormat(PersFile.getDateFormat());
   //V2ESSDisplay.setDecimal(PersFile.getDecimal());
   //V2ESSDisplay.setSeparator(PersFile.getSeparator());
   
   V2ESSDisplay.setSummaries("printhistory");

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
  
   
   //V2ESSDisplay.reset();
   //V2ESSDisplay.setDenormalizeClient(true);
   //V2ESSDisplay.set(voucher);
   //V2ESSDisplay.setReportReferenceName("voucher");
   //V2ESSDisplay.setJavaScriptFunction("window.opener.parent.ShowHistoryTrans");
   //V2ESSDisplay.setDisplayHTML("/ajax/DisplayReportItem.jsp");
   //V2ESSDisplay.setDisplayHTML("/../edit/DisplayReportItem.jsp");
   Log.println("[000] PrintHistoryReport.jsp - Set - " + email); 
   GL.setReport(voucher);
   %>
   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
   <html>
   <head>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <link rel="stylesheet" href="/ess/expenseLinkoPrint.css" type="text/css">
   <!--[if IE 7]> <link rel="stylesheet" href="/ess/expenseLinko_ie7.css" type="text/css" media="screen" /> <![endif]-->
   <!--[if IE 8]> <link rel="stylesheet" href="/ess/expenseLinko_ie8.css" type="text/css" media="screen" /> <![endif]-->
   </head>
   <body onLoad="window.print();window.close();">
   <%@ include file="HistoryReportLayoutV4.jsp" %>
   </body>
   </html>
<% } else { %>
   <%@ include file="../ajax/ReloginRedirectMsg.jsp" %>
<% } %>



