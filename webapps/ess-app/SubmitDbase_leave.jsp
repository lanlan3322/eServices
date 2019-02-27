<%--
SubmitDbase.jsp - submits a report for processing
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

<%@ page contentType="text/html" isThreadSafe="false" %>
<jsp:useBean id = "SendDbase"
     class="ess.ProcessESSReport"
     scope="page" />
<jsp:useBean id = "ReportDOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "SaveXML"
     class="ess.ReportContainer"
     scope="page" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="session" />
<jsp:useBean id = "Enh"
     class="ess.Enhancement"
     scope="page" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />           
<jsp:useBean id = "Scan"
     class="ess.Scan"
     scope="session" />        
     
<%@ include file="../DBAccessInfo.jsp" %>

<% 

String CompanyName = "x1";  //hardcoded and can later put in AdisoftDbase call to system (f1 has special processing)
//String database = request.getParameter("database");

boolean errorCondition = false; 

String ownersName = request.getParameter("email");
Log.println("[286] Start ajax/SubmitDbase: " + ownersName + " under session ID: " + session.getId());
boolean pFlag = PersFile.setPersInfo(ownersName); 
String reportSaved = "No";
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 

%>

<script language="javascript" id="script" folder="<%= PersFile.getAppServer() + "/" + PersFile.getAppFolder() %>" file="ajax/SubmitDbaseJS_leave.jsp?email=<%= ownersName%>&reference=<%= reference %>&ccode=<%= CCode%>&lastReference=<%= SaveXML.getLastReference()%>&status=<%= SaveXML.getStatus()%>&endproc=<%= request.getParameter("endproc")%>&saved=<%= reportSaved%>&errorcond=<%= EC%>"/>


<% } else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } 
Log.println("[287] End SubmitDbase: " + ownersName);
%>

<%@ include file="../StatXlation.jsp" %>
