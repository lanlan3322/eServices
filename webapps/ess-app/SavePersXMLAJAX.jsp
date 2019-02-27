<%--
SavePersXML.jsp - Saves personal data to the XMLU folder
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
<jsp:useBean id = "SavePers"
     class="ess.SavePersData"
     scope="page" />
<jsp:useBean id = "PersFile"
     class="ess.PersonnelSession"
     scope="session" />
<jsp:useBean id = "Log"
     class="ess.AuditTrail"
     scope="session" />
<jsp:useBean id = "Lang"
     class="ess.Language"
     scope="session" />           
     
	 
<%@ include file="../DBAccessInfo.jsp" %>
<%
String database = request.getParameter("persdbase");
String ownersName = request.getParameter("email");
boolean pFlag = ownersName.equals(PersFile.getEmailAddress()); 

if (pFlag) {  
   boolean StatusFlag;
   SavePers.setConnection(PersFile.getConnection());
   SavePers.setSQLTerminator(PersFile.getSQLTerminator()); 
   SavePers.setFile(database,ownersName); 
   if (SavePers.getStatus().equals("Saved")) { 
%><%= Lang.getString("PERSONAL_DATA_SAVED")%><% 
     StatusFlag = true;
     Log.println("[000] ajax/SavePersXMLAJAX.jsp saved: " + ownersName);
   } else { 
     StatusFlag = false;
     Log.println("[500] ajax/SavePersXMLAJAX.jsp error first attempt failed: " + ownersName);
   }
   if (!StatusFlag) {
      SavePers.setFile(database,ownersName); 
      if (SavePers.getStatus().equals("Saved")) { 
%><%= Lang.getString("PERSONAL_DATA_SAVED")%><% 
         StatusFlag = true;
         Log.println("[400] ajax/SavePersXMLAJAX.jsp saved on second try: " + ownersName);
      } else { 
%><strong><em><%= Lang.getString("PERSONAL_DATA_NOT_SAVED")%></em></strong><% 
         StatusFlag = false;
         Log.println("[500] ajax/SavePersXMLAJAX.jsp error second attempt failed for: " + database);
      }

   }
  } else { 
    Log.println("[500] ajax/SavePersXMLAJAX.jsp login/security error.");
%>
   <%@ include file="ReloginRedirectMsg.jsp" %>
<% } %>