<%--
Check.jsp - Check item and return value or "Not Valid"
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
<%@ include file="DBAccessInfo.jsp" %>
<% 
Log.println("[000] GetLogo.jsp accessed by: " + PersFile.getName());
boolean pFlag = true;
if (pFlag) {
%>
<%@ include file="SystemInfo.jsp" %>
<%
   Reg.setConnection(PersFile.getConnection());
   Reg.setSQLTerminator(PersFile.getSQLTerminator()); 

   String SQLCommand;
   String company = request.getParameter("company");
   if (company == null) company = PersFile.getCompany();
   if (company != null && !company.equals("")) {
      SQLCommand = SystemDOM.getDOMTableValueFor("checksql","logo");
      SQLCommand = Reg.SQLReplace(SQLCommand,"$company$",Reg.repStr(company));
      Log.println("[000] GetLogo.jsp SQL:" + SQLCommand);
   } else {
      SQLCommand = null;
   }   
   response.setHeader("Cache-Control","no-cache"); //HTTP 1.1
   response.setHeader("Pragma","no-cache"); //HTTP 1.0
   response.setDateHeader ("Expires", 0); //prevents caching at the proxy server
//Reg.myResult.getString(1)
   if (SQLCommand != null && Reg.setResultSet(SQLCommand)) { 
       String imageFile = Reg.myResult.getString(1);
       String width = Reg.myResult.getString(2);
       String height = Reg.myResult.getString(3);
       String description = Reg.myResult.getString(4);
       
       String template = "<img id=\"innerImage\" src=\"" + PersFile.getWebServer() + "/" + PersFile.getWebFolder()  + "/images/$image$\" width=\"$width$\" height=\"$height$\" alt=\"$description$\"></img>";
       // String template = "<img id=\"innerImage\" src=\"" + PersFile.getWebServer() + "/" + PersFile.getWebFolder()  + "/images/$image$\" style=\"width:$width$ height:$height$\" alt=\"$description$\"></img>";
       
       template = Reg.SQLReplace(template,"$image$",imageFile);
       template = Reg.SQLReplace(template,"$width$",width);
       template = Reg.SQLReplace(template,"$height$",height);
       template = Reg.SQLReplace(template,"$description$",description);
       Log.println("[000] GetLogo.jsp template: " + template);
       out.println(template);

   } else { 
       out.println("eClaim System");
   }
} //if (pFlag && PersFile.getChallengeCode().equals(CCode)) 
Reg.close();      //cleaning up open connections 
%>



