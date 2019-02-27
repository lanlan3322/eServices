<%--
getWorkJS.jsp - Gets the safe-store copy of the report found in the xmlr/tmp folder
Copyright (C) 2010 R. James Holton

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

<% 

String ownersName = request.getParameter("email");
boolean pFlag = PersFile.setPersInfo(ownersName);   //work a little on the security
String CCode = request.getParameter("ccode");
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
} 
// if (pFlag && PersFile.getChallengeCode().equals(CCode)) { //CCode wasn't working - investigate
if (pFlag) { 	
  DOM.setConnection(PersFile.getConnection()); //probably don't need this but leave for now...
  DOM.setSQLTerminator(PersFile.getSQLTerminator());
  %>
  <%@ include file="../SystemInfo.jsp" %>
  <%@ include file="../StatusInfo.jsp" %>
  <%
  String editable = request.getParameter("edit");
  String routingRule = "default";  //May want to get a person's routing rules later
  String repStat = "";
  if (editable == null) editable = "Yes";
   String reg_dbase = Sys.getSystemString("XML_FOLDER","E:\\Register\\");
   String report = reg_dbase + "/tmp/" + ownersName + ".xml";
   java.io.File myfile = new java.io.File(report);
   if (myfile.exists()) { 
     DOM.setDOM(myfile); 
     String repEdit = "Yes";
     String repWarning = "No";
     String reference = DOM.getDOMTableValueFor("reference");
     Log.println("[000] ajax/getWorkJS.jsp xmlr/tmp restore reference: " + reference + " for " + ownersName + ", initial flags: " + repEdit + "," + repWarning);
     if (!reference.equals("")) {

    	 String alternatePrefix = SystemDOM.getDOMTableValueFor("configuration","alternateprefix","0");
         reference = "0000000" + reference;
         int xLen = 8 - alternatePrefix.length();
         String pVoucher = alternatePrefix + reference.substring(reference.length()-xLen);
         String SQLCommand = "Select RP_STAT from REPORT where PERS_NUM = '$persnum' and PVOUCHER = '$pvoucher'";
    	 SQLCommand = SystemDOM.getDOMTableValueFor("reportstatus","findsql",SQLCommand);
    	 String persnum = DOM.getThirdLevelInfo("report","header","persnum");
    	 SQLCommand = PersFile.SQLReplace(SQLCommand,"$persnum$",PersFile.repStr(persnum));
    	 SQLCommand = PersFile.SQLReplace(SQLCommand,"$pvoucher$",PersFile.repStr(pVoucher));

    	 if (PersFile.setResultSet(SQLCommand)) {
    	    repStat = PersFile.myResult.getString("RP_STAT");
    	 	repEdit = StatEditable(repStat, routingRule, StatusDOM);
    	 	repWarning = StatWarning(repStat, routingRule, StatusDOM);
    	 	Log.println("[000] ajax/getWorkJS.jsp reference: " + reference + ", flags: " + repEdit + "," + repWarning);
    	 } else {
    		 Log.println("[000] ajax/getWorkJS.jsp SQL not found reference: " + reference + ", flags: " + repEdit + "," + repWarning); 
    	 }
     }
     
     	if (repEdit.equalsIgnoreCase("Yes")) {
    	 
     
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
     
     			parent.setNameValue(parent.Header,"reference","<%= DOM.getThirdLevelInfo("report","header","xref") %>");
     			parent.setNameValue(parent.Header,"editable","<%= DOM.getThirdLevelInfo("report","header","editable") %>");
     
     			parent.ProcessRepList('1',PurposeString);
     			parent.ProcessRepList('2',ReceiptString);
     			parent.ReportIsSaved = false;  //jh 2010-10-5
				parent.Log.println("getWorkJS","setReport CCode: " + parent.CCode);       
     			parent.ListDelay();<% 
    	 		
     			if (repWarning.equalsIgnoreCase("Yes")) {
     			%>
     			alert ("<%= Lang.getString("REPORTS_WORK_WARNING") %>");
     			<%
     		 	Log.println("[340] ajax/getWorkJS.jsp duplicate warning issued to " + ownersName);
     			} else {
     			Log.println("[341] ajax/getWorkJS.jsp no warning for " + ownersName);
     			}
%>     		}	<% 
       } else { %>
		function setReport() {
             document.getElementById("getWork").innerHTML = "<%= Lang.getString("REPORTS_WORK_ALREADY_PROCESSED") %>";
        }     
<% 
       Log.println("[342] ajax/getWorkJS.jsp report fully preocessd - not loaded for " + ownersName);
	
	} %> 


    function screenLoad() {
      setReport();
      // setTimeout("setReport()", 400);
      // myESSMenu.setMenu();
      return true;
    }
 
    
<% } else { %>
    
    function setReport() {
    }
    function screenLoad() {
      document.getElementById("getWork").innerHTML = "<%= Lang.getString("REPORTS_WORK_NONE") %>";
      // myESSMenu.setReport();
      return true;
    }
<% Log.println("[000] ajax/getWorkJS.jsp no report for " + ownersName);
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
<%@ include file="../StatEditable.jsp" %>