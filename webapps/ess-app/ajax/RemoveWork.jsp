<%--
RemoveWork.jsp - removes the safe-store copy of the report from XMLR/tmp. Standalone version  
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
<jsp:useBean id = "CK"
     class="ess.ChallengeKey"
     scope="application" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="application" />
<jsp:useBean id = "Sys"
     class="ess.ServerSystemTable"
     scope="page" />
      
<% 
String ownersName = request.getParameter("email");
Sys.setConnection(PersFile.getConnection()); 
Sys.setSQLTerminator(PersFile.getSQLTerminator()); 

Log.println("[000] ajax/RemoveWork.jsp owner is " + ownersName);

boolean pFlag = PersFile.setPersInfo(ownersName); 

String CCode = "";
if (pFlag) {
  if(PersFile.getChallengeCode().equals("")) {
    PersFile.setChallengeCode(request.getRemoteAddr(),CK.getChallengeKey());
  }
  CCode = request.getParameter("ccode"); 
} 
if (pFlag && PersFile.getChallengeCode().equals(CCode)) { 
	//if (pFlag){	
   String reg_dbase = Sys.getSystemString("XML_FOLDER","/var/ess/xmlr/");
   String fileName = reg_dbase + "tmp/" + ownersName + ".xml";
//   String fileName = "c:/ess/ess/xmlr/tmp/" + ownersName + ".xml";
   java.io.File removeFile = new java.io.File(fileName);
   if (removeFile.exists()) {
   try {
       if (removeFile.delete()) {
%>OK<% 
Log.println("[000] ajax/RemoveWork.jsp OK: " + fileName);
       } else {
%>NOT_DELETED<% 
Log.println("[000] ajax/RemoveWork.jsp Not Deleted: " + fileName);
       }
   } catch (java.lang.Exception e) {
       e.printStackTrace(); 
%>FAILED<%
Log.println("[500] ajax/RemoveWork.jsp Failed - See stack trace: " + fileName);
   }
} else {
%>WARNING<%	
Log.println("[400] ajax/RemoveWorkInclude.jsp Does not exist: " + fileName);		
}

} else {
%>SECURITY_ERROR<%
Log.println("[400] ajax/RemoveWork.jsp Security error/User session expired.");
}
%>