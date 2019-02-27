<%--
PrepopButton.jsp - Check item and return value or "Not Valid"
Copyright (C) 2008 R. James Holton

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

<jsp:useBean id = "Reg"
     class="ess.AdisoftDbase"
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
<jsp:useBean id = "Dt"
     class="ess.CustomDate"
     scope="session" />
<%@ include file="../DBAccessInfo.jsp" %>
<% 
Log.println("[000] PrepopButton.jsp accessed by :" + PersFile.getName());
boolean pFlag = true;
if (pFlag) {
%>
<%@ include file="../SystemInfo.jsp" %>
<%
   Reg.setConnection(PersFile.getConnection());
   Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

   String SQLCommand;
   String checkSQL = request.getParameter("check");
   String param1 = request.getParameter("param1");
   String param2 = request.getParameter("param2");
   if (param1 != null) {
      SQLCommand = SystemDOM.getDOMTableValueFor("checksql",checkSQL);
      SQLCommand = Reg.SQLReplace(SQLCommand,"$param1$",Reg.repStr(param1));
      Log.println("[000] PrepopButton.jsp SQL:" + SQLCommand);
   } else {
      SQLCommand = null;
   }   
   response.setHeader("Cache-Control","no-cache"); //HTTP 1.1
   response.setHeader("Pragma","no-cache"); //HTTP 1.0
   response.setDateHeader ("Expires", 0); //prevents caching at the proxy server
//Reg.myResult.getString(1)
   if (SQLCommand != null && Reg.setResultSet(SQLCommand)) { 
	   String retStr = ";" + Reg.myResult.getString(1);
	   Log.println("[000] PrepopButton.jsp result: " + retStr);
	   if (param2 == null) param2 = "prepopbutton";
	   String PrepopButtonHTML = SystemDOM.getDOMTableValueFor("prepopulateditems",param2);
	   Log.println("[000] PrepopButton.jsp PrepopButtonHTML: " + PrepopButtonHTML);
       out.println(PrepopButtonHTML);
   } else { 
       out.println("&nbsp;");
   }
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
Reg.close();      //cleaning up open connections 
%>



