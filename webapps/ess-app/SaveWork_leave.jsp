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
     class="ess.OutputTextFile"
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
<jsp:useBean id = "Sys"
     class="ess.ServerSystemTable"
     scope="page" />
      
     
<% 
String ownersName = request.getParameter("email");
String xDOM = request.getParameter("report");
Sys.setConnection(PersFile.getConnection()); 
Sys.setSQLTerminator(PersFile.getSQLTerminator()); 

Log.println("[313] ajax/SaveWork.jsp owner is " + ownersName);

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
   try {
	   String reg_dbase = Sys.getSystemString("XML_FOLDER","/var/ess/xmlr/tmp/");
	   String fileName = reg_dbase + "/tmp/" + ownersName + ".xml";
       // String fileName = "c:/ess/ess/xmlr/tmp/" + ownersName + ".xml";
	   SaveXML.setFile(fileName, xDOM);
%>OK<%  		    
   } catch (java.lang.Exception e) {
	   Log.println("[500] ajax/SaveWork.jsp failed for: " + ownersName);
       e.printStackTrace(); 
%>FAILED<%   
   }
   Log.println("[314] ajax/SaveWork.jsp report contents: " + xDOM);   

}
%>