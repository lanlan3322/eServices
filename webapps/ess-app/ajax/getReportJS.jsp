<%--
getReport.jsp - Downloads report from XMLR to browser
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
<jsp:useBean id = "DOM"
     class="ess.AdisoftDOM"
     scope="page" />
<jsp:useBean id = "Rep2"
     class="ess.Report2Client"
     scope="page" />
<jsp:useBean id = "Sys"
     class="ess.ServerSystemTable"
     scope="page" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<%-- jsp:useBean id = "GetXML" class="ess.SaveAndStatus" scope="page" --%>
<jsp:useBean id = "GetXML"
     class="ess.ReportContainer"
     scope="page" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />           
<%@ include file="../DBAccessInfo.jsp" %>
<% 
String database = request.getParameter("database");

String ownersName = request.getParameter("email");
boolean pFlag = PersFile.setPersInfo(ownersName); 
String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { //CCode wasn't working - investigate
//if (pFlag) { 	
  DOM.setConnection(PersFile.getConnection()); //probably don't need this but leave for now...
  DOM.setSQLTerminator(PersFile.getSQLTerminator());
  Sys.setConnection(PersFile.getConnection()); 
  Sys.setSQLTerminator(PersFile.getSQLTerminator()); 
  String editable = request.getParameter("edit");
  if (editable == null) editable = "Yes";
   String reference  = request.getParameter("reference");
   String reg_dbase = Sys.getSystemString("XML_FOLDER","E:\\Register\\");
   Log.println("[000] ajax.getReportJS.jsp: " + ownersName + " " + reference + " " + reg_dbase);
   String report = GetXML.getXML(reg_dbase,ownersName,reference);
   if (report != "") { 
     DOM.setDOM(report); 
     Rep2.setDateFormat(PersFile.getDateFormat());
     Rep2.setDecimal(PersFile.getDecimal());
     Rep2.setSeparator(PersFile.getSeparator());
     Rep2.setReportStrings(DOM); %>
     function setReport() {

     var HeaderString = <%= Rep2.getHeader() %>;
     var PurposeString = <%= Rep2.getPurposes() %>;
     var ReceiptString = <%= Rep2.getReceipts() %>;

     parent.NewReport();
     parent.DirectEdit = false; //JH 2005-12-20
     parent.ProcessHeader(HeaderString);
     <% if (request.getParameter("status").equals("Copy")) { %>
        parent.setNameValue(parent.Header,"status","Copy");
     <% } else { %>
     <%  if (request.getParameter("status").equals("Sent") || request.getParameter("status").equals("Resent")) { %>
          parent.setNameValue(parent.Header,"status","Changed Sent");
     <%  } else { %>
          parent.setNameValue(parent.Header,"status","Changed New");
     <%  }
       } %>
       parent.setNameValue(parent.Header,"reference","<%= reference %>");
       parent.setNameValue(parent.Header,"editable","<%= editable %>");
       parent.ProcessRepList('1',PurposeString);
       parent.ProcessRepList('2',ReceiptString);
       parent.ReportIsSaved = true;  //jh 2006-10-04
       parent.SetReportIsSaved = true;  //jh 2006-10-04
parent.Log.println("getReportJS","setReport load has finished");       
       parent.ListDelay();
    }
    function screenLoad() {
      setReport();
      return true;
    }
 
    
<% } else { %>
    alert("<%= Lang.getString("REPORT_NOT_FOUND") %>")

    function setReport() {
    }
    function screenLoad() {
      return true;
    }
<% Log.println("[500] ajax/getReport.jsp report not found: " + reference + " for " + ownersName);
   } %>
<% } else { %>
   alert("<%= Lang.getString("ERROR_SECURITY") %>")
   function screenLoad() {
      return true;
   }
   
<% } %>
   function screenUnload() {
      return true;
   }
