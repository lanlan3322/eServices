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
     class="ess.V2DB2ESS"
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
   String NeedPassword = "No";

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

<br/>
<div id="approveSection" style="BORDER-BOTTOM: 1px solid; BORDER-LEFT: 1px solid; BORDER-TOP: 1px solid; BORDER-RIGHT: 1px solid">
    <form method="POST" accept-charset="ISO-8859-1" action="<%= PersFile.getAppServer() %>/<%= PersFile.getAppFolder() %>/ajax/ApproveSave_leave.jsp">
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
      <input type="hidden" name="newdepart" value>
      <input type="hidden" name="password" value="">
    </form>
	</div>
<span language="javascript" id="script" folder="<%= PersFile.getAppServer() + "/" + PersFile.getAppFolder() %>" file="ajax/ApproveReportJS_leave.jsp?reference=<%= reference%>&voucher=<%= voucher%>&status=<%= status%>&rcpt2=<%= rcpt2%>&reply2=<%= reply2%>&NeedPassword=<%= NeedPassword%>"/>

<% Log.println("[000] ApproveReport.jsp - End - " + reply2); %>

<% } else { %>
   <%@ include file="../ajax/ReloginRedirectMsg.jsp" %>
<% } %>
