<%--
SaveXML.jsp - saves a report to the user's register file (XMLR) 
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
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" /> 
<jsp:useBean id = "Sys"
     class="ess.ServerSystemTable"
     scope="page" />            
     
<%@ include file="../DBAccessInfo.jsp" %>
<% 
Sys.setConnection(PersFile.getConnection());   //Used by RemoveWorkInclude.jsp
Sys.setSQLTerminator(PersFile.getSQLTerminator()); 

String database = request.getParameter("database");
String ownersName = request.getParameter("email");
String reportComment = request.getParameter("comment");
String reference = request.getParameter("reference");


if (reportComment != null) SaveXML.setComment(reportComment);

Log.println("[000] ajax/SaveXML.jsp owner is " + ownersName);
Log.println("[000] ajax/SaveXML.jsp reference is " + reference);

boolean pFlag = PersFile.setPersInfo(ownersName); 

String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
Log.println("[000] ajax/SaveXML.jsp ccode is " + CCode);
if (pFlag && PersFile.getChallengeCode().equals(CCode)) {  
// if (pFlag){

	SaveXML.setConnection(PersFile.getConnection());
    SaveXML.setSQLTerminator(PersFile.getSQLTerminator());

   if (request.getParameter("status").equals("Copy")) { %>

   <%= Lang.getString("ERROR_CANNOT_CHANGE_COPY") %>

<% } else { %>
   <% SaveXML.setOwner(ownersName); 
    if (SaveXML.getDOMProcessed()) { 
      String setStatus = request.getParameter("status");
      SaveXML.setStatus(setStatus);
      Log.println("[000] ajax/SaveXML.jsp report status: " + setStatus);
      String xDOM = request.getParameter("report");
      Log.println("[000] ajax/SaveXML.jsp report being saved: " + xDOM);
      Log.println("[000] ajax/SaveXML.jsp reference key is: " + SaveXML.getKey());
      if (reference.equals("")) {
    	  Log.println("[300] ajax/SaveXML.jsp saving without reference");   //JH 2014-10-6
    	  SaveXML.setXMLFile(xDOM);
      } else {
    	  Log.println("[300] ajax/SaveXML.jsp saving with reference");   //JH 2014-10-6
    	  SaveXML.setXMLFile(xDOM,reference); 
      } %>
      <%java.util.Date now = new java.util.Date(); %> 
      <% if (SaveXML.getStatus() == "Failure") { 
            Log.println("[500] SaveXML.jsp - Save Failure");
      %>
         <%= Lang.getString("ERROR_REPORT_NOT_SAVED") %>
      <% } else { 
             String xSavedMsg = Lang.getString("REPORT_SAVED");
             xSavedMsg = Lang.getReplace(xSavedMsg,"$now$",now.toString());
             xSavedMsg = Lang.getReplace(xSavedMsg,"$lastReference$",SaveXML.getLastReference());
             xSavedMsg = Lang.getReplace(xSavedMsg,"$email$",request.getParameter("email"));
             xSavedMsg = Lang.getReplace(xSavedMsg,"$status$",Lang.getDataString(SaveXML.getStatus()));
      %>
         <%= xSavedMsg %>
 <%@ include file="RemoveWorkInclude.jsp" %>
      <% } 
     } else {
     Log.println("[500] ajax/SaveXML.jsp Register access failure for: " + PersFile.getEmailAddress()); 
%>
     <%= Lang.getString("ERROR_ACCESSING_PERSONAL_DATA") %>
<%
     }
  }%>

<br><br>
<span id="personalData"><%= Lang.getString("PERSONAL_DATA_BEING_UPDATED") %></span>
<br><br>

<span language="javascript" id="script" folder="<%= PersFile.getAppServer() + "/" + PersFile.getAppFolder() %>" file="ajax/SaveXMLJS.jsp?email=<%= ownersName%>&reference=<%= SaveXML.getLastReference()%>&ccode=<%= CCode%>&status=<%= SaveXML.getStatus()%>"/>

<% } else { %>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } %>

