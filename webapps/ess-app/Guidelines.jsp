<%--
Guidelines.jsp - returns the guideline report against the uploaded report
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
<jsp:useBean id = "GL"
     class="ess.Guideline"
     scope="page" />
<jsp:useBean id = "ReportDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "Enh"
     class="ess.Enhancement"
     scope="page" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
 
<%@ include file="DBAccessInfo.jsp" %>


<% String database = request.getParameter("database");

String CCode = "";
String ownersName = request.getParameter("email");
boolean pFlag = PersFile.setPersInfo(ownersName); 

if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
}
if (pFlag && PersFile.getChallengeCode().equals(CCode)) {
%>
<%@ include file="SystemInfo.jsp" %>
<% 

   Log.println("[000] Guidelines.jsp run by: " + ownersName);

   ReportDOM.setConnection(PersFile.getConnection());
   ReportDOM.setSQLTerminator(PersFile.getSQLTerminator());

   Enh.setConnection(PersFile.getConnection());    //database,DBUser,DBPassword
   Enh.setSQLTerminator(PersFile.getSQLTerminator()); 

   GL.setConnection(PersFile.getConnection());
   GL.setSQLTerminator(PersFile.getSQLTerminator());
   GL.setUpFiles();
   GL.setCompany(PersFile.getCompany()); //This will get the runners G/L and not nec. the reporter.

   ReportDOM.setDOM(request.getParameter("report")); 
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
   
   java.util.Date now = new java.util.Date(); 

   String submissionMsg = SystemDOM.getDOMTableValueFor("messages","submission_link","Submit expense report for approval and payment");

%> 

<html>
<head>
<link rel="stylesheet" href="<%= PersFile.getWebServer() %>/<%= PersFile.getWebFolder() %>/expense.css" type="text/css">
</head>
<body>
<h1>Guideline check: <%= now%></h1><h2> 
<% if (GL.getStatus().equals("Passed")) { %>
Report has passed the <%= GL.getGuideType()%> guideline check.<br>
<% 
   Log.println("[000] Guidelines.jsp passed");
   } else { %>    
Report has FAILED the <%= GL.getGuideType()%> guideline check.<br> 
<% 
   Log.println("[000] Guidelines.jsp failed");
   } %>
<br></h2>

<%= GL.toString() %><br>
End of guideline check<br><br>
<p align="center"><a class="ExpenseReturnLink" href="javascript: void parent.contents.ListDelay()" tabindex="1">Return to report display</a></p>
<p align="center"><a class="ExpenseReturnLink" href="javascript: void parent.contents.OnlyIfEditable(parent.contents.defaultHead+'submitXMLSMTP.html')" tabindex="2"><%= submissionMsg %></a></p>
  
</body>
</html>
<%
   Log.println("[000] Guidelines.jsp finished");
} else { 
  Log.println("[000] Guidelines.jsp Relogin request"); %>
  <%@ include file="ReloginRedirectMsg.jsp" %>
<%
}
%>
